//
//  COMemberViewController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/24.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COMemberViewController.h"
#import "COProjectRequest.h"
#import "COMemberCell.h"
#import "COSession.h"
#import "COProjectController.h"
#import "COMessageViewController.h"
#import "COProject.h"
#import "COMemberAddController.h"

@interface COMemberViewController ()<UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titileLabel;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;

@property (nonatomic, strong) UIViewController *popController;
@property (nonatomic, strong) UIButton *maskView;
@property (nonatomic, strong) UIView *popShadowView;

@property (nonatomic, strong) NSMutableArray *members;

@end

@implementation COMemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    _titileLabel.text = _project ? [NSString stringWithFormat:@"%@：成员", _project.name] : @"成员";
    _addBtn.hidden = [COSession session].user.userId == _project.ownerId ? FALSE : TRUE;
    [self loadMemebers];
    
    [self setUpRefresh:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)quitProject
{
    COProjectQuitRequest *quit = [COProjectQuitRequest request];
    quit.projectId = @(_project.projectId);
    __weak typeof(self) weakself = self;
    [quit postWithSuccess:^(CODataResponse *responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself showSuccess:@"成功退出项目"];
            [[NSNotificationCenter defaultCenter] postNotificationName:OPProjectReloadNotification object:nil];
        });
    } failure:^(NSError *error) {
        [weakself showErrorInHudWithError:error];
    }];
}

#pragma mark -
- (void)refresh
{
    [self loadMemebers];
}

- (void)loadMemebers
{
    COProjectMembersRequest *request = [COProjectMembersRequest request];
    request.projectId = _project.projectId;
    request.page = 1;
    request.pageSize = 100;
    
    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        [weakself.refreshCtrl endRefreshing];
        [COEmptyView removeFormView:weakself.view];
        if ([weakself checkDataResponse:responseObject]) {
            [weakself showMembers:responseObject.data];
        }
    } failure:^(NSError *error) {
        [weakself.refreshCtrl endRefreshing];
//        [weakself showError:error];
        [weakself showErrorReloadView:^{
            [weakself loadMemebers];
        } padding:UIEdgeInsetsMake(44.0, 0.0, 0.0, 0.0)];
    }];
}

- (void)showMembers:(NSArray *)members
{
    self.members = members.mutableCopy;
    [self.tableView reloadData];
}

#pragma mark - action
- (IBAction)cellAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    CGPoint location            = [btn convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath      = [self.tableView indexPathForRowAtPoint:location];
    COProjectMember *member = self.members[indexPath.row];
    if ([COSession session].user.userId == member.userId) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"确定退出项目？" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确认退出" otherButtonTitles:@"取消", nil];
        sheet.tag = -1;
        [sheet showInView:self.view];
    }
    else {
        COMessageViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COMessageViewController"];
        controller.globalKey = member.user.globalKey;
        [self.navigationController pushViewController:controller animated:YES];
        [controller showMessage:nil];
    }
}

- (IBAction)backBtnAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addBtnAction:(UIButton *)sender
{
    COMemberAddController *popoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"COMemberAddController"];
    popoverVC.project = _project;
    if (_members.count > 0) {
        [popoverVC configAddedArrayWithMembers:_members];
    }
    __weak typeof(self) weakSelf = self;
    popoverVC.popSelfBlock = ^(){
        [weakSelf loadMemebers];
    };
    [self popoverController:popoverVC withSize:CGSizeMake(kPopWidthS, kPopHeightS)];
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _members.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    COMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:@"COMemberCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell assignWithMember:_members[indexPath.row]];
    cell.actioBtn.tag = indexPath.row;
    [cell.actioBtn addTarget:self action:@selector(cellAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

//-----------------------------------Editing
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"移除成员";
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL canEdit = NO;
    if (_project.ownerId == [COSession session].user.userId) {
        COProjectMember *curMember = [_members objectAtIndex:indexPath.row];
        canEdit = (curMember.userId != [COSession session].user.userId);
    }
    return canEdit;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView setEditing:NO animated:YES];
   
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"移除该成员后，他将不再显示在项目中" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确认移除" otherButtonTitles:@"取消", nil];
    sheet.tag = indexPath.row;
    [sheet showInView:self.view];
}

