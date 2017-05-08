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

@interface HTTPSessionShare ()


@property (readwrite, nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) NSMutableDictionary *taskDict;

//@property (nonatomic, strong) NSMutableArray *fileList;
@property (nonatomic, strong) NSMutableArray *temDowningList;
//@property (nonatomic, strong) NSURLSessionDownloadTask *backDownTask;
@property (nonatomic, strong) NSTimer *timer;


//存储正在下载的文件模型
@property (nonatomic, strong) NSMutableArray *downloadingList;
//存储现在暂停中的文件模型
//@property (nonatomic, strong) NSMutableArray *stopDownloadList;
//存储磁盘缓存的文件
@property (nonatomic, strong) NSMutableArray *diskFileList;

@end

@implementation HTTPSessionShare

static NSString *const temFileNameString = @"CFNetworkDownload";
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionDownloadAplicationWillTerminate) name:MCAplicationWillTerminate object:nil];
        
        
//        _fileList = [NSMutableArray array];
        
        _taskDict = [NSMutableDictionary dictionary];
        _temDowningList = [NSMutableArray array];
        _maxCount = 3;
        _downloadingList = [NSMutableArray array];
        _diskFileList = [NSMutableArray array];
//        _stopDownloadList = [NSMutableArray array];
        //更新文件状态，防止重新运行程序时，上次未下载完成的任务可能会开始下载
        [FileModelDbManager updateUnFinishedFileState];
        [_diskFileList addObjectsFromArray:[FileModelDbManager getAllDownloadedFile]];
        [_downloadingList addObjectsFromArray:[FileModelDbManager getAllNotCompletedFile]];
        
        ////session在每次重建时，会检查有没有没做完的任务，如果有session就会继续未完成的任务，这样很可能导致程序崩溃（在这个后台session里，每次意外退出app以后，再次重新创建后台session，都会默认开启上次崩溃前未执行完的任务，所以需要一个第三方的中介来对应一个任务,并且有次数限制
        //以下代码辅助处理异常退出的情况
        

//        [_backSession getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
//            
//            for (NSURLSessionDownloadTask *task in downloadTasks) {
//                NSLog(@"%zd",task.state);
//                NSURLSessionDownloadTask *downTask = (NSURLSessionDownloadTask *)task;
//                [self addDelegateForDownloadTask:downTask progressBlock:nil destinationBlock:nil completedBlock:nil];
//                
//                [downTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
//                    
//                    [self handleResumeData:resumeData file:nil];
//                    
//                    
//                }];
//            }
//        }];

    }
    return self;
}



- (void)downloadFileWithFileModel:(FileModel *)model
{
    if (model.fileUrl.length == 0) {
        return;
    }
    //判断文件是否已经存在
    FileModel *downFile = [FileModelDbManager getFileModeWithFilUrl:model.fileUrl];
    if (downFile) {
        if (downFile.fileState == FileDownloaded) {
            NSLog(@"文件已经下载");
            return;
        } else {
            NSLog(@"文件已经在下载列表中");
            return;
        }
    }
    [self.downloadingList addObject:model];
    [FileModelDbManager insertFile:model];
    [self startDownload];
}


- (void)downloadFileWithFileModelArray:(NSArray<FileModel*> *)modelArray
{
    for (FileModel *file in modelArray) {
        [self downloadFileWithFileModel:file];
    }
}
- (void)startDownload
{
    [self handleDowningFile];
    for (FileModel *file in self.downloadingList) {
        if (file.fileState == FileDownloading) {
            NSURLSessionTask *task = [_taskDict objectForKey:file.fileUrl];
            if (!task) {
                [self beginDownloadFileWithFileModel:file];
                
            }
        } else {
        
            NSURLSessionDownloadTask *task = [_taskDict objectForKey:file.fileUrl];
                if (task) {
                  [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                      
                  }];
            }
        }
    }
}

- (void)handleDowningFile
{
    [_temDowningList removeAllObjects];
    for (FileModel *file in self.downloadingList) {
        if (file.fileState == FileDownloading) {
            [_temDowningList addObject:file];
        }
        
    }
    if (_temDowningList.count < _maxCount) {
        for (FileModel *file in _downloadingList) {
            if (file.fileState == FileWillDownload) {
                file.fileState = FileDownloading;
                [_temDowningList addObject:file];
                if (_temDowningList.count >= _maxCount) {
                    break;
                }
            }
        }
        
    } else {
        [_temDowningList enumerateObjectsUsingBlock:^(FileModel *file, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx >= _maxCount) {
                file.fileState = FileWillDownload;
            }
        }];
        
    }

}

