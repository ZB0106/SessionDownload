//
//  DownlodedCell.m
//  downloadCeshi
//
//  Created by 瞄财网 on 2017/3/16.
//  Copyright © 2017年 瞄财网. All rights reserved.
//

#import "DownlodedCell.h"
#import "FileModel.h"
#import "NSString+Common.h"

@implementation DownlodedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setFlModel:(FileModel *)flModel
{
    _flModel = flModel;
    self.fileNameLabel.text = flModel.fileName;
    self.sizeLabel.text = [NSString stringWithFormat:@"%@/%@",[NSString getFileSizeString:flModel.fileReceivedSize.longLongValue],[NSString getFileSizeString:flModel.fileSize.longLongValue]];
}
@end
