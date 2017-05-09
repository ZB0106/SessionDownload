//
//  NSProgress+downSpeed.h
//  downloadCeshi
//
//  Created by mac  on 17/5/8.
//  Copyright © 2017年 瞄财网. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSProgress (downSpeed)

@property (nonatomic, assign) float zb_downSpeed;
@property (nonatomic, assign) int64_t zb_preBytes;
@property (nonatomic, strong) NSDate *zb_startDate;

@end