- (void)startAllTask
{
    for (FileModel *file in self.downloadingList) {
        if (file.fileState == FileStopDownload) {
            file.fileState = FileWillDownload;
            [self startDownload];
        }
    }

}
- (void)stopAllTask
{
    for (FileModel *file in self.downloadingList) {
        if (file.fileState == FileDownloading || file.fileState == FileWillDownload) {
            file.fileState = FileStopDownload;
            [self startDownload];
        }
    }

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
    
    [self.downloadingList removeObjectAtIndex:tmIdx];
    [self.downloadingList insertObject:file atIndex:0];

    [self startDownload];
}


- (void)AF_BeginDownloadFileWithFileModel:(FileModel *)file
{
    //获取文件缓存信息
    NSLog(@"22222222");
    NSURLSessionDownloadTask *task = nil;
    __weak typeof(self) weak = self;
    if (file.resumeData.length > 0 && file.tempPath.length > 0) {
        
        NSData *resumData = [file.resumeData dataUsingEncoding:NSUTF8StringEncoding];
        
        //移动缓存文件到tmp目录，进行断点下载,此处不能用file的属性传入缓存路径名，程序第一次运行的时候目录不存在，会出现错误
        NSError *error ;
        [[NSFileManager defaultManager] moveItemAtPath:[[[FileManageShare fileManageShare] miaocaiRootTempCache] stringByAppendingPathComponent:file.tempFileName] toPath:[RootTemp stringByAppendingPathComponent:file.tempFileName] error:&error];
        
        task = [[ZB_NetWorkShare ZB_NetWorkShare] downloadTaskWithResumeData:resumData progress:^(NSProgress *downloadProgress) {
            [weak addDownloadProgressWithProgress:downloadProgress file:file];
            
        } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            
            return [weak addDownloadDestinationBlockWithLocation:targetPath downloadTask:response file:file];

        } completionHandler:^(NSURLResponse *response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            [weak addCompleteHandlerWithDownloadTask:response error:error file:file];
        }];
        
        
    } else {
        task = [[ZB_NetWorkShare ZB_NetWorkShare] downloadTaskWithUrlStr:file.fileUrl progress:^(NSProgress *downloadProgress) {
             [weak addDownloadProgressWithProgress:downloadProgress file:file];
        } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            
            return [weak addDownloadDestinationBlockWithLocation:targetPath downloadTask:response file:file];
            
        } completionHandler:^(NSURLResponse *response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            [weak addCompleteHandlerWithDownloadTask:response error:error file:file];
        }];
    }
    //创建下载任务
    if (task) {
        
        [self.taskDict setObject:task forKey:file.fileUrl];
        [task resume];
    }

}

