//
//  LLMainTableViewController.m
//  LLVideoDemo
//
//  Created by LvJianfeng on 2016/10/21.
//  Copyright © 2016年 LvJianfeng. All rights reserved.
//

#import "LLMainTableViewController.h"
#import "CustomVideoPlayerViewController.h"

@interface LLMainTableViewController ()

@end

@implementation LLMainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 1) {
        [self presentViewController:[CustomVideoPlayerViewController new] animated:YES completion:nil];
    }
}
@end
