//
//  ZB_NetWorkShare.m
//  downloadCeshi
//
//  Created by mac  on 17/5/8.
//  Copyright © 2017年 瞄财网. All rights reserved.
//

#import "ZB_NetWorkShare.h"


@interface ZB_NetWorkShare ()

@property (nonatomic, strong) AFHTTPSessionManager *backSessionManager;
@property (nonatomic, strong) AFNetworkReachabilityManager *reachManager;

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
        
        NSString *identifier = @"com.yourcompany.appId.BackgroundSession";
        //session在每次重建时，会检查有没有没做完的任务，如果有session就会继续未完成的任务，这样很可能导致程序崩溃（在这个后台session里，每次意外退出app以后，再次重新创建后台session，都会默认开启上次崩溃前未执行完的任务，所以需要一个第三方的中介来对应一个任务
        NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
        //后台任务session
        _backSessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:sessionConfig];
        
        //网络监听
        _reachManager = [AFNetworkReachabilityManager manager];
        
        //设置全局的baseUrl
        
    }
    return self;
}

- (void)startMonitoring
{
    
    [_reachManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"%zd",status);
    }];
    
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [_reachManager startMonitoring];
    });
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

    return [self.backSessionManager downloadTaskWithRequest:request progress:downloadProgressBlock destination:destination completionHandler:completionHandler];
}

- (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)resumeData
                                                progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                             destination:(nullable NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                       completionHandler:(nullable void (^)(NSURLResponse *response, NSURL * _Nullable filePath, NSError * _Nullable error))completionHandler
{
    return [self.backSessionManager downloadTaskWithResumeData:resumeData progress:downloadProgressBlock destination:destination completionHandler:completionHandler];
}


@end
