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

@interface ZB_NetWorkShare : NSObject

@property (nonatomic, strong, readonly) AFHTTPSessionManager * _Nullable backSessionManager;
@property (nonatomic, strong, readonly) AFNetworkReachabilityManager * _Nullable reachManager;

+ (instancetype _Nullable )ZB_NetWorkShare;

- (NSURLSessionDownloadTask *_Nullable)downloadTaskWithUrlStr:(NSString *_Nullable)urlStr
                                                progress:(nullable void (^)(NSProgress * _Nullable downloadProgress))downloadProgressBlock
                                             destination:(nullable NSURL * _Nullable (^)(NSURL * _Nullable targetPath, NSURLResponse * _Nullable response))destination
                                       completionHandler:(nullable void (^)(NSURLResponse * _Nullable response, NSURL *_Nullable filePath, NSError * _Nullable error))completionHandler;


- (NSURLSessionDownloadTask *_Nullable)downloadTaskWithResumeData:(NSData *_Nullable)resumeData
                                                progress:(nullable void (^)(NSProgress * _Nullable downloadProgress))downloadProgressBlock
                                             destination:(nullable NSURL * _Nullable (^)(NSURL * _Nullable targetPath, NSURLResponse * _Nullable response))destination
                                       completionHandler:(nullable void (^)(NSURLResponse * _Nullable response, NSURL * _Nullable filePath, NSError * _Nullable error))completionHandler;


@end
