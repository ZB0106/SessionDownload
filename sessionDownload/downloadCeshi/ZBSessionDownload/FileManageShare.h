//
//  FileManageShare.h
//  downloadCeshi
//
//  Created by 瞄财网 on 2017/3/21.
//  Copyright © 2017年 瞄财网. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FileManageShare : NSObject

+ (FileManageShare *)fileManageShare;
- (NSString *)miaocaiRootTempCache;
- (NSString *)miaocaiRootDownloadFileCache;
- (NSString *)miaocaiRootDBCache;
- (NSString *)miaocaiRootDownloadFile;
- (NSString *)appleSessionDownloadFile;

- (NSString *)miaocairootAppleLocationCache;
@end