- (void)removeMember:(NSInteger)index
{
    COProjectMember *curMember = [_members objectAtIndex:index];
    NSLog(@"remove - ProjectMember : %@", curMember.user.name);
    COProjectMemberKickoutRequest *request = [COProjectMemberKickoutRequest request];
    request.projectId = @(_project.projectId);
    request.userId = @(curMember.userId);
    __weak typeof(self) weakself = self;
    [self showProgressHudWithMessage:@"正在移除成员"];
    [request postWithSuccess:^(CODataResponse *responseObject) {
        if ([weakself checkDataResponse:responseObject]) {
            [weakself showSuccess:@"移除成员成功"];
            [weakself loadMemebers];
        }
    } failure:^(NSError *error) {
        [weakself showErrorInHudWithError:error];
    }];
}

#pragma mark -
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        if (actionSheet.tag == -1) {
            [self quitProject];
        } else {
            [self removeMember:actionSheet.tag];
        }
    }
}

#pragma mark - pop
- (void)popoverController:(UIViewController *)controller withSize:(CGSize)size
{
    BOOL reset = FALSE;
    if (self.popController) {
        reset = TRUE;
        _popShadowView.backgroundColor = [UIColor clearColor];
        [_popController.view removeFromSuperview];
        [_popController removeFromParentViewController];
        self.popController = nil;
    }
    
    if (self.maskView == nil) {
        self.maskView = [[UIButton alloc] initWithFrame:self.view.bounds];
        _maskView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
        [_maskView addTarget:self action:@selector(dismissBtnAction) forControlEvents:UIControlEventTouchUpInside];
        
        _popShadowView = [[UIView alloc] initWithFrame:CGRectZero];
        _popShadowView.layer.shadowOpacity = 0.5;
        _popShadowView.layer.shadowRadius = 4;
        _popShadowView.layer.cornerRadius = 4;
        _popShadowView.layer.shadowOffset = CGSizeMake(1, 3);
        _popShadowView.layer.shadowColor = [UIColor blackColor].CGColor;
        [_maskView addSubview:_popShadowView];
    }
    
    CGRect frame = CGRectMake((_maskView.frame.size.width - size.width) / 2, (_maskView.frame.size.height - size.height) / 2, size.width, size.height);
    controller.view.frame = frame;
    _popShadowView.frame = frame;
    
    controller.view.layer.cornerRadius = 4;
    controller.view.layer.masksToBounds = TRUE;
    
    if (!reset) {
        _maskView.alpha = 0;
        controller.view.alpha = 0;
    }
    
    [self.view addSubview:_maskView];
    
    self.popController = controller;
    [self addChildViewController:controller];
    [_maskView addSubview:controller.view];
    
    _popShadowView.backgroundColor = [UIColor clearColor];
    
    if (reset) {
        [UIView animateWithDuration:0.2 animations:^{
            controller.view.alpha = 1;
        } completion:^(BOOL finished) {
            _popShadowView.backgroundColor = [UIColor whiteColor];
        }];
    } else {
        [UIView animateWithDuration:0.1 animations:^{
            _maskView.alpha = 1;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                controller.view.alpha = 1;
            } completion:^(BOOL finished) {
                _popShadowView.backgroundColor = [UIColor whiteColor];
            }];
        }];
    }
}

- (void)dismissPopover
{
    [_popController viewWillDisappear:YES];
    _popShadowView.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:0.1 animations:^{
        _popController.view.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            _maskView.alpha = 0;
        } completion:^(BOOL finished) {
            [_popController.view removeFromSuperview];
            [_popController removeFromParentViewController];
            [_maskView removeFromSuperview];
            self.popController = nil;
        }];
    }];
}

- (void)dismissBtnAction
{
    [_popController.view endEditing:YES];
}

@end
