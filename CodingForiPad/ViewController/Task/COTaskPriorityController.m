//
//  COTaskPriorityController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/24.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COTaskPriorityController.h"
#import "CORootViewController.h"
#import "COTask.h"
#import "COAddTaskViewController.h"

@interface COTaskPriorityController ()

@end

@implementation COTaskPriorityController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"COTaskPriorityCell"];
    
    UILabel *tempLbl = (UILabel *)[cell viewWithTag:101];
    tempLbl.textColor = indexPath.row == 3 ? [UIColor colorWithRed:155/255.0 green:155/255.0 blue:155/255.0 alpha:1.0]: [UIColor colorWithRed:1.0 green:69/255.0 blue:98/255.0 alpha:1.0];
    
    tempLbl = (UILabel *)[cell viewWithTag:102];
    tempLbl.textColor = (indexPath.row == 0 || indexPath.row == 1) ? [UIColor colorWithRed:1.0 green:69/255.0 blue:98/255.0 alpha:1.0] : [UIColor colorWithRed:155/255.0 green:155/255.0 blue:155/255.0 alpha:1.0];
    
    tempLbl = (UILabel *)[cell viewWithTag:103];
    tempLbl.textColor = indexPath.row == 0 ? [UIColor colorWithRed:1.0 green:69/255.0 blue:98/255.0 alpha:1.0] : [UIColor colorWithRed:155/255.0 green:155/255.0 blue:155/255.0 alpha:1.0];
    
    tempLbl = (UILabel *)[cell viewWithTag:110];
    if (indexPath.row == 0) {
        tempLbl.text = @"十万火急";
    } else if (indexPath.row == 1) {
        tempLbl.text = @"优先处理";
    } else if (indexPath.row == 2) {
        tempLbl.text = @"正常处理";
    } else if (indexPath.row == 3) {
        tempLbl.text = @"有空再看";
    }
    
    UIImageView *selectIcon = (UIImageView *)[cell viewWithTag:120];
    selectIcon.hidden = [[_task priorityDisplay] isEqualToString:tempLbl.text] ? FALSE : TRUE;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 已有任务修改任务优先级 或 新增任务设置任务优先级
    _task.priority = 3 - indexPath.row;
    
    if (_type == 0) {
        [[CORootViewController currentRoot] dismissPopover];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
        [[CORootViewController currentRoot] popoverChangeSize:CGSizeMake(kPopWidth, kPopHeight)];
    }
}

#pragma mark - click
- (IBAction)cancelBtnClick:(UIButton *)sender
{
    // 已有任务修改取消修改 或 新增任务返回上一步
    if (_type == 0) {
        [[CORootViewController currentRoot] dismissPopover];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
        [[CORootViewController currentRoot] popoverChangeSize:CGSizeMake(kPopWidth, kPopHeight)];
    }
}

@end
