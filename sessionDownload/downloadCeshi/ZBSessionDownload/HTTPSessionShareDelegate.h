//
//  HTTPSessionShareDelegate.h
//  downloadCeshi
//
//  Created by 瞄财网 on 2017/3/17.
//  Copyright © 2017年 瞄财网. All rights reserved.
//

#import "FileModel.h"

@protocol HTTPSessionShareDelegate <NSObject>

@optional
- (void)updateProgressWithFlModel:(FileModel *)flModel;
- (void)updateTableViewWithFlModel:(FileModel *)flModel;

@end
