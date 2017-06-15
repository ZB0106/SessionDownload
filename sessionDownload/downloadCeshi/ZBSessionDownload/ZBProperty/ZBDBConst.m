//
//  ZBDBConst.m
//  ZBDBManagerDemo
//
//  Created by 瞄财网 on 2017/5/23.
//  Copyright © 2017年 kdong. All rights reserved.
//

#import "ZBDBConst.h"

@implementation ZBDBConst

/**
 *  成员变量类型（属性类型）
 */
NSString *const ZBPropertyTypeInt = @"i";
NSString *const ZBPropertyTypeShort = @"s";
NSString *const ZBPropertyTypeFloat = @"f";
NSString *const ZBPropertyTypeDouble = @"d";
NSString *const ZBPropertyTypeLong = @"l";
NSString *const ZBPropertyTypeLongLong = @"q";
NSString *const ZBPropertyTypeChar = @"c";
NSString *const ZBPropertyTypeBOOL1 = @"c";
NSString *const ZBPropertyTypeBOOL2 = @"b";
NSString *const ZBPropertyTypePointer = @"*";

NSString *const ZBPropertyTypeIvar = @"^{objc_ivar=}";
NSString *const ZBPropertyTypeMethod = @"^{objc_method=}";
NSString *const ZBPropertyTypeBlock = @"@?";
NSString *const ZBPropertyTypeClass = @"#";
NSString *const ZBPropertyTypeSEL = @":";
NSString *const ZBPropertyTypeId = @"@";


@end
