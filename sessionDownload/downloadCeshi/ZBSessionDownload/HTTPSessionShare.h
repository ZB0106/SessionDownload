//
//  HTTPSessionShare.h
//  downloadCeshi
//
//  Created by 瞄财网 on 2017/3/16.
//  Copyright © 2017年 瞄财网. All rights reserved.
//


#import "HTTPSessionShareDelegate.h"
@class FileModel;


@interface HTTPSessionShare : NSObject

+ (HTTPSessionShare *)httpSessionShare;

//存储task与url，便于查询
//@property (nonatomic, strong) NSMutableDictionary *taskDict;
//存储正在下载的文件模型
@property (nonatomic, strong, readonly) NSMutableArray *downloadingList;
//存储现在暂停中的文件模型
//@property (nonatomic, strong, readonly) NSMutableArray *stopDownloadList;
//存储磁盘缓存的文件
@property (nonatomic, strong, readonly) NSMutableArray *diskFileList;
//最大并发数
@property (nonatomic, assign) NSInteger maxCount;
//代理
@property (nonatomic, weak) id<HTTPSessionShareDelegate>sessionDelegate;

- (void)downloadFileWithFileModel:(FileModel *)model;

- (void)downloadFileWithFileModelArray:(NSArray<FileModel*> *)modelArray;

- (void)startAllTask;
- (void)stopAllTask;

- (void)continueDownloadWithFile:(FileModel *)file;
- (void)stopDownloadWithFile:(FileModel *)file;
- (void)removeFileWithFileArray:(NSArray *)fileArray;

@end
