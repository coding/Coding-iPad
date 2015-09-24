//
//  COPojectAdvanceSettingViewController.m
//  CodingForiPad
//
//  Created by sgl on 15/7/9.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COPojectAdvanceSettingViewController.h"
#import "COProjectDeleteController.h"
#import "CORootViewController.h"

@interface COPojectAdvanceSettingViewController ()

@end

@implementation COPojectAdvanceSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)deleAction:(id)sender
{
    COProjectDeleteController *popoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"COProjectDeleteController"];
    popoverVC.project = self.project;
    [[CORootViewController currentRoot] popoverController:popoverVC withSize:CGSizeMake(400, 200)];
}

@end
