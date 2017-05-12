//
//  FileModel.m
//  downloadCeshi
//
//  Created by 瞄财网 on 2017/3/16.
//  Copyright © 2017年 瞄财网. All rights reserved.
//

#import "FileModel.h"

@implementation FileModel

- (instancetype)init
{
    if (self = [super init]) {
        _fileState = FileWillDownload;
    }
    return self;
}

@end
