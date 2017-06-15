//
//  ZBDBFoundation.m
//  ZBDBManagerDemo
//
//  Created by 瞄财网 on 2017/5/23.
//  Copyright © 2017年 kdong. All rights reserved.
//

#import "ZBDBFoundation.h"

@implementation ZBDBFoundation

static NSSet *_zb_FoundationSet = nil;


+ (NSSet *)zb_foundationSet
{
    if (!_zb_FoundationSet) {
        _zb_FoundationSet = [NSSet setWithObjects:[NSURL class],
                             [NSDate class],
                             [NSValue class],
                             [NSData class],
                             [NSError class],
                             [NSArray class],
                             [NSDictionary class],
                             [NSString class],
                             [NSAttributedString class], nil];
    }
    return _zb_FoundationSet;
}

+ (BOOL)isClassFromFoundation:(Class)zb_class
{
    if (zb_class == [NSObject class]) {
        return YES;
    }
    __block BOOL ret = NO;
    [[self zb_foundationSet] enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([zb_class isSubclassOfClass:obj]) {
            ret = YES;
            *stop = YES;
        }
    }];
    return ret;
}
@end
