//
//  FileModelDbManager.h
//  downloadCeshi
//
//  Created by 瞄财网 on 2017/3/16.
//  Copyright © 2017年 瞄财网. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FileModel;

@interface NSObject(FileDBManager)

//插入文件
+(BOOL)insertFile:(FileModel *)fileModel;
//批量插入文件
+(BOOL)batchInsertFile:(NSArray *)fileList;
//删除文件
+(BOOL)delFiles:(FileModel *)fileModel;
//更新文件
+(BOOL)updateFile:(FileModel *)fileModel;

//查询所有本地文件
+ (NSArray *)getAllFileModel;
//根据url查询文件
+ (FileModel *)getFileModeWithFilUrl:(NSString *)fileUrl;

//查询所有未下载完成的文件
+(NSArray *)getAllStopDownloadFile;
+(NSArray *)getAllDownloadingFile;

+ (NSArray *)getAllNotCompletedFile;
//查询所有已经下载完成的文件
+ (NSArray *)getAllDownloadedFile;

+ (BOOL)updateUnFinishedFileState;
@end
