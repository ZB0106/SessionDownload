//
//  ZBProperty.h
//  ZBDBManagerDemo
//
//  Created by mac  on 17/5/22.
//  Copyright © 2017年 kdong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
@class ZBPropertyType;

@interface ZBProperty : NSObject

@property (nonatomic, assign, readonly) objc_property_t property; ///< property's opaque struct
@property (nonatomic, strong, readonly) NSString *name;           ///< property's name
//@property (nonatomic, assign, readonly) YYEncodingType type;      ///< property's type
@property (nonatomic, strong, readonly) ZBPropertyType *typeEncoding;   ///< property's encoding value

+ (instancetype)zb_cachedPropertyWithProperty:(objc_property_t)property;

@end
