//
//  SessionDownloadDelegate.h
//  downloadCeshi
//
//  Created by 瞄财网 on 17/3/25.
//  Copyright © 2017年 瞄财网. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SessionDownloadDelegate : NSObject

- (instancetype)initWithTask:(NSURLSessionDownloadTask *)task;

@property (nonatomic, copy) void (^downloadProgressBlock)(NSProgress *progress);
@property (nonatomic, copy) NSURL *(^destination)(NSURL *location, NSURLResponse *downloadTask);
@property (nonatomic, copy) void (^completionHandler)(NSURLResponse *downloadTask, NSError *error);

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location;

/* Sent periodically to notify the delegate of download progress. */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;

/* Sent when a download has been resumed. If a download failed with an
 * error, the -userInfo dictionary of the error will contain an
 * NSURLSessionDownloadTaskResumeData key, whose value is the resume
 * data.
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes;

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error;


@end
