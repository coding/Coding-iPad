//
//  COActiveTipsViewController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/8/31.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COActiveTipsViewController.h"
#import "CORootViewController.h"

@interface COActiveTipsViewController ()

@end

@implementation COActiveTipsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (IBAction)btnAction:(id)sender
{
    [[CORootViewController currentRoot] dismissPopover];
}

@end
