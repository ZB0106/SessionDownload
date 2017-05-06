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
#import "ZBProgress.h"
#import "NSString+Common.h"
#import "C_common.h"
#import "SessionDownloadDelegate.h"

@interface HTTPSessionShare ()<NSURLSessionDelegate,NSURLSessionDownloadDelegate>

//@property (nonatomic, strong) NSMutableArray *fileList;
@property (nonatomic, strong) NSOperationQueue *dowque;
@property (nonatomic, strong) NSURLSession *backSession;
@property (nonatomic, strong) NSMutableDictionary *taskDict;
@property (nonatomic, strong) NSMutableDictionary *delgateForTaskDict;
@property (readwrite, nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) NSMutableArray *temDowningList;
//@property (nonatomic, strong) NSURLSessionDownloadTask *backDownTask;
@property (nonatomic, strong) NSTimer *timer;



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
- (NSURLSession *)backgroundURLSession {
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *identifier = @"com.yourcompany.appId.BackgroundSession";
        //session在每次重建时，会检查有没有没做完的任务，如果有session就会继续未完成的任务，这样很可能导致程序崩溃（在这个后台session里，每次意外退出app以后，再次重新创建后台session，都会默认开启上次崩溃前未执行完的任务，所以需要一个第三方的中介来对应一个任务
        NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
        session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                delegate:self
                                           delegateQueue:_dowque];
    });
    
    return session;
}



- (instancetype)init
{
    if (self) {
        self = [super init];
        
        
        //注册通知处理异常情况
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionDownloadAplicationWillTerminate) name:MCAplicationWillTerminate object:nil];
        
        
//        _fileList = [NSMutableArray array];
        
        _dowque = [[NSOperationQueue alloc] init];
        _dowque.maxConcurrentOperationCount = 1;
        _backSession = [self backgroundURLSession];
        
        _taskDict = [NSMutableDictionary dictionary];
        _delgateForTaskDict = [NSMutableDictionary dictionary];
       
        _temDowningList = [NSMutableArray array];
        _maxCount = 3;
        _downloadingList = [NSMutableArray array];
        _diskFileList = [NSMutableArray array];
        [_diskFileList addObjectsFromArray:[FileModelDbManager getAllDownloadedFile]];
        [_downloadingList addObjectsFromArray:[FileModelDbManager getAllNotCompletedFile]];
        
        ////session在每次重建时，会检查有没有没做完的任务，如果有session就会继续未完成的任务，这样很可能导致程序崩溃（在这个后台session里，每次意外退出app以后，再次重新创建后台session，都会默认开启上次崩溃前未执行完的任务，所以需要一个第三方的中介来对应一个任务,并且有次数限制
        //以下代码辅助处理异常退出的情况
        [_backSession getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
            
            for (NSURLSessionDownloadTask *task in downloadTasks) {
                NSLog(@"%zd",task.state);
                NSURLSessionDownloadTask *downTask = (NSURLSessionDownloadTask *)task;
                [self addDelegateForDownloadTask:downTask progressBlock:nil destinationBlock:nil completedBlock:nil];
                
                [downTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                    
                    [self handleResumeData:resumeData file:nil];
                    
                    
                }];
            }
        }];

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
        task = [self downloadTaskWithResumedata:resumData file:file progressBlock:^(ZBProgress *progress) {
            [weak addDownloadProgressWithProgress:progress file:file];
        } destinationBlock:^NSURL *(NSURL *delegateLocation, NSURLSessionDownloadTask *downloadTask) {
            
            return [weak addDownloadDestinationBlockWithLocation:delegateLocation downloadTask:downloadTask file:file];
            
        } completeHandler:^(NSURLSessionDownloadTask *downloadTask, NSError *delegateError) {
            
            [weak addCompleteHandlerWithDownloadTask:downloadTask error:delegateError file:file];
            
        }];
        
        
    } else {
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:file.fileUrl parameters:nil error:nil];
        task = [self downloadTaskWithRequest:[request copy] file:file progressBlock:^(ZBProgress *progress) {
            
            [weak addDownloadProgressWithProgress:progress file:file];
            
        } destinationBlock:^NSURL *(NSURL *delegateLocation, NSURLSessionDownloadTask *downloadTask) {
            
             return [weak addDownloadDestinationBlockWithLocation:delegateLocation downloadTask:downloadTask file:file];
            
        } completeHandler:^(NSURLSessionDownloadTask *downloadTask, NSError *delegateError) {
            
             [weak addCompleteHandlerWithDownloadTask:downloadTask error:delegateError file:file];
            
        }];
        
       
       
    }
    
   
    //创建下载任务
    if (task) {

        [self.taskDict setObject:task forKey:file.fileUrl];
        [task resume];
    }

}

- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request file:(FileModel *)file progressBlock:(void (^)(ZBProgress *progress))progressBlock destinationBlock:(NSURL *(^)(NSURL *delegateLocation, NSURLSessionDownloadTask *downloadTask))destinationBlock completeHandler:(void(^)(NSURLSessionDownloadTask *downloadTask, NSError *delegateError))compleHandler
{
    
    NSURLSessionDownloadTask *task = [self.backSession downloadTaskWithRequest:request];
    [self addDelegateForDownloadTask:task progressBlock:progressBlock destinationBlock:destinationBlock completedBlock:compleHandler];

    return task;
}

