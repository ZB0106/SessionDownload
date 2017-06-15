//
//  NSObject+ZB_Properties.h
//  ZBDBManager
//
//  Created by 瞄财网 on 2017/5/18.
//  Copyright © 2017年 瞄财网. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "ZBDBProtocol.h"

@interface NSObject (ZB_Properties)<ZBDBProtocol>

+ (NSDictionary *)ZB_allProperties;

+ (NSDictionary *)getPropertiesDict;
+ (NSDictionary *)getIvarsDict;

@end
