//
//  FileManageShare.m
//  downloadCeshi
//
//  Created by 瞄财网 on 2017/3/21.
//  Copyright © 2017年 瞄财网. All rights reserved.
//

#import "FileManageShare.h"


static FileManageShare *_share = nil;
@implementation FileManageShare

+ (FileManageShare *)fileManageShare
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_share == nil) {
            
            _share = [[self alloc] init];
        }
    });
    return _share;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_share == nil) {
            _share = [super allocWithZone:zone];
        }
    });
    return _share;

}

- (NSString *)mioacaiRoot
{
    NSString *path = [RootCache stringByAppendingPathComponent:@"miaocai/common"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:path])
    {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return path;
}
- (NSString *)miaocaiRootTempCache
{
    NSString *path = [[self mioacaiRoot] stringByAppendingPathComponent:@"cache"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:path])
    {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return path;
}
- (NSString *)miaocaiRootDownloadFileCache
{
    NSString *path = [[self mioacaiRoot] stringByAppendingPathComponent:@"downloadFile"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:path])
    {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return path;
}
- (NSString *)miaocaiRootDBCache
{
    NSString *path = [[self mioacaiRoot] stringByAppendingPathComponent:@"DB/miaocai.db"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:path])
    {
        [fileManager createDirectoryAtPath:[path stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return path;
}

@end
