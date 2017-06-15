//
//  ZB_NetWorkShare.m
//  downloadCeshi
//
//  Created by mac  on 17/5/8.
//  Copyright © 2017年 瞄财网. All rights reserved.
//

#import "ZB_NetWorkShare.h"
#import "NSProgress+downSpeed.h"

@interface ZB_NetWorkShare ()

@property (nonatomic, strong) AFHTTPSessionManager *backSessionManager;
@property (nonatomic, strong) NSMutableDictionary *completionHandlerDictionary;

@end

@implementation ZB_NetWorkShare


static ZB_NetWorkShare *_instance;

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


+ (instancetype)ZB_NetWorkShare
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _instance = [[ZB_NetWorkShare alloc] init];
        
    });
    return _instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        //普通session
        
        NSString *identifier = @"com.miaocaiwang.downloadceshi.BackgroundSession";
        //session在每次重建时，会检查有没有没做完的任务，如果有session就会继续未完成的任务，这样很可能导致程序崩溃（在这个后台session里，每次意外退出app以后，再次重新创建后台session，都会默认开启上次崩溃前未执行完的任务，所以需要一个第三方的中介来对应一个任务
//        NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
        NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        //后台任务session
        _backSessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:sessionConfig];
        __weak typeof(self) weak = self;
        [_backSessionManager setDidFinishEventsForBackgroundURLSessionBlock:^(NSURLSession * _Nonnull session) {
            NSLog(@"Background URL session %@ finished events.\n", session);
            if (session.configuration.identifier) {
                // 调用在 -application:handleEventsForBackgroundURLSession: 中保存的 handler
                __strong typeof(weak) strongSelf = weak;
                [strongSelf callCompletionHandlerForSession:session.configuration.identifier];
            }
        }];

        [self startMonitoring];
        
        //设置全局的baseUrl
        
    }
    return self;
}

- (void)callCompletionHandlerForSession:(NSString *)identifier {
    
    if ([self.backSessionCompletionDelegate respondsToSelector:@selector(backSessionDidCompletionWithSession:)]) {
        [self.backSessionCompletionDelegate backSessionDidCompletionWithSession:identifier];
    }
    void (^completionHandler)() = [self.completionHandlerDictionary objectForKey: identifier];
    if (completionHandler) {
        [self.completionHandlerDictionary removeObjectForKey: identifier];
        
        completionHandler();
    }
}

//后台任务处理
- (void)addCompletionHandle:(void (^)())completionHandler forSession:(NSString *)identifier
{
    if (![self.completionHandlerDictionary objectForKey:identifier]) {
        [self.completionHandlerDictionary setObject:completionHandler forKey:identifier];
    }
}


- (void)startMonitoring
{
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [_backSessionManager.reachabilityManager startMonitoring];
    });
}

- (void)checkNetWorking
{
    [_reachManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"%zd",status);
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWiFi:
                
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                
                break;
            case AFNetworkReachabilityStatusNotReachable:
                
                break;
            default:
                
                break;
        }
        
    }];

}

- (NSURLSessionDownloadTask *)downloadTaskWithUrlStr:(NSString *)urlStr
                                             progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                          destination:(nullable NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                    completionHandler:(nullable void (^)(NSURLResponse *response, NSURL * _Nullable filePath, NSError * _Nullable error))completionHandler
{
    
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.backSessionManager.requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:urlStr relativeToURL:nil] absoluteString] parameters:nil error:&serializationError];
    if (serializationError) {
        if (completionHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(nil,nil,serializationError);
            });
        }
        
        return nil;
    }
    __weak typeof(self) weakSelf = self;
    return [self.backSessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf updateProgress:downloadProgress downloadBlock:downloadProgressBlock];
        
    } destination:destination completionHandler:completionHandler];
}

- (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)resumeData
                                                progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                             destination:(nullable NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                       completionHandler:(nullable void (^)(NSURLResponse *response, NSURL * _Nullable filePath, NSError * _Nullable error))completionHandler
{
    
    __weak typeof(self) weakSelf = self;
    return [self.backSessionManager downloadTaskWithResumeData:resumeData progress:^(NSProgress * _Nonnull downloadProgress) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf updateProgress:downloadProgress downloadBlock:downloadProgressBlock];
        
    } destination:destination completionHandler:completionHandler];
}

- (void)updateProgress:(NSProgress *)downloadProgress downloadBlock:(void (^)(NSProgress *))downloadProgressBlock
{
    if (!downloadProgress.zb_startDate) {
        downloadProgress.zb_startDate = [NSDate date];
        downloadProgress.zb_preBytes = downloadProgress.completedUnitCount;
    }
    NSDate *cur = [NSDate date];
    NSTimeInterval time = [cur timeIntervalSinceDate:downloadProgress.zb_startDate];
    if (time >= 1.0) {
        
        downloadProgress.zb_downSpeed = (downloadProgress.completedUnitCount - downloadProgress.zb_preBytes) / time;
        
        downloadProgress.zb_startDate = cur;
        downloadProgress.zb_preBytes = downloadProgress.completedUnitCount;
        
        if (downloadProgressBlock) {
            downloadProgressBlock(downloadProgress);
        }
    }
}


@end
