//
//  DownlodedCell.h
//  downloadCeshi
//
//  Created by 瞄财网 on 2017/3/16.
//  Copyright © 2017年 瞄财网. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FileModel;

@interface DownlodedCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (nonatomic, strong) FileModel *flModel;

@end
