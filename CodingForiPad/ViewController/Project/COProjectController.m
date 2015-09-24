//
//  COProjectController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/14.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COProjectController.h"
#import "COProjectDetailController.h"
#import "COProjectListController.h"
#import "CORootViewController.h"

@interface COProjectController ()<CORootBackgroudProtocol>

@property (nonatomic, strong) COProjectDetailController *detailController;
@property (nonatomic, strong) COProjectListController *listController;
@property (nonatomic, strong) UINavigationController *rightNav;

@end

@implementation COProjectController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"项目详情";
    self.rightView.hidden = YES;
    self.leftView.layer.cornerRadius = 4.0;
    self.leftView.layer.masksToBounds = YES;
    self.view.backgroundColor = [UIColor clearColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(projectReload:) name:OPProjectReloadNotification object:nil];
}

- (void)projectReload:(NSNotification *)n
{
    self.rightView.hidden = YES;
    [[CORootViewController currentRoot] changeBackground:[UIImage imageNamed:@"background_project"] full:NO];
    [self.rightNav popToRootViewControllerAnimated:NO];
    [self.listController reloadProject];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showProject:(COProject *)project
{
    if (project) {
        self.rightView.hidden = NO;
        [[CORootViewController currentRoot] changeBackground:[UIImage imageNamed:@"background_project"] full:YES];
        [self.rightNav popToRootViewControllerAnimated:NO];
        [self.rightNav.view removeFromSuperview];
        self.rightNav = nil;
        self.detailController = nil;
        self.rightNav = [self.storyboard instantiateViewControllerWithIdentifier:@"projectDetailNav"];
        self.detailController = self.rightNav.viewControllers.firstObject;
        self.rightNav.view.frame = self.rightView.bounds;
        [self.rightView addSubview:self.rightNav.view];
        [self.detailController showProject:project];
    }
    else {
        self.rightView.hidden = YES;
        [[CORootViewController currentRoot] changeBackground:[UIImage imageNamed:@"background_project"] full:NO];
        [self.rightNav popToRootViewControllerAnimated:NO];
    }
}

- (void)showUserProjects:(COUser *)user
{
    self.rightView.hidden = YES;
    [self.rightNav popToRootViewControllerAnimated:NO];
}

#pragma mark -
- (UIImage *)imageForBackgroud
{
    if (self.rightView == nil
        || self.rightView.hidden) {
        // 半屏
        return [UIImage imageNamed:@"background_project_half"];
    }
    else {
        // 全屏
        return [UIImage imageNamed:@"background_project"];
    }
}

#pragma mark -
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"projectDetail"]) {
        UINavigationController *nav = segue.destinationViewController;
        self.rightNav = nav;
        self.detailController = nav.childViewControllers.firstObject;
    }
    else if ([segue.identifier isEqualToString:@"projectList"]) {
        self.listController = segue.destinationViewController;
        self.listController.user = self.user;
    }
}

@end
