//
//  NSObject+ZB_File.m
//  downloadCeshi
//
//  Created by 瞄财网 on 2017/6/30.
//  Copyright © 2017年 瞄财网. All rights reserved.
//

#import "NSObject+ZB_File.h"
#import <objc/runtime.h>

@implementation NSObject (ZB_File)

- (void)setMD5:(NSString *)MD5
{
    objc_setAssociatedObject(self, @selector(MD5), MD5, OBJC_ASSOCIATION_COPY_NONATOMIC
                             );
}

- (NSString *)MD5
{
   return objc_getAssociatedObject(self, _cmd);
}
//@property (nonatomic, copy) NSString *fileName;
//@property (nonatomic, copy) NSString *fileUrl;

- (void)setFileName:(NSString *)fileName
{
    objc_setAssociatedObject(self, @selector(fileName), fileName, OBJC_ASSOCIATION_COPY_NONATOMIC
                             );
}

- (NSString *)fileName
{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setFileUrl:(NSString *)fileUrl
{
    objc_setAssociatedObject(self, @selector(fileUrl), fileUrl, OBJC_ASSOCIATION_COPY_NONATOMIC
                             );
}

- (NSString *)fileUrl
{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setFileSize:(NSString *)fileSize
{
    objc_setAssociatedObject(self, @selector(fileSize), fileSize, OBJC_ASSOCIATION_COPY_NONATOMIC
                             );
}

- (NSString *)fileSize
{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setFileState:(DownloadState)fileState
{
    objc_setAssociatedObject(self, @selector(fileState), @(fileState), OBJC_ASSOCIATION_ASSIGN
                             );
}

- (DownloadState)fileState
{
    return [objc_getAssociatedObject(self, _cmd) intValue];
}


- (void)setFileReceivedSize:(NSString *)fileReceivedSize
{
    objc_setAssociatedObject(self, @selector(fileReceivedSize), fileReceivedSize, OBJC_ASSOCIATION_COPY_NONATOMIC
                             );
}

- (NSString *)fileReceivedSize
{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setFileDownSpeed:(NSString *)fileDownSpeed
{
    objc_setAssociatedObject(self, @selector(fileDownSpeed), fileDownSpeed, OBJC_ASSOCIATION_COPY_NONATOMIC
                             );
}

- (NSString *)fileDownSpeed
{
    return objc_getAssociatedObject(self, _cmd);
}


- (void)setFileDownedTime:(NSString *)fileDownedTime
{
    objc_setAssociatedObject(self, @selector(fileDownedTime), fileDownedTime, OBJC_ASSOCIATION_COPY_NONATOMIC
                             );
}

- (NSString *)fileDownedTime
{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setFilePath:(NSString *)filePath
{
    objc_setAssociatedObject(self, @selector(filePath), filePath, OBJC_ASSOCIATION_COPY_NONATOMIC
                             );
}

- (NSString *)filePath
{
    return objc_getAssociatedObject(self, _cmd);
}

//@property (nonatomic, copy) NSString *tempFileName;
//@property (nonatomic, copy) NSString *resumeData;
//@property (nonatomic, copy) NSString *tempPath;

- (void)setTempFileName:(NSString *)tempFileName
{
    objc_setAssociatedObject(self, @selector(tempFileName), tempFileName, OBJC_ASSOCIATION_COPY_NONATOMIC
                             );
}

- (NSString *)tempFileName
{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setTempPath:(NSString *)tempPath
{
    objc_setAssociatedObject(self, @selector(tempPath), tempPath, OBJC_ASSOCIATION_COPY_NONATOMIC
                             );
}

- (NSString *)tempPath
{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setResumeData:(NSString *)resumeData
{
    objc_setAssociatedObject(self, @selector(resumeData), resumeData, OBJC_ASSOCIATION_COPY_NONATOMIC
                             );
}

- (NSString *)resumeData
{
    return objc_getAssociatedObject(self, _cmd);
}
@end
