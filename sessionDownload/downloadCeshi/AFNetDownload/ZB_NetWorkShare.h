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


@property (nonatomic, strong, readonly) AFHTTPSessionManager *backSessionManager;
@property (nonatomic, strong, readonly) AFNetworkReachabilityManager *reachManager;

+ (instancetype)ZB_NetWorkShare;

- (NSURLSessionDownloadTask *)downloadTaskWithUrlStr:(NSString *)urlStr
                                                progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                             destination:(nullable NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                       completionHandler:(nullable void (^)(NSURLResponse *response, NSURL * _Nullable filePath, NSError * _Nullable error))completionHandler;

/**
 Creates an `NSURLSessionDownloadTask` with the specified resume data.
 
 @param resumeData The data used to resume downloading.
 @param downloadProgressBlock A block object to be executed when the download progress is updated. Note this block is called on the session queue, not the main queue.
 @param destination A block object to be executed in order to determine the destination of the downloaded file. This block takes two arguments, the target path & the server response, and returns the desired file URL of the resulting download. The temporary file used during the download will be automatically deleted after being moved to the returned URL.
 @param completionHandler A block to be executed when a task finishes. This block has no return value and takes three arguments: the server response, the path of the downloaded file, and the error describing the network or parsing error that occurred, if any.
 */
- (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)resumeData
                                                progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                             destination:(nullable NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                       completionHandler:(nullable void (^)(NSURLResponse *response, NSURL * _Nullable filePath, NSError * _Nullable error))completionHandler;


@end
