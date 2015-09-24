//
//  COSettingController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/18.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COSettingController.h"
#import "COSettingEmptyViewController.h"
#import "COFeedbackViewController.h"
#import "COTopic+Ext.h"
#import "CORootViewController.h"

@interface COSettingController ()<CORootBackgroudProtocol>

@end

@implementation COSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage *)imageForBackgroud
{
    return [UIImage imageNamed:@"background_setting"];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"settingLeft"]) {
        [segue.destinationViewController setValue:self forKey:@"settingController"];
    }
    else if ([segue.identifier isEqualToString:@"settingRight"]) {
        self.rightRoot = segue.destinationViewController;
    }
}

- (void)showFeedback
{
    COFeedbackViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COFeedbackViewController"];
    controller.topic = [COTopic feedbackTopic];
    [self.rightRoot popToRootViewControllerAnimated:NO];
    [self.rightRoot pushViewController:controller animated:NO];
}

- (void)showAbout
{
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COAboutViewController"];
    [self.rightRoot popToRootViewControllerAnimated:NO];
    [self.rightRoot pushViewController:controller animated:NO];
}

@end
