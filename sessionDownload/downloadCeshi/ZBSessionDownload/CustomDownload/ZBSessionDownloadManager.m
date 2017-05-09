//
//  ZBSessionDownloadManager.m
//  downloadCeshi
//
//  Created by mac  on 17/5/8.
//  Copyright © 2017年 瞄财网. All rights reserved.
//

#import "ZBSessionDownloadManager.h"
#import "SessionDownloadDelegate.h"

@interface ZBSessionDownloadManager ()

@property (nonatomic, strong) NSOperationQueue *dowque;
@property (nonatomic, strong) NSURLSession *backSession;

@property (nonatomic, strong) NSMutableDictionary *delgateForTaskDict;
@property (readwrite, nonatomic, strong) NSLock *lock;



@end

@implementation ZBSessionDownloadManager

static ZBSessionDownloadManager *_instance;

+ (id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone
{
    return _instance;
}


+ (instancetype)ZBSessionDownloadManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _instance = [[ZBSessionDownloadManager alloc] init];
        
    });
    return _instance;
}



- (NSURLSession *)backgroundURLSession {
    NSString *identifier = @"com.yourcompany.appId.BackgroundSession";
        //session在每次重建时，会检查有没有没做完的任务，如果有session就会继续未完成的任务，这样很可能导致程序崩溃（在这个后台session里，每次意外退出app以后，再次重新创建后台session，都会默认开启上次崩溃前未执行完的任务，所以需要一个第三方的中介来对应一个任务
        NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
    _backSession = [NSURLSession sessionWithConfiguration:sessionConfig
                                                delegate:self
                                           delegateQueue:_dowque];
    
    return _backSession;
}

- (instancetype)init
{
    if (self = [super init]) {
        _dowque = [[NSOperationQueue alloc] init];
        _dowque.maxConcurrentOperationCount = 1;
        _backSession = [self backgroundURLSession];
        _delgateForTaskDict = [NSMutableDictionary dictionary];
        
        _lock = [[NSLock alloc] init];
        _lock.name = @"ZBHTTPSessionShareCustomDelegate";

    }
    return self;
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



- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request progressBlock:(void (^)(NSProgress *progress))progressBlock destinationBlock:(NSURL *(^)(NSURL *delegateLocation, NSURLResponse *downloadTask))destinationBlock completeHandler:(void(^)(NSURLResponse *downloadTask, NSError *delegateError))compleHandler
{
    
    NSURLSessionDownloadTask *task = [self.backSession downloadTaskWithRequest:request];
    [self addDelegateForDownloadTask:task progressBlock:progressBlock destinationBlock:destinationBlock completedBlock:compleHandler];
    
    return task;
}

- (NSURLSessionDownloadTask *)downloadTaskWithResumedata:(NSData *)resumedata progressBlock:(void (^)(NSProgress *progress))progressBlock destinationBlock:(NSURL *(^)(NSURL *delegateLocation, NSURLResponse *downloadTask))destinationBlock completeHandler:(void(^)(NSURLResponse *downloadTask, NSError *delegateError))compleHandler
{
    NSURLSessionDownloadTask *task = [self.backSession downloadTaskWithResumeData:resumedata];
    
    [self addDelegateForDownloadTask:task progressBlock:progressBlock destinationBlock:destinationBlock completedBlock:compleHandler];
    return task;
}

- (void)addDelegateForDownloadTask:(NSURLSessionDownloadTask *)downloadTask progressBlock:(void(^)(NSProgress *progress))progressBlock destinationBlock:(NSURL *(^)(NSURL *delegateLocation,  NSURLResponse *downloadTask))destinationBlock completedBlock:(void(^)(NSURLResponse *downloadTask, NSError *delegateError))completedBlock
{
    SessionDownloadDelegate *delegate = [[SessionDownloadDelegate alloc] init];
    [self setDelegate:delegate forTask:downloadTask];
    delegate.downloadProgressBlock = progressBlock;
    delegate.destination = destinationBlock;
    delegate.completionHandler = completedBlock;
    
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


@end
