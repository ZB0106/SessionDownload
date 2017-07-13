//
//  NSString+Common.m
//  MCSchool
//
//  Created by 瞄财网 on 2017/3/23.
//  Copyright © 2017年 瞄财网络科技（北京）有限公司. All rights reserved.
//

#import "NSString+Common.h"

@implementation NSString (Common)
+ (NSString *)getFileSizeString:(int64_t )size
{
    if(size >=1024*1024)//大于1M，则转化成M单位的字符串
    {
        return [NSString stringWithFormat:@"%.2fM",size * 1.0/1024/1024];
    }
    else if(size >=1024 && size <1024*1024) //不到1M,但是超过了1KB，则转化成KB单位
    {
        return [NSString stringWithFormat:@"%.2fKB",1.0 * size/1024];
    }
    else//剩下的都是小于1K的，则转化成B单位
    {
        return [NSString stringWithFormat:@"%zdB",size];
    }
}

@end

@implementation NSString (ZB_timeStamp)

+ (NSString *)getCurrentTimeStamp
{
    NSTimeInterval time = kCFAbsoluteTimeIntervalSince1970;
    time = time * 1000;
    NSString *timeString = [NSString stringWithFormat:@"%@",@(time)];
    NSRange range = [timeString rangeOfString:@"."];
    if (range.location == NSNotFound) {
        return timeString;
    }
    return [timeString substringToIndex:range.location];
}

@end
