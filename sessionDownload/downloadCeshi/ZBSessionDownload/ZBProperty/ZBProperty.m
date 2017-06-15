//
//  ZBProperty.m
//  ZBDBManagerDemo
//
//  Created by mac  on 17/5/22.
//  Copyright © 2017年 kdong. All rights reserved.
//

#import "ZBProperty.h"
#import "ZBPropertyType.h"

@interface ZBProperty ()

@property (nonatomic, assign) objc_property_t property;

@end

@implementation ZBProperty

+ (instancetype)zb_cachedPropertyWithProperty:(objc_property_t)property
{
    ZBProperty *zb_property = objc_getAssociatedObject(self, property);
    if (!zb_property) {
        zb_property = [[self alloc] init];
        zb_property.property = property;
        objc_setAssociatedObject(self , property, zb_property, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return zb_property;
}

- (void)setProperty:(objc_property_t)property
{
    _property = property;
    _name = @(property_getName(property));
    
    NSString *ty = @(property_getAttributes(property));
    NSLog(@"%@======",ty);
    unsigned int attrCount = 0;
    objc_property_attribute_t *attrs = property_copyAttributeList(property, &attrCount);
    for (int i = 0; i < attrCount; i ++) {
        
        NSLog(@"%@＋＋＋＋＋%@",@(attrs[i].name),@(attrs[i].value));
        switch (attrs[i].name[0]) {
            case 'T':
                if (attrs[i].value) {
                    _typeEncoding = [ZBPropertyType zb_cachedTypeWithCode:@(attrs[i].value)];
                }
                break;
                
            default:
                break;
        }
    }
}
@end
