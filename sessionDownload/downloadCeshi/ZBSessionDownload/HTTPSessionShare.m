//
//  HTTPSessionShare.m
//  downloadCeshi
//
//  Created by 瞄财网 on 2017/3/16.
//  Copyright © 2017年 瞄财网. All rights reserved.
//

#import "HTTPSessionShare.h"
#import "AFNetworking.h"
#import "FileModelDbManager.h"
#import "FileModel.h"
#import "FileModelDbManager.h"
#import "NSProgress+downSpeed.h"
#import "NSString+Common.h"
#import "C_common.h"
#import "ZB_NetWorkShare.h"
#import "ZBSessionDownloadManager.h"

@interface HTTPSessionShare ()<ZB_NetWorkShareDelegate>


@property (readwrite, nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) NSMutableDictionary *taskDict;



//存储正在下载的文件模型
@property (nonatomic, strong) NSMutableArray *downloadingList;
//存储磁盘缓存的文件
@property (nonatomic, strong) NSMutableArray *diskFileList;

@property (nonatomic, strong) NSMutableDictionary *completionHandlerDictionary;

@end

@implementation HTTPSessionShare

static HTTPSessionShare *_share = nil;


+ (HTTPSessionShare *)httpSessionShare
{

   static dispatch_once_t once;
    _dispatch_once(&once, ^{
        _share = [[self alloc] init];
    });
    return _share;
}


- (instancetype)init
{
    if (self) {
        self = [super init];
        
        
        //注册通知处理异常情况
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionDownloadAplicationWillTerminate) name:UIApplicationWillTerminateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        _lock = [[NSLock alloc] init];
        _lock.name = @"ZBHTTPSessionShareTaskDict";
        
        _taskDict = [NSMutableDictionary dictionary];
        //后台任务处理
        _completionHandlerDictionary = [NSMutableDictionary dictionary];
        _maxCount = 3;
        _downloadingList = [NSMutableArray array];
        _diskFileList = [NSMutableArray array];
        //更新文件状态，防止重新运行程序时，上次未下载完成的任务可能会开始下载
        [FileModelDbManager updateUnFinishedFileState];
        [_diskFileList addObjectsFromArray:[FileModelDbManager getAllDownloadedFile]];
        [_downloadingList addObjectsFromArray:[FileModelDbManager getAllNotCompletedFile]];
        
        
        [ZB_NetWorkShare ZB_NetWorkShare].backSessionCompletionDelegate = self;

    }
    return self;
}


//在后台下载完成以后的处理
- (void)backSessionDidCompletionWithSession:(NSString *)identifier
{
    
}

- (void)appDidEnterBackground
{
    NSLog(@"appDidEnterBackground");
}
- (void)sessionDownloadAplicationWillTerminate
{
    //如果程序在后台下载直到完成期间一直没有初始化，会导致崩溃
    //操作：选择一个下载，然后退出程序，再运行程序以后进入后台，等后台下载完成以后再初始化session或者
    //点击选择一个下载，然后退出程序，直到在后台下载完再次打开程序(大概是3分钟左右）
    
    
    
    //程序意外退出时 保存断点信息
    //点击home进入后台，再双击杀死程序，此时resumedata不为空，task的state==3直接双击home退出app则resumedata为空，task的state==2；
    NSDictionary *dict = _taskDict.copy;
    NSLog(@"%@",dict);
    dispatch_semaphore_t sem = dispatch_semaphore_create(1);
    __weak typeof(self) weak = self;
    for (NSURLSessionDownloadTask *task in _taskDict.allValues) {
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        
        [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            __strong typeof(weak) strongSelf = weak;
           
            [strongSelf handleResumeData:resumeData file:nil];
           
            dispatch_semaphore_signal(sem);
        }];
    }
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
}
- (void)removeFileWithFileArray:(NSArray *)fileArray
{
    for (FileModel *pt in fileArray) {
        NSURLSessionDownloadTask *task = [self taskForKey:pt.fileUrl];
        if (task) {
            [self removeTaskForKey:pt.fileUrl];
            [task cancel];
        }
        [FileModelDbManager delFiles:pt];
        //此处必须传入路径，而且不能传入数据库中存储的路径
        [[NSFileManager defaultManager] removeItemAtPath:[[[FileManageShare fileManageShare] miaocaiRootDownloadFileCache] stringByAppendingPathComponent:pt.fileName] error:nil];
        [self.downloadingList removeObjectsInArray:fileArray];
        [self.diskFileList removeObjectsInArray:fileArray];
    }
}



