//
//  ZBDBProtocol.h
//  ZBDBManager
//
//  Created by mac  on 17/5/20.
//  Copyright © 2017年 瞄财网. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZBDBProtocol <NSObject>

@optional
+ (NSArray *)ZB_allowedDBPropertyNames;
+ (NSArray *)ZB_ignoredDBPropertyNames;

@end
