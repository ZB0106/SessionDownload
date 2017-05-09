//
//  ListCell.m
//  downloadCeshi
//
//  Created by 瞄财网 on 2017/3/15.
//  Copyright © 2017年 瞄财网. All rights reserved.
//

#import "ListCell.h"

@implementation ListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)downloadAction:(UIButton *)sender {
    if (self.downloadCallBack) { self.downloadCallBack(); }
}

@end
