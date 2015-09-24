//
//  COSplitController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/28.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COSplitController.h"

@interface COSplitController ()

@property (nonatomic, strong) UIViewController *rightController;

@end

@implementation COSplitController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showInRightView:(UIViewController *)vc sender:(id)sender
{
    if (_rightController) {
        [_rightController.view removeFromSuperview];
        [_rightController removeFromParentViewController];
        _rightController = nil;
    }
    
    vc.view.frame = _rightView.bounds;
    [_rightView addSubview:vc.view];
    _rightController = vc;
    
    [self addChildViewController:vc];
}

@end