- (void)downloadFileWithFileModel:(FileModel *)model
{
    if ([self handelDBFile:model]) {
        
        [self startDownload];
    }
}

- (BOOL)handelDBFile:(FileModel *)model
{
    if (model.fileUrl.length == 0) {
        return NO;
    }
    //判断文件是否已经存在
    FileModel *downFile = [FileModelDbManager getFileModeWithFilUrl:model.fileUrl];
    if (downFile) {
        if (downFile.fileState == FileDownloaded) {
            NSLog(@"文件已经下载");
            return NO;
        } else {
            NSLog(@"文件已经在下载列表中");
            return NO;
        }
    }
    [FileModelDbManager insertFile:model];
    [self.downloadingList addObject:model];
    return YES;
}

- (void)downloadFileWithFileModelArray:(NSArray<FileModel*> *)modelArray
{
    for (FileModel *file in modelArray) {
        [self handelDBFile:file];
    }
    [self startDownload];
}

- (void)startDownload
{
    for (FileModel *file in self.downloadingList) {
        if (self.taskDict.count < self.maxCount) {
            if (file.fileState == FileWillDownload) {
                file.fileState = FileDownloading;
            }
        } else if(self.taskDict.count > self.maxCount){
            if (file.fileState == FileDownloading) {
                file.fileState = FileStopDownload;
            }
        } else {
            
        }
        if (file.fileState == FileDownloading) {
            NSURLSessionTask *task = [self taskForKey:file.fileUrl];
            if (!task) {
                [self AF_BeginDownloadFileWithFileModel:file];
            }
        } else {
            //此处未异步回掉self.downloadingcout--，不能及时生效，所以更换另外一种方式
            NSURLSessionDownloadTask *task = [self taskForKey:file.fileUrl];
                if (task) {
                    [self removeTaskForKey:file.fileUrl];
                    if (file) {
                        file.fileState = FileStopDownload;
                        [FileModelDbManager insertFile:file];
                    }
                  [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                      NSLog(@"%zd",task.state);
                  }];
            }
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.sessionDelegate respondsToSelector:@selector(updateTableViewWithFlModel:)] && self.sessionDelegate) {
            [self.sessionDelegate updateTableViewWithFlModel:nil];
        }
        
    });
}


- (void)startAllTask
{
    for (FileModel *file in self.downloadingList) {
        if (file.fileState != FileDownloaded) {
            file.fileState = FileWillDownload;
        }
    }
    [self startDownload];

}
- (void)stopAllTask
{
    for (FileModel *file in self.downloadingList) {
        if (file.fileState == FileDownloading || file.fileState == FileWillDownload) {
            file.fileState = FileStopDownload;
        }
    }
    [self startDownload];

}
- (void)stopDownloadWithFile:(FileModel *)file
{
    if (file.fileUrl.length == 0) {
        return;
    }
    for (FileModel *tm in self.downloadingList) {
        if ([file.fileUrl isEqualToString:tm.fileUrl]) {
            tm.fileState = FileStopDownload;
            
        }
    }
    [self startDownload];
}

