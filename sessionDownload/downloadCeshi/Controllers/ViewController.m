//
//  ViewController.m
//  downloadCeshi
//
//  Created by 瞄财网 on 2017/3/17.
//  Copyright © 2017年 瞄财网. All rights reserved.
//

#import "ViewController.h"
#import "DownloadTableViewController.h"
#import "FileManageShare.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UIAlertController *aler = [UIAlertController alertControllerWithTitle:@"" message:[[NSString alloc] initWithContentsOfFile:[[[FileManageShare fileManageShare] miaocaiRootDownloadFileCache] stringByAppendingPathComponent:@"ceshi.strings"]  encoding:NSUTF8StringEncoding error:nil] preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *act = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [aler addAction:act];
    
    [self presentViewController:aler animated:YES completion:nil];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
