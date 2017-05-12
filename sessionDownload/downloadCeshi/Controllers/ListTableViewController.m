//
//  ListTableViewController.m
//  downloadCeshi
//
//  Created by 瞄财网 on 2017/3/15.
//  Copyright © 2017年 瞄财网. All rights reserved.
//

#import "ListTableViewController.h"
#import "ListCell.h"
#import "HTTPSessionShare.h"
#import "FileModel.h"

@interface ListTableViewController ()

@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, assign) NSInteger count;
@end

@implementation ListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blueColor]} forState:UIControlStateNormal];
    self.navigationItem.title = @"demo";
    self.navigationController.navigationBar.tintColor = [UIColor grayColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"全部开始" style:UIBarButtonItemStylePlain target:self action:@selector(xiazai)];
    self.count = 0;
    self.view.backgroundColor = [UIColor redColor];
    self.dataSource = @[@"http://dldir1.qq.com/qqfile/QQforMac/QQ_V4.2.4.dmg",
                        @"http://baobab.wdjcdn.com/1456117847747a_x264.mp4",
                        @"http://baobab.wdjcdn.com/14525705791193.mp4",
                        @"http://baobab.wdjcdn.com/1456459181808howtoloseweight_x264.mp4",
                        @"http://baobab.wdjcdn.com/1455968234865481297704.mp4",
                        @"http://sw.bos.baidu.com/sw-search-sp/software/d2622df9c559c/WeChat_2.4.1.67_setup.exe",
                        @"http://dlsw.baidu.com/sw-search-sp/soft/1c/25697/WinRAR.3.93.1395888874.dmg",
                        @"http://dlied6.qq.com/invc/qqpcmgr/qudao/qqpcmgr_v11.7.17799.230_8891720_1.exe",
                        @"http://xiazai.xiazaiba.com/Soft/Q/QQBrowser_9.5.4_XiaZaiBa.zip",
                        @"http://xiazai.xiazaiba.com/Soft/Q/QQMusic_13.02.3746.214_XiaZaiBa.zip",
                        @"http://xiazai.xiazaiba.com/Soft/B/BaiduBrowser_8.7.100.4208_XiaZaiBa.zip",
                        @"https://image.baidu.com/search/down?tn=download&word=download&ie=utf8&fr=detail&url=https%3A%2F%2Ftimgsa.baidu.com%2Ftimg%3Fimage%26quality%3D80%26size%3Db10000_10000%26sec%3D1490148924%26di%3D21578a4a0832a2f0b607488eb650a5cf%26src%3Dhttp%3A%2F%2Fdl.bizhi.sogou.com%2Fimages%2F2013%2F08%2F08%2F356837.jpg"];


}

- (void)xiazai
{
    NSMutableArray *arrM = [NSMutableArray array];
    for (NSString *urlStr in self.dataSource) {
       NSString *url = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSString *name = [[url componentsSeparatedByString:@"/"] lastObject];
        FileModel *fileModel = [[FileModel alloc] init];
        fileModel.fileName = name;
        fileModel.fileUrl = urlStr;
        [arrM addObject:fileModel];
    }
   
    [HttpShare downloadFileWithFileModelArray:arrM];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ListCell * cell = [tableView dequeueReusableCellWithIdentifier:@"listCell"];
    __block NSString *urlStr = self.dataSource[indexPath.row];
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    cell.titleLabel.text = urlStr;
    NSString *name = [[urlStr componentsSeparatedByString:@"/"] lastObject];
    FileModel *fileModel = [[FileModel alloc] init];
    fileModel.fileName = name;
    fileModel.fileUrl = urlStr;

    cell.downloadCallBack = ^{
        [HttpShare downloadFileWithFileModel:fileModel];
    };
    
    return cell;
}


@end
