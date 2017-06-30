//
//  NSObject+ZB_File.h
//  downloadCeshi
//
//  Created by 瞄财网 on 2017/6/30.
//  Copyright © 2017年 瞄财网. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ZB_File)

typedef enum {
    FileStopDownload = 0, //停止下载(停止下载放在上面，便于排序)
    FileWillDownload,     //等待下载
    FileDownloading,      //下载中
    FileDownloaded          //已下载
}DownloadState;

@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *fileUrl;
@property (nonatomic, copy) NSString *fileSize;
@property (nonatomic, assign) DownloadState fileState;
@property (nonatomic, copy) NSString *fileReceivedSize;
@property (nonatomic, copy) NSString *fileDownSpeed;
@property (nonatomic, copy) NSString *fileDownedTime;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *MD5;
@property (nonatomic, copy) NSString *tempFileName;
@property (nonatomic, copy) NSString *resumeData;
@property (nonatomic, copy) NSString *tempPath;


@end
