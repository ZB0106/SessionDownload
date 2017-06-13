//
//  DatabaseQueueShare.m
//  downloadCeshi
//
//  Created by 瞄财网 on 2017/3/16.
//  Copyright © 2017年 瞄财网. All rights reserved.
//

#import "DatabaseQueueShare.h"
#import "FileManageShare.h"
#import <sqlite3.h>


@implementation DatabaseQueueShare

static DatabaseQueueShare *_databaseQueueShare = nil;

+ (DatabaseQueueShare *)databaseQueueShare
{
//    static DatabaseQueueShare *_databaseQueueShare = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _databaseQueueShare = [self databaseQueueWithPath:[[FileManageShare fileManageShare] miaocaiRootDBCache] flags:SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FILEPROTECTION_NONE];
    });
    return _databaseQueueShare;
}

- (void)updateDBVersion
{
    [self inDatabase:^(FMDatabase *db) {
        if(db != nil)
        {
            
            [db executeUpdate:@"CREATE TABLE IF NOT EXISTS DOWNLOADFILE (DownLoadIndex integer PRIMARY KEY AUTOINCREMENT, LocalFilePath varchar(200),  FileSize varchar(200),  DownloadSize varchar(200), fileState INTEGER DEFAULT 0,  FileName varchar(200)  NOT NULL,  fileUrl varchar(200)  NOT NULL,  CreateDate varchar(40) ,resumeData varchar(4000), tempPath varchar(200), tempFileName varchar(200));"];
        }
    }];
    
}

//+ (instancetype)allocWithZone:(struct _NSZone *)zone
//{
//    _dispatch_once(&onceToken, ^{
//        if (_databaseQueueShare == nil) {
//            _databaseQueueShare = [super allocWithZone:zone];
//        }
//        
//    });
//    return _databaseQueueShare;
//}

@end
