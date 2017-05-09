//
//  DownLoadCell.m
//  downloadCeshi
//
//  Created by 瞄财网 on 2017/3/15.
//  Copyright © 2017年 瞄财网. All rights reserved.
//

#import "DownLoadCell.h"
#import "FileModel.h"
#import "HTTPSessionShare.h"
#import "NSString+Common.h"

@implementation DownLoadCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)clickDownload:(UIButton *)sender {
    // 执行操作过程中应该禁止该按键的响应 否则会引起异常
    sender.selected = !sender.selected;
    if (sender.selected) {
        [HttpShare continueDownloadWithFile:self.flModel];
    } else {
        [HttpShare stopDownloadWithFile:self.flModel];
    }

    if (self.btnClickBlock) {
        self.btnClickBlock(sender.selected);
    }
    
    
}

- (void)setFlModel:(FileModel *)flModel
{
    _flModel = flModel;
    self.fileNameLabel.text = flModel.fileName;
    if (flModel.fileSize.integerValue > 0) {
        self.progress.progress = 1.0 * flModel.fileReceivedSize.integerValue / flModel.fileSize.integerValue;
    } else {
        self.progress.progress = 0.0;
    }
    
    if (flModel.fileState == FileDownloading) {
        self.downloadBtn.selected = YES;
        self.speedLabel.text = flModel.fileDownSpeed;
    } else if (flModel.fileState == FileWillDownload){
        self.speedLabel.text = @"下载等待中...";
        self.downloadBtn.selected = NO;
    } else
    {
        self.downloadBtn.selected = NO;
        self.speedLabel.text = @"";
    }
}
@end
