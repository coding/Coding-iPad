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
#import <RegexKitLite.h>
#import "COProjectRequest.h"

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
//    [[CORootViewController currentRoot] changeBackground:[UIImage imageNamed:@"background_project"] full:NO];
    [[CORootViewController currentRoot].projectBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    [self.rightNav popToRootViewControllerAnimated:NO];
    if (n.userInfo) {
        NSString *data = n.userInfo[@"data"];
        if (data.length > 0) {
            
            NSString *projectRegexStr = @"/u/([^/]+)/p/([^/]+)";
            NSArray *matchedCaptures = [data captureComponentsMatchedByRegex:projectRegexStr];
            if (matchedCaptures.count >= 3) {
                NSString *user_global_key = matchedCaptures[1];
                NSString *project_name = matchedCaptures[2];
                COProject *curPro = [[COProject alloc] init];
                curPro.ownerUserName = user_global_key;
                curPro.name = project_name;
                [self showProject:curPro];
                
                COProjectDetailRequest *request = [COProjectDetailRequest request];
                request.projectName = project_name;
                request.projectOwnerName = user_global_key;
                __weak typeof(self) weakself = self;
                [request getWithSuccess:^(CODataResponse *responseObject) {
                    if ([weakself checkDataResponse:responseObject]) {
                        COProject *project = responseObject.data;
                        [self.listController reloadProject:project.projectId];
                    }
                } failure:^(NSError *error) {}];
            }
        }
    }
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
