//
//  COTaskController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/14.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COTaskController.h"
#import "COTaskDetailController.h"
#import "COTask.h"
#import "CORootViewController.h"

@interface COTaskController ()<CORootBackgroudProtocol>

@property (nonatomic, strong) COTaskDetailController *detailController;
@property (nonatomic, strong) UINavigationController *rightNav;

@end

@implementation COTaskController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rightView.hidden = YES;
    self.leftView.layer.cornerRadius = 4.0;
    self.leftView.layer.masksToBounds = YES;
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showTask:(COTask *)task
{
    self.rightView.hidden = NO;
    [[CORootViewController currentRoot] changeBackground:[UIImage imageNamed:@"background_tast"] full:YES];
    [self.rightNav popToRootViewControllerAnimated:NO];
    [self.detailController showTask:task];
}

- (UIImage *)imageForBackgroud
{
    if (self.rightView == nil
        || self.rightView.hidden) {
        // 半屏
        return [UIImage imageNamed:@"background_tast_half"];
    }
    else {
        // 全屏
        return [UIImage imageNamed:@"background_tast"];
    }
}

#pragma mark -
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"taskDetail"]) {
        UINavigationController *nav = segue.destinationViewController;
        self.rightNav = nav;
        self.detailController = nav.childViewControllers.firstObject;
    }
}

@end