- (void)continueDownloadWithFile:(FileModel *)file
{
    NSLog(@"continue");
    if (file.fileUrl.length == 0) {
        return;
    }
    //预防已下载的文件出现在下载列表中
    if (file.fileState == FileDownloaded) {
        return;
    }
    

    __block NSInteger tmIdx = 0;
    
    [self.downloadingList enumerateObjectsUsingBlock:^(FileModel *tm, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([file.fileUrl isEqualToString:tm.fileUrl]) {
            tm.fileState = FileDownloading;
            tmIdx = idx;
            *stop = YES;
        }

    }];
    //不进行下载排序
//    [self.downloadingList removeObjectAtIndex:tmIdx];
//    [self.downloadingList insertObject:file atIndex:0];

    [self startDownload];
}

- (void)AF_BeginDownloadFileWithFileModel:(FileModel *)file
{

    //获取文件缓存信息
    NSLog(@"22222222");
    NSURLSessionDownloadTask *task = nil;
    __weak typeof(self) weak = self;
    NSLog(@"%@",[[FileManageShare fileManageShare] miaocaiRootTempCache]);
    if (file.resumeData.length > 0 && file.tempPath.length > 0) {
        
        NSData *resumData = [file.resumeData dataUsingEncoding:NSUTF8StringEncoding];
        
        //移动缓存文件到tmp目录，进行断点下载,此处不能用file的属性传入缓存路径名，程序第一次运行的时候目录不存在，会出现错误
        
        NSError *error ;
        [[NSFileManager defaultManager] moveItemAtPath:[[[FileManageShare fileManageShare] miaocaiRootTempCache] stringByAppendingPathComponent:file.tempFileName] toPath:[RootTemp stringByAppendingPathComponent:file.tempFileName] error:&error];
        task = [[ZB_NetWorkShare ZB_NetWorkShare] downloadTaskWithResumeData:resumData progress:^(NSProgress *downloadProgress) {
            __strong typeof(weak) strongSelf = weak;
            [strongSelf addDownloadProgressWithProgress:downloadProgress file:file];
            
        } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            __strong typeof(weak) strongSelf = weak;
            return [strongSelf addDownloadDestinationBlockWithLocation:targetPath downloadTask:response file:file];

        } completionHandler:^(NSURLResponse *response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            __strong typeof(weak) strongSelf = weak;
            [strongSelf addCompleteHandlerWithDownloadTask:response error:error file:file];
        }];
        
        
    } else {
        task = [[ZB_NetWorkShare ZB_NetWorkShare] downloadTaskWithUrlStr:file.fileUrl progress:^(NSProgress *downloadProgress) {
            __strong typeof(weak) strongSelf = weak;
             [strongSelf addDownloadProgressWithProgress:downloadProgress file:file];
        } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            __strong typeof(weak) strongSelf = weak;
            return [strongSelf addDownloadDestinationBlockWithLocation:targetPath downloadTask:response file:file];
            
        } completionHandler:^(NSURLResponse *response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            __strong typeof(weak) strongSelf = weak;
            [strongSelf addCompleteHandlerWithDownloadTask:response error:error file:file];
        }];
    }
    //创建下载任务
    if (task) {
        [self addTask:task ForKey:file.fileUrl];
        [task resume];
    }

}


- (void)addDownloadProgressWithProgress:(NSProgress *)progress file:(FileModel *)file
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        file.fileReceivedSize = [NSString stringWithFormat:@"%zd",progress.completedUnitCount];
        file.fileSize = [NSString stringWithFormat:@"%zd",progress.totalUnitCount];
        file.fileDownSpeed = [[NSString getFileSizeString:progress.zb_downSpeed] stringByAppendingString:@"/s"];
        if ([self.sessionDelegate respondsToSelector:@selector(updateProgressWithFlModel:)] && self.sessionDelegate) {
            [self.sessionDelegate updateProgressWithFlModel:file];
        }

    });
}
- (NSURL *)addDownloadDestinationBlockWithLocation:(NSURL *)location downloadTask:(NSURLResponse *)downloadTask file:(FileModel *)file
{
    NSLog(@"didfinishtourl   ===%@",location.path);
    NSURL *destPath = [NSURL fileURLWithPath:[RootCache stringByAppendingPathComponent:downloadTask.suggestedFilename]];
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:location.path];
    file.filePath = destPath.path;
    file.fileState = FileDownloaded;
    //下载完成时需要设置文件的大小，因为设置了每隔1s更新一次，最后一次有可能会没有更新
    file.fileReceivedSize = [NSString stringWithFormat:@"%@",@(data.length)];
    file.fileSize = [NSString stringWithFormat:@"%@",@(data.length)];
    
    [self.downloadingList removeObject:file];
    [self.diskFileList addObject:file];
    
    [FileModelDbManager insertFile:file];
    
    return destPath;
}

