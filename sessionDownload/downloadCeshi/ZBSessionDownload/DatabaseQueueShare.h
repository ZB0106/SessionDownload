//
//  DatabaseQueueShare.h
//  downloadCeshi
//
//  Created by 瞄财网 on 2017/3/16.
//  Copyright © 2017年 瞄财网. All rights reserved.
//

#import "FMDatabaseQueue.h"

@interface DatabaseQueueShare : FMDatabaseQueue


+ (DatabaseQueueShare *)databaseQueueShare;
- (void)updateDBVersion;

@end
