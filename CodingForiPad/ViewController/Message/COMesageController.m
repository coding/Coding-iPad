//
//  COMesageController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/14.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COMesageController.h"
#import "COMessageViewController.h"
#import "COConversation.h"
#import "CORootViewController.h"
#import "COConversationListController.h"

@interface COMesageController ()<UINavigationControllerDelegate, CORootBackgroudProtocol>

@property (nonatomic, strong) UINavigationController *rightNav;
@property (nonatomic, strong) COMessageViewController *detailController;
@property (nonatomic, strong) COConversationListController *leftController;
@property (nonatomic, assign) BOOL showDetail;

@end

@implementation COMesageController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.rightView.hidden = YES;
    self.leftView.layer.cornerRadius = 4.0;
    self.leftView.layer.masksToBounds = YES;
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showMessage:(COConversation *)conversation
{
    self.showDetail = NO;
    if (conversation) {
        self.rightView.hidden = NO;
        [self.rightNav popToRootViewControllerAnimated:NO];
        [[CORootViewController currentRoot] changeBackground:[UIImage imageNamed:@"background_message"] full:YES];
        [self.detailController showMessage:conversation];
    } else {
        [[CORootViewController currentRoot] changeBackground:[UIImage imageNamed:@"background_message_half"] full:YES];
        self.rightView.hidden = YES;
    }
}

- (void)pushDetail:(UIViewController *)controller
{
    self.showDetail = YES;
    self.rightView.hidden = NO;
    [[CORootViewController currentRoot] changeBackground:[UIImage imageNamed:@"background_message"] full:YES];
    [self.rightNav pushViewController:controller animated:NO];
}

- (void)chatToGlobalKey:(NSString *)globalKey
{
    self.rightView.hidden = NO;
    [[CORootViewController currentRoot] changeBackground:[UIImage imageNamed:@"background_message"] full:YES];
    [self.detailController chatToGlobalKey:globalKey];
}

- (void)showPushNotification:(NSString *)linkStr
{
    [self.leftController showPushNotification:linkStr];
}

#pragma mark -
- (UIImage *)imageForBackgroud
{
    if (self.rightView == nil
        || self.rightView.hidden == YES) {
        // 半屏
        return [UIImage imageNamed:@"background_message_half"];
    }
    else {
        // 全屏
        return [UIImage imageNamed:@"background_message"];
    }
}

#pragma mark -
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.showDetail) {
        NSInteger index = [navigationController.viewControllers indexOfObject:viewController];
        if (index == 0) {
            self.rightView.hidden = YES;
        }
    }
}

#pragma mark -
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"messageDetail"]) {
        self.rightNav = segue.destinationViewController;
        self.rightNav.delegate = self;
        self.detailController = self.rightNav.viewControllers.firstObject;
    }
    else if ([segue.identifier isEqualToString:@"messageLeftList"]) {
        self.leftController = segue.destinationViewController;
    }
}

@end
