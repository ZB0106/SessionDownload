//
//  FileModelDbManager.m
//  downloadCeshi
//
//  Created by 瞄财网 on 2017/3/16.
//  Copyright © 2017年 瞄财网. All rights reserved.
//

#import "NSObject+FileDBManager.h"
#import "DatabaseQueueShare.h"
#import "FileModel.h"


@implementation NSObject(FileDBManager)

+ (BOOL)insertFile:(FileModel *)fileModel
{
    if (fileModel == nil) {
        return NO;
    }
    
    __block BOOL ret = NO;
    [DBQueueShare inDatabase:^(FMDatabase *db) {
        NSString *url = [db stringForQuery:@"SELECT fileUrl FROM DOWNLOADFILE WHERE fileUrl = ?",fileModel.fileUrl];
        if (url) {
            ret = [db executeUpdate:@"UPDATE DOWNLOADFILE SET LocalFilePath = ?,  FileName = ?, CreateDate = ?, fileState = ?, tempFileName = ?, tempPath = ?, resumeData = ?, FileSize = ?, DownloadSize = ? WHERE fileUrl = ?",fileModel.filePath,fileModel.fileName,fileModel.fileDownedTime,@(fileModel.fileState),fileModel.tempFileName,fileModel.tempPath,fileModel.resumeData,fileModel.fileSize,fileModel.fileReceivedSize,fileModel.fileUrl];
        } else {
            ret = [db executeUpdate:@"INSERT INTO DOWNLOADFILE(LocalFilePath, FileSize, DownloadSize, FileName, fileUrl, CreateDate, fileState,tempFileName,tempPath,resumeData) VALUES (?,?,?,?,?,?,?,?,?,?)",fileModel.filePath,fileModel.fileSize,fileModel.fileReceivedSize,fileModel.fileName,fileModel.fileUrl,fileModel.fileDownedTime,@(fileModel.fileState),fileModel.tempFileName,fileModel.tempPath,fileModel.resumeData];
        }
    }];
    return ret;
}

+ (BOOL)batchInsertFile:(NSArray *)fileList
{
    if (fileList.count == 0 || fileList == nil) {
        return NO;
    }
    __block BOOL ret = NO;
    [DBQueueShare inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (FileModel *fileModel in fileList) {
            
            NSString *url = [db stringForQuery:@"SELECT fileUrl FROM DOWNLOADFILE WHERE fileUrl = ?",fileModel.fileUrl];
            if (url) {
                ret = [db executeUpdate:@"UPDATE DOWNLOADFILE SET LocalFilePath = ?,  FileName = ?, CreateDate = ?, fileState = ?, tempFileName = ?, tempPath = ?, resumeData = ?, FileSize = ?, DownloadSize = ? WHERE fileUrl = ?",fileModel.filePath,fileModel.fileName,fileModel.fileDownedTime,@(fileModel.fileState),fileModel.tempFileName,fileModel.tempPath,fileModel.resumeData,fileModel.fileSize,fileModel.fileReceivedSize,fileModel.fileUrl];
            } else {
                 ret = [db executeUpdate:@"INSERT INTO DOWNLOADFILE(LocalFilePath, FileSize, DownloadSize, FileName, fileUrl, CreateDate, fileState,tempFileName,tempPath,resumeData) VALUES (?,?,?,?,?,?,?,?,?,?)",fileModel.filePath,fileModel.fileSize,fileModel.fileReceivedSize,fileModel.fileName,fileModel.fileUrl,fileModel.fileDownedTime,@(fileModel.fileState),fileModel.tempFileName,fileModel.tempPath,fileModel.resumeData];
            }

            if (!ret) {
                *rollback = YES;
                break;
            }
        }

    }];
    return ret;
}

