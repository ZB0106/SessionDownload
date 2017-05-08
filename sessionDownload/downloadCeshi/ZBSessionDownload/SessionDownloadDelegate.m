////
////  SessionDownloadDelegate.m
////  downloadCeshi
////
////  Created by 瞄财网 on 17/3/25.
////  Copyright © 2017年 瞄财网. All rights reserved.
////
//
#import "SessionDownloadDelegate.h"
#import "NSProgress+downSpeed.h"

@interface SessionDownloadDelegate ()

@property (nonatomic, strong) NSProgress *progress;
@property (nonatomic ,strong) NSURL *destPath;
//记录上一秒已经下载的数据的长度
@property (nonatomic, assign) int64_t preCompleteBytes;
@property (nonatomic, strong) NSTimer *timer;


@end

@implementation SessionDownloadDelegate

- (instancetype)initWithTask:(NSURLSessionDownloadTask *)task
{
    self = [super init];
    if (self) {
        _progress = [[NSProgress alloc] init];
        _preCompleteBytes = 0;
        [self fire];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _progress = [[NSProgress alloc] init];
        _preCompleteBytes = 0;
        [self fire];
    }
    return self;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    self.progress.completedUnitCount = totalBytesWritten;
    self.progress.totalUnitCount = totalBytesExpectedToWrite;
    
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    self.progress.completedUnitCount = fileOffset;
    self.progress.totalUnitCount = expectedTotalBytes;
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    //下载完成时需调用一下，协调定时器更好的工作
    if (self.downloadProgressBlock) {
        self.downloadProgressBlock(self.progress);
    }

    if (self.destination) {
        self.destPath = self.destination(location,downloadTask.response);
        
        if (self.destPath) {
            NSError *fileManagerError = nil;
            
            [[NSFileManager defaultManager] moveItemAtURL:location toURL:self.destPath error:&fileManagerError];
        }
    }
   
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (self.completionHandler) {
        self.completionHandler(task.response,error);
    }
    [self cancelTimer];
}

- (void)fire
{
    _timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    [_timer fire];

}
- (void)cancelTimer
{
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
}


- (void)dealloc
{
    NSLog(@"delegate");
    [self cancelTimer];
}

//实时更新下载任务进度
- (void)updateProgress
{
    self.progress.zb_downSpeed = self.progress.completedUnitCount - self.preCompleteBytes;
   
    self.preCompleteBytes = self.progress.completedUnitCount;
    if (self.downloadProgressBlock) {
        self.downloadProgressBlock(self.progress);
    }
}

////重置下载进度的值
//self.progress.totalUnitCount = 0;
//self.progress.completedUnitCount = 0;
//self.progress.downSpeed = 0;
//self.preCompleteBytes = 0;

@end
