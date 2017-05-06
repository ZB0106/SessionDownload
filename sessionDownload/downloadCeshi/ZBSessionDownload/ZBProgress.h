//
//  ZBProgress.h
//  MCSchool
//
//  Created by 瞄财网 on 2017/3/23.
//  Copyright © 2017年 瞄财网络科技（北京）有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZBProgress : NSObject

@property int64_t totalUnitCount;
@property int64_t completedUnitCount;
@property (nonatomic, assign) float downSpeed;

@end
