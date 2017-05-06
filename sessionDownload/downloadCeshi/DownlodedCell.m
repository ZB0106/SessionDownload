//
//  DownlodedCell.m
//  downloadCeshi
//
//  Created by 瞄财网 on 2017/3/16.
//  Copyright © 2017年 瞄财网. All rights reserved.
//

#import "DownlodedCell.h"
#import "FileModel.h"

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
    self.imageView.image = [UIImage imageWithContentsOfFile:flModel.filePath];
}
@end