- (void)addCompleteHandlerWithDownloadTask:(NSURLResponse *)downloadTask error:(NSError *)error file:(FileModel *)file
{
    NSURLSessionDownloadTask *task = [self taskForKey:file.fileUrl];
    NSLog(@"completionerror====%@",@(task.state));
    if (error) {
        NSLog(@"%@",error);
        NSData *data = error.userInfo[NSURLSessionDownloadTaskResumeData];
        [self handleResumeData:data file:file];
        
    }
    [self removeTaskForKey:file.fileUrl];
//    [self.downloadinTaskCountDict removeObjectForKey:file.fileUrl];
    [self startDownload];
}

- (void)setMaxCount:(NSInteger)maxCount
{
    _maxCount = maxCount;
    [self startDownload];
}

- (void)handleResumeData:(NSData *)resumeData file:(FileModel *)file
{
    if (resumeData.length > 0) {
        
        NSDictionary *tmdict = getResumeDictionary(resumeData);
        if (!file) {
            for (FileModel *tm in _downloadingList) {
                if ([tm.fileUrl isEqualToString:tmdict[@"NSURLSessionDownloadURL"]]) {
                    file = tm;
                    break;
                }

//                file = [FileModelDbManager getFileModeWithFilUrl:tmdict[@"NSURLSessionDownloadURL"]];
            }
        }
        if (file) {
            file.resumeData = [[NSString alloc] initWithData:resumeData encoding:NSUTF8StringEncoding];
            
            NSString *tmFileName = [NSString stringWithFormat:@"%@",[tmdict objectForKey:@"NSURLSessionResumeInfoTempFileName"]];
            file.tempFileName = tmFileName;
            file.tempPath = [[[FileManageShare fileManageShare] miaocaiRootTempCache] stringByAppendingPathComponent:file.tempFileName];
            NSData *data = [[NSFileManager defaultManager] contentsAtPath:[RootTemp stringByAppendingPathComponent:file.tempFileName]];
            file.fileReceivedSize = [NSString stringWithFormat:@"%@",@(data.length)];
            NSError *error;
            [[NSFileManager defaultManager] moveItemAtPath:[RootTemp stringByAppendingPathComponent:file.tempFileName] toPath:file.tempPath error:&error];
        }
    }
    
    if (file) {
        file.fileState = FileStopDownload;
        [FileModelDbManager insertFile:file];
        [self startDownload];
    }
}

- (void)removeTaskForKey:(NSString *)key
{   [self.lock lock];
    [self.taskDict removeObjectForKey:key];
    [self.lock unlock];
}

- (NSURLSessionDownloadTask *)taskForKey:(NSString *)key
{
    NSURLSessionDownloadTask *task = nil;
    [self.lock lock];
    task = [self.taskDict objectForKey:key];
    [self.lock unlock];
    return task;
}

- (void)addTask:(NSURLSessionTask *)task ForKey:(NSString *)key
{
    [self.lock lock];
    [self.taskDict setObject:task forKey:key];
    [self.lock unlock];

}


