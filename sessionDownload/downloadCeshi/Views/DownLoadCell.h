//
//  DownLoadCell.h
//  downloadCeshi
//
//  Created by 瞄财网 on 2017/3/15.
//  Copyright © 2017年 瞄财网. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FileModel;

typedef void(^btnclick)(BOOL selected);

@interface DownLoadCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;

@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (nonatomic, strong) FileModel *flModel;
/** 下载按钮点击回调block */
@property (nonatomic, copy  ) btnclick  btnClickBlock;
/** 下载信息模型 */
//@property (nonatomic, strong) ZFFileModel      *fileInfo;
/** 该文件发起的请求 */
//@property (nonatomic,retain ) ZFHttpRequest    *request;

@end
