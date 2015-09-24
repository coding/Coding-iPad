//
//  COTaskDeadlineController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/24.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COTaskDeadlineController.h"
#import "CORootViewController.h"
#import "COAddTaskViewController.h"
#import "COTask.h"
#import "COUtility.h"

@interface COTaskDeadlineController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;

@end

@implementation COTaskDeadlineController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _datePicker.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - click
- (IBAction)cancelBtnClick:(UIButton *)sender
{
    // 移除
    _task.deadline = nil;
    if (_type == 0) {
        [[CORootViewController currentRoot] dismissPopover];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
        [[CORootViewController currentRoot] popoverChangeSize:CGSizeMake(kPopWidth, kPopHeight)];
    }
}

- (IBAction)okBtnClick:(UIButton *)sender
{
    // 已有任务修改截止时间 或 新增任务设置截止时间
    _task.deadline = [COUtility timestampToDay:[_datePicker.date timeIntervalSince1970] * 1000];
    
    if (_type == 0) {
        [[CORootViewController currentRoot] dismissPopover];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
        [[CORootViewController currentRoot] popoverChangeSize:CGSizeMake(kPopWidth, kPopHeight)];
    }
}

@end
