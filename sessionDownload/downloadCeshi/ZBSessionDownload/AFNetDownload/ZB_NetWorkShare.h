//
//  ZB_NetWorkShare.h
//  downloadCeshi
//
//  Created by mac  on 17/5/8.
//  Copyright © 2017年 瞄财网. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "AFNetworkReachabilityManager.h"


@protocol ZB_NetWorkShareDelegate <NSObject>

- (void)backSessionDidCompletionWithSession:(NSString *)identifier;

@end

@interface ZB_NetWorkShare : NSObject

@property (nonatomic, strong, readonly) AFHTTPSessionManager * _Nullable backSessionManager;
@property (nonatomic, strong, readonly) AFNetworkReachabilityManager * _Nullable reachManager;
@property (nonatomic, weak) id <ZB_NetWorkShareDelegate> backSessionCompletionDelegate;

+ (instancetype _Nullable )ZB_NetWorkShare;
//后台任务处理
- (void)addCompletionHandle:(void (^_Nullable)())completionHandler forSession:(NSString *_Nullable)identifier;
- (NSURLSessionDownloadTask *_Nullable)downloadTaskWithUrlStr:(NSString *_Nullable)urlStr
                                                progress:(nullable void (^)(NSProgress * _Nullable downloadProgress))downloadProgressBlock
                                             destination:(nullable NSURL * _Nullable (^)(NSURL * _Nullable targetPath, NSURLResponse * _Nullable response))destination
                                       completionHandler:(nullable void (^)(NSURLResponse * _Nullable response, NSURL *_Nullable filePath, NSError * _Nullable error))completionHandler;


- (NSURLSessionDownloadTask *_Nullable)downloadTaskWithResumeData:(NSData *_Nullable)resumeData
                                                progress:(nullable void (^)(NSProgress * _Nullable downloadProgress))downloadProgressBlock
                                             destination:(nullable NSURL * _Nullable (^)(NSURL * _Nullable targetPath, NSURLResponse * _Nullable response))destination
                                       completionHandler:(nullable void (^)(NSURLResponse * _Nullable response, NSURL * _Nullable filePath, NSError * _Nullable error))completionHandler;


@end

