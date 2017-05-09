//
//  ZBSessionDownloadManager.h
//  downloadCeshi
//
//  Created by mac  on 17/5/8.
//  Copyright © 2017年 瞄财网. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZBSessionDownloadManager : NSObject<NSURLSessionDelegate,NSURLSessionDownloadDelegate>

+ (instancetype)ZBSessionDownloadManager;

- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request progressBlock:(void (^)(NSProgress *progress))progressBlock destinationBlock:(NSURL *(^)(NSURL *delegateLocation, NSURLResponse *NSURLResponse))destinationBlock completeHandler:(void(^)(NSURLResponse *downloadTask, NSError *delegateError))compleHandler;

- (NSURLSessionDownloadTask *)downloadTaskWithResumedata:(NSData *)resumedata progressBlock:(void (^)(NSProgress *progress))progressBlock destinationBlock:(NSURL *(^)(NSURL *delegateLocation, NSURLResponse *NSURLResponse))destinationBlock completeHandler:(void(^)(NSURLResponse *NSURLResponse, NSError *delegateError))compleHandler;

@end
