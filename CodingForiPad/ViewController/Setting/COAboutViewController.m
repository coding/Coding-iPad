//
//  COAboutViewController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/7/19.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COAboutViewController.h"

@interface COAboutViewController ()

@end

@implementation COAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString *bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    self.versionLabel.text = [NSString stringWithFormat:@"版本：%@", version];
    NSLog(@"bundleVersion: %@", bundleVersion);
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