//自定义的下载类
//- (void)beginDownloadFileWithFileModel:(FileModel *)file
//{
//    //获取文件缓存信息
//    NSLog(@"22222222");
//
//    NSURLSessionDownloadTask *task = nil;
//     __weak typeof(self) weak = self;
//    if (file.resumeData.length > 0 && file.tempPath.length > 0) {
//
//        NSData *resumData = [file.resumeData dataUsingEncoding:NSUTF8StringEncoding];
//
//        //移动缓存文件到tmp目录，进行断点下载,此处不能用file的属性传入缓存路径名，程序第一次运行的时候目录不存在，会出现错误
//        NSError *error ;
//        [[NSFileManager defaultManager] moveItemAtPath:[[[FileManageShare fileManageShare] miaocaiRootTempCache] stringByAppendingPathComponent:file.tempFileName] toPath:[RootTemp stringByAppendingPathComponent:file.tempFileName] error:&error];
//        task = [[ZBSessionDownloadManager ZBSessionDownloadManager] downloadTaskWithResumedata:resumData progressBlock:^(NSProgress *progress) {
//            [weak addDownloadProgressWithProgress:progress file:file];
//        } destinationBlock:^NSURL *(NSURL *delegateLocation, NSURLResponse *downloadTask) {
//
//            return [weak addDownloadDestinationBlockWithLocation:delegateLocation downloadTask:downloadTask file:file];
//
//        } completeHandler:^(NSURLResponse *downloadTask, NSError *delegateError) {
//
//            [weak addCompleteHandlerWithDownloadTask:downloadTask error:delegateError file:file];
//
//        }];
//
//
//    } else {
//        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:file.fileUrl parameters:nil error:nil];
//        task = [[ZBSessionDownloadManager ZBSessionDownloadManager] downloadTaskWithRequest:[request copy] progressBlock:^(NSProgress *progress) {
//
//            [weak addDownloadProgressWithProgress:progress file:file];
//
//        } destinationBlock:^NSURL *(NSURL *delegateLocation, NSURLResponse *downloadTask) {
//
//             return [weak addDownloadDestinationBlockWithLocation:delegateLocation downloadTask:downloadTask file:file];
//
//        } completeHandler:^(NSURLResponse *downloadTask, NSError *delegateError) {
//
//             [weak addCompleteHandlerWithDownloadTask:downloadTask error:delegateError file:file];
//
//        }];
//
//
//
//    }
//
//
//    //创建下载任务
//    if (task) {
//
//        [self addTask:task ForKey:file.fileUrl];
//        [task resume];
//    }
//
//}


//结束
- (NSData *)reCreateResumeDataWithRequest:(NSURLRequest *)request tmfileName:(NSString *)tmfileName tmFilePath:(NSString *)tmFilePath
{
    NSMutableDictionary *resumeDataDict = [NSMutableDictionary dictionary];
    
    NSMutableURLRequest *newResumeRequest = [request mutableCopy];
    NSData *tmData = [NSData dataWithContentsOfFile:tmFilePath];
    
    [newResumeRequest addValue:[NSString stringWithFormat:@"bytes=%ld-",tmData.length] forHTTPHeaderField:@"Range"];
    [resumeDataDict setObject:request.URL.absoluteString forKey:@"NSURLSessionDownloadURL"];
    NSData *newResumeRequestData = [NSKeyedArchiver archivedDataWithRootObject:newResumeRequest];[resumeDataDict setObject:[NSNumber numberWithInteger:tmData.length] forKey:@"NSURLSessionResumeBytesReceived"];
    [resumeDataDict setObject:newResumeRequestData forKey:@"NSURLSessionResumeCurrentRequest"];
    [resumeDataDict setObject:@(2) forKey:@"NSURLSessionResumeInfoVersion"];
    [resumeDataDict setObject:newResumeRequestData forKey:@"NSURLSessionResumeOriginalRequest"];[resumeDataDict setObject:[tmfileName lastPathComponent]forKey:@"NSURLSessionResumeInfoTempFileName"];
    return [NSPropertyListSerialization dataWithPropertyList:resumeDataDict format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
}


@end
