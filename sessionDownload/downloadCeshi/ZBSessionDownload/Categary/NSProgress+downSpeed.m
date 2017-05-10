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

- (int64_t)zb_downSpeed
{
    return [objc_getAssociatedObject(self, _cmd) longLongValue];
}

- (void)setZb_downSpeed:(int64_t)zb_downSpeed
{
    objc_setAssociatedObject(self, @selector(zb_downSpeed), [NSNumber numberWithLongLong:zb_downSpeed], OBJC_ASSOCIATION_ASSIGN);
}

- (int64_t)zb_preBytes
{
    return [objc_getAssociatedObject(self, _cmd) longLongValue];
}

- (void)setZb_preBytes:(int64_t)zb_preBytes
{
    objc_setAssociatedObject(self, @selector(zb_preBytes), [NSNumber numberWithLongLong:zb_preBytes], OBJC_ASSOCIATION_ASSIGN);
}


- (NSDate *)zb_startDate
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setZb_startDate:(NSDate *)zb_startDate
{
    objc_setAssociatedObject(self, @selector(zb_startDate), zb_startDate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
