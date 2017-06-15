//
//  ZBPropertyType.m
//  ZBDBManagerDemo
//
//  Created by 瞄财网 on 2017/5/23.
//  Copyright © 2017年 kdong. All rights reserved.
//

#import "ZBPropertyType.h"
#import "ZBDBConst.h"
#import "ZBDBFoundation.h"

@implementation ZBPropertyType

static NSMutableDictionary *_zb_typeForCodeDict = nil;

+ (void)load
{
    _zb_typeForCodeDict = @{}.mutableCopy;
}

+ (instancetype)zb_cachedTypeWithCode:(NSString *)code
{
    @synchronized (self) {
        if (code.length) {
            ZBPropertyType *type = _zb_typeForCodeDict[code];
            if (!type) {
                type = [[self alloc] init];
                type.code = code;
                _zb_typeForCodeDict[code] = type;
            }
            return type;
        }
        return nil;
    }
}

- (void)setCode:(NSString *)code
{
    _code = [code copy];
    if ([code isEqualToString:ZBPropertyTypeId]) {
        _idType = YES;
    } else if (code.length > 3 && [code hasPrefix:@"@\""]){
        _code = [code substringWithRange:NSMakeRange(2, code.length - 3)];
        _typeClass = NSClassFromString(_code);
        _fromFoundation = [ZBDBFoundation isClassFromFoundation:_typeClass];
        _numberType = [_typeClass isSubclassOfClass:[NSNumber class]];
    } else {
    
    }
    NSString *lowerCode = _code.lowercaseString;
    NSArray *numberTypes = @[ZBPropertyTypeInt, ZBPropertyTypeShort, ZBPropertyTypeBOOL1, ZBPropertyTypeBOOL2, ZBPropertyTypeFloat, ZBPropertyTypeDouble, ZBPropertyTypeLong, ZBPropertyTypeLongLong, ZBPropertyTypeChar];
    if ([numberTypes containsObject:lowerCode]) {
        _numberType = YES;
        
        if ([lowerCode isEqualToString:ZBPropertyTypeBOOL1]
            || [lowerCode isEqualToString:ZBPropertyTypeBOOL2]) {
            _boolType = YES;
        }
    }

}

@end
