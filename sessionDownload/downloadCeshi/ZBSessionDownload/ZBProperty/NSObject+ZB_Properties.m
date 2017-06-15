//
//  NSObject+ZB_Properties.m
//  ZBDBManager
//
//  Created by 瞄财网 on 2017/5/18.
//  Copyright © 2017年 瞄财网. All rights reserved.
//

#import "NSObject+ZB_Properties.h"
#import "ZBProperty.h"


@implementation NSObject (ZB_Properties)

const static NSMutableDictionary *_propertiesForClassDict;

+ (void)load
{
    _propertiesForClassDict = @{}.mutableCopy;
}

+ (NSDictionary *)ZB_allProperties
{
    unsigned int zb_count = 0;
    NSMutableDictionary *dicM = @{}.mutableCopy;
    objc_property_t *properties = class_copyPropertyList([self class], &zb_count);
    for (NSUInteger i = 0; i < zb_count; i ++) {
        const char *propertyName = property_getName(properties[i]);
        NSString *name = [NSString stringWithUTF8String:propertyName];
        id propertyValue = [self valueForKey:name];
        if (propertyValue) {
            dicM[name] = propertyValue;
        } else {
            dicM[name] = @"";
        }
    }
    free(properties);
    return dicM;
}

+ (NSDictionary *)getPropertiesDict
{
    
    NSDictionary *propertydic = [_propertiesForClassDict objectForKey:NSStringFromClass(self)];
    if (!propertydic) {

        unsigned int zb_count = 0;
        NSMutableDictionary *dictM = @{}.mutableCopy;
        objc_property_t *properties = class_copyPropertyList([self class], &zb_count);
        NSArray *allowDBProperties = nil;
        if ([[self class] respondsToSelector:@selector(ZB_allowedDBPropertyNames)]){
            allowDBProperties = [[self class] ZB_allowedDBPropertyNames];
        }
        NSArray *ignoreDBPropertyNames = nil;
        if ([[self class] respondsToSelector:@selector(ZB_ignoredDBPropertyNames)]){
            ignoreDBPropertyNames = [[self class] ZB_ignoredDBPropertyNames];
        }
        
        if (allowDBProperties.count) {
            for (NSUInteger i = 0; i < zb_count; i ++) {
                objc_property_t property = properties[i];
                ZBProperty *propertyObj = [ZBProperty zb_cachedPropertyWithProperty:property];
                if ([allowDBProperties containsObject:propertyObj.name]) {
                    [dictM setValue:propertyObj.typeEncoding forKey:propertyObj.name];
                }
            }
            free(properties);
            propertydic = [dictM copy];
            [_propertiesForClassDict setObject:propertydic forKey:NSStringFromClass(self)];
            return propertydic;
        }
        
        for (NSUInteger i = 0; i < zb_count; i ++) {
            objc_property_t property = properties[i];
            ZBProperty *propertyObj = [ZBProperty zb_cachedPropertyWithProperty:property];
            if (![ignoreDBPropertyNames containsObject:propertyObj.name]) {
                [dictM setValue:propertyObj.typeEncoding forKey:propertyObj.name];
            }
        }
        free(properties);
        propertydic = [dictM copy];
        [_propertiesForClassDict setObject:propertydic forKey:NSStringFromClass(self)];
    }
    
    return propertydic;
}


+ (NSDictionary *)getIvarsDict
{
    unsigned int zb_count = 0;
    NSMutableDictionary *dictM = @{}.mutableCopy;
    Ivar *ivars = class_copyIvarList([self class], &zb_count);
    for (int i = 0; i < zb_count; i ++) {
        
        Ivar ivar = ivars[i];
        NSLog(@"%@-----------",@(ivar_getName(ivar)));
    }
    return nil;
}

@end