+ (BOOL)delFiles:(FileModel *)fileModel
{
    if(fileModel == nil)
    {
        return NO;
    }
    //    FMDatabaseQueue *queen = [FMDatabaseQueue  databaseQueueWithPath:[[CFolderMgr shareInstance] personalDatabasePathRecently]];
    __block BOOL ret = NO;
    [DBQueueShare inDatabase:^(FMDatabase *db) {
        ret = [db executeUpdate:@"delete from DOWNLOADFILE where fileUrl = ?", fileModel.fileUrl];
    }];
    return ret;

}
+ (BOOL)updateFile:(FileModel *)fileModel
{
    if(fileModel == nil)
    {
        return NO;
    }
   
    __block BOOL ret = NO;
    [DBQueueShare inDatabase:^(FMDatabase *db) {
         ret = [db executeUpdate:@"UPDATE DOWNLOADFILE SET LocalFilePath = ?,  FileName = ?, CreateDate = ?, fileState = ?, tempFileName = ?, tempPath = ?, resumeData = ?, FileSize = ?, DownloadSize = ? WHERE fileUrl = ?",fileModel.filePath,fileModel.fileName,fileModel.fileDownedTime,@(fileModel.fileState),fileModel.tempFileName,fileModel.tempPath,fileModel.resumeData,fileModel.fileSize,fileModel.fileReceivedSize,fileModel.fileUrl];

    }];
    return ret;
 
}
+ (FileModel *)getFileModeWithFilUrl:(NSString *)fileUrl
{
    if (fileUrl == nil) {
        return nil;
    }
    __block FileModel *model = nil;
    [DBQueueShare inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"SELECT *FROM DOWNLOADFILE WHERE fileUrl = ?",fileUrl];
        if (result != nil) {
            while ([result next]) {
                model = [self fileModelWithResult:result];
            }
        }
        [result close];
    }];
    return model;
}

+ (FileModel *)fileModelWithResult:(FMResultSet *)result
{
    FileModel *model = [[FileModel alloc] init];
    
    model.filePath = [result stringForColumn:@"LocalFilePath"];
    model.fileSize = [result stringForColumn:@"FileSize"];
    model.fileReceivedSize = [result stringForColumn:@"DownloadSize"];
    model.fileName = [result stringForColumn:@"FileName"];
    model.fileDownedTime = [result stringForColumn:@"CreateDate"];
    model.fileState = [result intForColumn:@"fileState"];
    model.tempFileName = [result stringForColumn:@"tempFileName"];
    model.tempPath = [result stringForColumn:@"tempPath"];
    model.resumeData = [result stringForColumn:@"resumeData"];
    model.fileUrl = [result stringForColumn:@"fileUrl"];
    
    return model;
}

+ (NSArray *)getAllFileModel
{
    __block NSMutableArray *modelArray = [NSMutableArray array];
    [DBQueueShare inDatabase:^(FMDatabase *db) {
       FMResultSet *result = [db executeQuery:@"SELECT * FROM DOWNLOADFILE"];
        if (result) {
            while ([result next]) {
                FileModel *model = [self fileModelWithResult:result];
                [modelArray addObject:model];
            }
        }
        [result close];
    }];
    return modelArray;
}

+ (NSArray *)getAllDownloadedFile
{
    __block NSMutableArray *modelArray = [NSMutableArray array];
    [DBQueueShare inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM DOWNLOADFILE WHERE fileState = ?",@(FileDownloaded)];
        if (result) {
            while ([result next]) {
                FileModel *model = [self fileModelWithResult:result];
                [modelArray addObject:model];
            }
        }
        [result close];
    }];
    return modelArray;

}

+(NSArray *)getAllStopDownloadFile
{
    __block NSMutableArray *modelArray = [NSMutableArray array];
    [DBQueueShare inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM DOWNLOADFILE WHERE fileState = ?",@(FileStopDownload)];
        if (result) {
            while ([result next]) {
                FileModel *model = [self fileModelWithResult:result];
                [modelArray addObject:model];
            }
        }
        [result close];
    }];
    return modelArray;

}

+(NSArray *)getAllDownloadingFile
{
    __block NSMutableArray *modelArray = [NSMutableArray array];
    [DBQueueShare inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM DOWNLOADFILE WHERE fileState = ? OR fileState = ?",@(FileWillDownload),@(FileDownloading)];
        if (result) {
            while ([result next]) {
                FileModel *model = [self fileModelWithResult:result];
                [modelArray addObject:model];
            }
        }
        [result close];
    }];
    return modelArray;
    
}

+ (NSArray *)getAllNotCompletedFile
{
    __block NSMutableArray *modelArray = [NSMutableArray array];
    [DBQueueShare inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM DOWNLOADFILE WHERE fileState <> ?",@(FileDownloaded)];
        if (result) {
            while ([result next]) {
                FileModel *model = [self fileModelWithResult:result];
                [modelArray addObject:model];
            }
        }
        [result close];
    }];
    return modelArray;
}

+ (BOOL)updateUnFinishedFileState
{
    __block BOOL ret = NO;
    [DBQueueShare inDatabase:^(FMDatabase *db) {
        ret = [db executeUpdate:@"UPDATE DOWNLOADFILE SET fileState = ? WHERE fileState = ? OR fileState = ?",@(FileStopDownload),@(FileWillDownload),@(FileDownloading)];
        
    }];
    return ret;

}

@end
