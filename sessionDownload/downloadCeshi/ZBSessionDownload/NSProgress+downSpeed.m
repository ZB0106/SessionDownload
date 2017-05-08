//
//  NSProgress+downSpeed.m
//  downloadCeshi
//
//  Created by mac  on 17/5/8.
//  Copyright © 2017年 瞄财网. All rights reserved.
//

#import "NSProgress+downSpeed.h"
#import <objc/runtime.h>

@implementation NSProgress (downSpeed)

- (float)zb_downSpeed
{
    return [objc_getAssociatedObject(self, @selector(zb_downSpeed)) floatValue];
}

- (void)setZb_downSpeed:(float)zb_downSpeed
{
    objc_setAssociatedObject(self, @selector(zb_downSpeed), [NSNumber numberWithFloat:zb_downSpeed], OBJC_ASSOCIATION_ASSIGN);
}
@end
