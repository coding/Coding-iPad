//
//  COSettingItemsViewController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/22.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COSettingItemsViewController.h"
#import "COSession.h"
#import "CORootViewController.h"
#import "COSettingPasswordController.h"

#define kAppReviewURL   @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=1013704594"

@interface COSettingItemsViewController () <UIActionSheetDelegate>

@end

@implementation COSettingItemsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (0 == indexPath.row) {
        // 修改密码
        COSettingPasswordController *popoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"COSettingPasswordController"];
        [[CORootViewController currentRoot] popoverController:popoverVC withSize:CGSizeMake(kPopWidthS, kPopHeightSS)];
    }
    else if (1 == indexPath.row) {
        // 意见反馈
        [_settingController showFeedback];
    }
    else if (2 == indexPath.row) {
        // 去评分
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppReviewURL]];
    }
    else if (3 == indexPath.row) {
        // 关于
        [_settingController showAbout];
    }
}

#pragma mark - Action
- (IBAction)logouAction:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"确定要退出当前帐号" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定退出" otherButtonTitles:@"取消", nil];
    CORootViewController *root = [CORootViewController currentRoot];
    [sheet showInView:root.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (0 == buttonIndex) {
        [[COSession session] userLogout];
    }
}

@end