- (NSURLSessionDownloadTask *)downloadTaskWithResumedata:(NSData *)resumedata file:(FileModel *)file progressBlock:(void (^)(ZBProgress *progress))progressBlock destinationBlock:(NSURL *(^)(NSURL *delegateLocation, NSURLSessionDownloadTask *downloadTask))destinationBlock completeHandler:(void(^)(NSURLSessionDownloadTask *downloadTask, NSError *delegateError))compleHandler
{
    NSURLSessionDownloadTask *task = [self.backSession downloadTaskWithResumeData:resumedata];
    
    [self addDelegateForDownloadTask:task progressBlock:progressBlock destinationBlock:destinationBlock completedBlock:compleHandler];
    return task;
}

- (void)addDelegateForDownloadTask:(NSURLSessionDownloadTask *)downloadTask progressBlock:(void(^)(ZBProgress *progress))progressBlock destinationBlock:(NSURL *(^)(NSURL *delegateLocation,  NSURLSessionDownloadTask *downloadTask))destinationBlock completedBlock:(void(^)(NSURLSessionDownloadTask *downloadTask, NSError *delegateError))completedBlock
{
    SessionDownloadDelegate *delegate = [[SessionDownloadDelegate alloc] init];
    [self setDelegate:delegate forTask:downloadTask];
    delegate.downloadProgressBlock = progressBlock;
    delegate.destination = destinationBlock;
    delegate.completionHandler = completedBlock;
   
}

- (void)removeDelegateForTask:(NSURLSessionTask *)task {
    NSParameterAssert(task);
    
    [self.lock lock];
    [self.delgateForTaskDict removeObjectForKey:@(task.taskIdentifier)];
    [self.lock unlock];
}

- (SessionDownloadDelegate *)delegateForTask:(NSURLSessionTask *)task {
    NSParameterAssert(task);
    
    SessionDownloadDelegate *delegate = nil;
    [self.lock lock];
    delegate = self.delgateForTaskDict[@(task.taskIdentifier)];
    [self.lock unlock];
    
    return delegate;
}

- (void)setDelegate:(SessionDownloadDelegate *)delegate
            forTask:(NSURLSessionTask *)task
{
    NSParameterAssert(task);
    NSParameterAssert(delegate);
    
    [self.lock lock];
    self.delgateForTaskDict[@(task.taskIdentifier)] = delegate;
    
    [self.lock unlock];
}


- (void)addDownloadProgressWithProgress:(ZBProgress *)progress file:(FileModel *)file
{
        file.fileReceivedSize = [NSString stringWithFormat:@"%zd",progress.completedUnitCount];
       file.fileSize = [NSString stringWithFormat:@"%zd",progress.totalUnitCount];
        file.fileDownSpeed = [[NSString getFileSizeString:progress.downSpeed] stringByAppendingString:@"/s"];
    if ([self.sessionDelegate respondsToSelector:@selector(updateProgressWithFlModel:)] && self.sessionDelegate) {
        [self.sessionDelegate updateProgressWithFlModel:file];
    }

}
- (NSURL *)addDownloadDestinationBlockWithLocation:(NSURL *)location downloadTask:(NSURLSessionDownloadTask *)downloadTask file:(FileModel *)file
{
    SessionDownloadDelegate *delgate = [self delegateForTask:downloadTask];
    if (delgate) {
        NSURL *destPath = [NSURL fileURLWithPath:[RootCache stringByAppendingPathComponent:downloadTask.response.suggestedFilename]];
        [[NSFileManager defaultManager] moveItemAtURL:location toURL:destPath error:nil];
        file.filePath = location.path;
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
        return nil;
}

- (void)addCompleteHandlerWithDownloadTask:(NSURLSessionDownloadTask *)downloadTask error:(NSError *)error file:(FileModel *)file
{
    SessionDownloadDelegate *delgate = [self delegateForTask:downloadTask];
    if (delgate) {
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
    
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
//    self.progress.totalUnitCount = totalBytesExpectedToWrite;
//    self.progress.completedUnitCount = totalBytesWritten;
    
    SessionDownloadDelegate *delegate = [self delegateForTask:downloadTask];
    if (delegate) {
        [delegate URLSession:session downloadTask:downloadTask didWriteData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }

}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
   SessionDownloadDelegate *delegate = [self delegateForTask:downloadTask];
    if (delegate) {
        [delegate URLSession:session downloadTask:downloadTask didResumeAtOffset:fileOffset expectedTotalBytes:expectedTotalBytes];
        
    }
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    SessionDownloadDelegate *delegate = [self delegateForTask:downloadTask];
    if (delegate) {
        [delegate URLSession:session downloadTask:downloadTask didFinishDownloadingToURL:location];
    }
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    SessionDownloadDelegate *delegate = [self delegateForTask:task];
    if (delegate) {
        [delegate URLSession:session task:task didCompleteWithError:error];
        [self removeDelegateForTask:task];
    }
    
    
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
    
    [_backSession getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
        
        for (NSURLSessionDownloadTask *task in downloadTasks) {
            NSLog(@"%zd",task.state);
            NSURLSessionDownloadTask *downTask = (NSURLSessionDownloadTask *)task;
            [self addDelegateForDownloadTask:downTask progressBlock:nil destinationBlock:nil completedBlock:nil];
            
            [downTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                
                NSString *str = task.originalRequest.URL.absoluteString;
                FileModel *file = [FileModelDbManager getFileModeWithFilUrl:str];
                [self handleResumeData:resumeData file:file];
                
            }];
        }
    }];

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
