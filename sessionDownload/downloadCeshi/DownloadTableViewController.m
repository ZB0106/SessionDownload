//
//  DownloadTableViewController.m
//  downloadCeshi
//
//  Created by 瞄财网 on 2017/3/15.
//  Copyright © 2017年 瞄财网. All rights reserved.
//

#import "DownloadTableViewController.h"
#import "FileModel.h"
#import "FileModelDbManager.h"
#import "AFNetworking.h"
#import "DownLoadCell.h"
#import "DownlodedCell.h"
#import "HTTPSessionShare.h"

@interface DownloadTableViewController ()<HTTPSessionShareDelegate>

@property (atomic, strong) NSMutableArray *downloadObjectArr;

@end

@implementation DownloadTableViewController

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor grayColor];
    [super viewDidLoad];
    HttpShare.sessionDelegate = self;
    self.tableView.rowHeight = 100;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self initData];
}
- (void)initData
{
    
    self.downloadObjectArr = @[].mutableCopy;
    [self.downloadObjectArr addObjectsFromArray:HttpShare.diskFileList];
    [self.downloadObjectArr addObjectsFromArray:HttpShare.downloadingList];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.downloadObjectArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileModel *model = self.downloadObjectArr[indexPath.row];
    
    if (model.fileState != FileDownloaded) {
        DownLoadCell *cell = [tableView dequeueReusableCellWithIdentifier:@"downLoadCell"];
        cell.flModel = model;
        return cell;
    } else
    {
        DownlodedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"downloadedCell"];
        cell.flModel = model;
        return cell;
    }
    
}
#pragma mark sessionsharedelegate 相关方法
- (void)updateProgressWithFlModel:(FileModel *)flModel
{
    NSArray *cellArr = [self.tableView visibleCells];
    for (id obj in cellArr) {
        if([obj isKindOfClass:[DownLoadCell class]]) {
            DownLoadCell *cell = (DownLoadCell *)obj;
            if([cell.flModel.fileUrl isEqualToString:flModel.fileUrl]) {
                cell.flModel = flModel;
            }
        }
    }
}
- (void)updateTableViewWithFlModel:(FileModel *)flModel
{
//    NSArray *cellArr = [self.tableView visibleCells];
//    for (id obj in cellArr) {
//        if([obj isKindOfClass:[DownLoadCell class]]) {
//            DownLoadCell *cell = (DownLoadCell *)obj;
//            if([cell.flModel.fileUrl isEqualToString:flModel.fileUrl]) {
//                cell.flModel = flModel;
//            }
//        }
//    }

    [self initData];
}
@end