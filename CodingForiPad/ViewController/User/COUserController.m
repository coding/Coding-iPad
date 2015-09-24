//
//  COUserController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/28.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COUserController.h"
#import "COUserInfoViewController.h"
#import "COUserDetailViewController.h"
#import "COAccountRequest.h"
#import "COAddFriendsController.h"
#import "CORootViewController.h"
#import "COSession.h"
#import "COProjectController.h"
#import "COUserProjectsViewController.h"

@interface COUserController ()

@property (nonatomic, strong) COUserInfoViewController *infoController;
@property (nonatomic, strong) COUserDetailViewController *detailController;
@property (nonatomic, strong) UIViewController *rightController;

@end

@implementation COUserController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.containerView.backgroundColor = [UIColor clearColor];
    self.rightView.hidden = YES;
    
    [self showRightItem:self.user.globalKey];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(projectReload:) name:OPProjectReloadNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showRightItem:(NSString *)globalKey
{
    if ([globalKey isEqualToString:[COSession session].user.globalKey]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_topbar_add"] style:UIBarButtonItemStylePlain target:self action:@selector(rightBtnAction:)];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showDetail
{
    if (self.detailController == nil) {
        [self performSegueWithIdentifier:@"userInfo" sender:nil];
        [self performSegueWithIdentifier:@"userDetail" sender:nil];
    }
    else {
        [self chageController:self.detailController];
        [self.detailController.tableView reloadData];
    }
}

- (void)showUserWithGlobalKey:(NSString *)globalKey
{
    [self showRightItem:globalKey];
    
    COAccountUserInfoRequest *request = [COAccountUserInfoRequest request];
    request.globalKey = globalKey;
    
    __weak typeof(self) weakself = self;
    [self showProgressHud];
    [request getWithSuccess:^(CODataResponse *responseObject) {
        [weakself dismissProgressHud];
        if ([weakself checkDataResponse:responseObject]) {
            weakself.user = responseObject.data;
            [weakself showDetail];
        }
    } failure:^(NSError *error) {
        [weakself showErrorInHudWithError:error];
    }];
}

- (void)chageController:(UIViewController *)destination
{
    self.rightView.hidden = NO;
    if (_rightController) {
        [_rightController.view removeFromSuperview];
        _rightController = nil;
    }
    
    destination.view.frame = _rightView.bounds;
    [_rightView addSubview:destination.view];
    //    [destination viewDidAppear:NO];
    _rightController = destination;
}

- (void)projectReload:(NSNotification *)n
{
    if ([self.user.globalKey isEqualToString:[COSession session].user.globalKey] && [_rightController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)_rightController;
        if ([nav.viewControllers[0] isKindOfClass:[COUserProjectsViewController class]]) {
            [nav popToRootViewControllerAnimated:NO];
            COUserProjectsViewController *vc = (COUserProjectsViewController *)nav.viewControllers[0];
            [vc loadProjects];
        }
    }
}

#pragma mark - Navigation
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"userInfo"]) {
        if (nil == _user) {
            return NO;
        }
        else return YES;
    }
    else if ([identifier isEqualToString:@"userDetail"]) {
        if (nil == _user) {
            return NO;
        }
        else return YES;
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"userInfo"]) {
        self.infoController = segue.destinationViewController;
        self.infoController.user = _user;
    }
    else if ([segue.identifier isEqualToString:@"userDetail"]) {
        self.detailController = segue.destinationViewController;
        self.detailController.user = _user;
    }
}

#pragma mark -
- (IBAction)rightBtnAction:(id)sender
{
    [COAddFriendsController popSelf];
}

@end
