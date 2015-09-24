//
//  COTaskProgressController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/24.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COTaskProgressController.h"
#import "CORootViewController.h"
#import "COTask.h"

@interface COTaskProgressController ()

@end

@implementation COTaskProgressController

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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"COTaskProgressCell"];
    
    UILabel *tempLbl = (UILabel *)[cell viewWithTag:110];
    tempLbl.text = indexPath.row == 0 ? @"未完成" : @"已完成";
    
    UIImageView *selectIcon = (UIImageView *)[cell viewWithTag:120];
    selectIcon.hidden = (_task.status == indexPath.row + 1) ? FALSE : TRUE;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _task.status = indexPath.row + 1;
    
    [[CORootViewController currentRoot] dismissPopover];
}

#pragma mark - click
- (IBAction)cancelBtnClick:(UIButton *)sender
{
    [[CORootViewController currentRoot] dismissPopover];
}

@end