- (void)beginDownloadFileWithFileModel:(FileModel *)file
{
    //获取文件缓存信息
    NSLog(@"22222222");
    NSURLSessionDownloadTask *task = nil;
     __weak typeof(self) weak = self;
    if (file.resumeData.length > 0 && file.tempPath.length > 0) {
        
        NSData *resumData = [file.resumeData dataUsingEncoding:NSUTF8StringEncoding];
        
        //移动缓存文件到tmp目录，进行断点下载,此处不能用file的属性传入缓存路径名，程序第一次运行的时候目录不存在，会出现错误
        NSError *error ;
        [[NSFileManager defaultManager] moveItemAtPath:[[[FileManageShare fileManageShare] miaocaiRootTempCache] stringByAppendingPathComponent:file.tempFileName] toPath:[RootTemp stringByAppendingPathComponent:file.tempFileName] error:&error];
        task = [[ZBSessionDownloadManager ZBSessionDownloadManager] downloadTaskWithResumedata:resumData progressBlock:^(NSProgress *progress) {
            [weak addDownloadProgressWithProgress:progress file:file];
        } destinationBlock:^NSURL *(NSURL *delegateLocation, NSURLResponse *downloadTask) {
            
            return [weak addDownloadDestinationBlockWithLocation:delegateLocation downloadTask:downloadTask file:file];
            
        } completeHandler:^(NSURLResponse *downloadTask, NSError *delegateError) {
            
            [weak addCompleteHandlerWithDownloadTask:downloadTask error:delegateError file:file];
            
        }];
        
        
    } else {
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:file.fileUrl parameters:nil error:nil];
        task = [[ZBSessionDownloadManager ZBSessionDownloadManager] downloadTaskWithRequest:[request copy] progressBlock:^(NSProgress *progress) {
            
            [weak addDownloadProgressWithProgress:progress file:file];
            
        } destinationBlock:^NSURL *(NSURL *delegateLocation, NSURLResponse *downloadTask) {
            
             return [weak addDownloadDestinationBlockWithLocation:delegateLocation downloadTask:downloadTask file:file];
            
        } completeHandler:^(NSURLResponse *downloadTask, NSError *delegateError) {
            
             [weak addCompleteHandlerWithDownloadTask:downloadTask error:delegateError file:file];
            
        }];
        
       
       
    }
    
   
    //创建下载任务
    if (task) {

        [self.taskDict setObject:task forKey:file.fileUrl];
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
    NSURL *destPath = [NSURL fileURLWithPath:[RootCache stringByAppendingPathComponent:downloadTask.suggestedFilename]];
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:destPath error:nil];
    file.filePath = destPath.path;
    file.fileState = FileDownloaded;
    
    [self.downloadingList removeObject:file];
    [self.temDowningList removeObject:file];
    [self.diskFileList addObject:file];
    
    
    
    [FileModelDbManager updateFile:file];
    
    
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.sessionDelegate respondsToSelector:@selector(updateProgressWithFlModel:)] && self.sessionDelegate) {
            [self.sessionDelegate updateProgressWithFlModel:file];
        }
        
    });
    return destPath;
}

- (void)addCompleteHandlerWithDownloadTask:(NSURLResponse *)downloadTask error:(NSError *)error file:(FileModel *)file
{
    if (error) {
        NSLog(@"%@",error);
        NSData *data = error.userInfo[NSURLSessionDownloadTaskResumeData];
        [self handleResumeData:data file:file];
        
    }
    
    [_taskDict removeObjectForKey:file.fileUrl];
    [self startDownload];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.sessionDelegate respondsToSelector:@selector(updateTableViewWithFlModel:)] && self.sessionDelegate) {
            [self.sessionDelegate updateTableViewWithFlModel:file];
        }
        
    });
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
            file = [FileModelDbManager getFileModeWithFilUrl:tmdict[@"NSURLSessionDownloadURL"]];
        }
        if (file) {
            file.resumeData = [[NSString alloc] initWithData:resumeData encoding:NSUTF8StringEncoding];
            
            NSString *tmFileName = [NSString stringWithFormat:@"%@",[tmdict objectForKey:@"NSURLSessionResumeInfoTempFileName"]];
            file.tempFileName = tmFileName;
            file.tempPath = [[[FileManageShare fileManageShare] miaocaiRootTempCache] stringByAppendingPathComponent:file.tempFileName];
            NSError *error;
            [[NSFileManager defaultManager] moveItemAtPath:[RootTemp stringByAppendingPathComponent:file.tempFileName] toPath:file.tempPath error:&error];
        }
    }
    
    if (file) {
        file.fileState = FileStopDownload;
        [FileModelDbManager updateFile:file];
    }
}
- (void)sessionDownloadAplicationWillTerminate
{
    //程序意外退出时 保存断点信息
    
//    [_backSession getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
//        
//        for (NSURLSessionDownloadTask *task in downloadTasks) {
//            NSLog(@"%zd",task.state);
//            NSURLSessionDownloadTask *downTask = (NSURLSessionDownloadTask *)task;
//            [self addDelegateForDownloadTask:downTask progressBlock:nil destinationBlock:nil completedBlock:nil];
//            
//            [downTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
//                
//                NSString *str = task.originalRequest.URL.absoluteString;
//                FileModel *file = [FileModelDbManager getFileModeWithFilUrl:str];
//                [self handleResumeData:resumeData file:file];
//                
//            }];
//        }
//    }];

}



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
