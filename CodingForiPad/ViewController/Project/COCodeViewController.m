//
//  COCodeViewController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/24.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COCodeViewController.h"
#import "COGitRequest.h"
#import "COGitTree.h"
#import "COCodeCell.h"
#import "COCodePreViewController.h"
#import "COCodeFilterController.h"

#define DEGREES_TO_RADIANS(angle) ((angle)/180.0 * M_PI)

@interface COCodeViewController ()

@property (nonatomic, strong) NSArray *data;

@property (nonatomic, strong) UIViewController *popController;
@property (nonatomic, strong) UIButton *maskView;

@property (weak, nonatomic) IBOutlet UILabel *filterLabel;
@property (weak, nonatomic) IBOutlet UIImageView *filterIcon;

@end

@implementation COCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    self.filterLabel.text = self.ref;
    
    [self loadRefData];
    
    [self setUpRefresh:self.tableView];
    
    if (self.filePath) {
        NSArray *names = [self.filePath componentsSeparatedByString:@"/"];
        self.titleLabel.text = [NSString stringWithFormat:@"%@：%@", self.project.name, names.lastObject];
    }
    else {
        self.titleLabel.text = [NSString stringWithFormat:@"%@：代码", self.project.name];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data
- (void)reloadData
{
    [self loadRefData];
}

- (void)refresh
{
    [self loadRefData];
}

- (void)loadRefData
{
    COGitListBranchesRequest *request = [COGitListBranchesRequest request];
    request.backendProjectPath = self.backendProjectPath;
    
    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        [weakself.refreshCtrl endRefreshing];
        if ([weakself checkDataResponse:responseObject]) {
            [weakself handleRefData:responseObject.data];
        }
    } failure:^(NSError *error) {
        [weakself.refreshCtrl endRefreshing];
        //        [weakself showErrorInHudWithError:error];
        [weakself showErrorReloadView:^{
            [weakself loadRefData];
        } padding:UIEdgeInsetsMake(44.0, 0.0, 0.0, 0.0)];
    }];
}

- (void)loadData
{
    COGitTreeInfosRequest *request = [COGitTreeInfosRequest request];
    request.ref = self.ref;
    request.backendProjectPath = self.backendProjectPath;
    request.filePath = self.filePath;
    
    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        [weakself.refreshCtrl endRefreshing];
        [COEmptyView removeFormView:weakself.view];
        if ([weakself checkDataResponse:responseObject]) {
            [weakself showData:responseObject.data];
        }
    } failure:^(NSError *error) {
        [weakself.refreshCtrl endRefreshing];
//        [weakself showErrorInHudWithError:error];
        [weakself showErrorReloadView:^{
            [weakself loadData];
        } padding:UIEdgeInsetsMake(44.0, 0.0, 0.0, 0.0)];
    }];
}

- (void)handleRefData:(NSArray *)branches
{
    if (!branches || branches.count == 0) {
        [self showErrorWithStatus:@"git 仓库没有提交"];
        self.filterLabel.text = @"";
        return;
    } else if (branches.count == 1) {
        NSString *ref = ((COGitBranch *)branches[0]).name;
        self.ref = ref;
        self.filterLabel.text = ref;
    } else {
        COGitBranch *defaultBranch;
        for (COGitBranch *branch in branches) {
            if (branch.isDefaultBranch) {
                defaultBranch = branch;
                break;
            }
        }
        NSString *ref;
        if (defaultBranch) {
           ref = defaultBranch.name;
        } else {
            ref = ((COGitBranch *)branches[0]).name;
        }
        self.ref = ref;
        self.filterLabel.text = ref;
    }
    [self loadData];
}

- (void)showData:(COGitTreeInfo *)data
{
    self.data = data.infos;
    [self.tableView reloadData];
}

- (IBAction)backBtnAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    COCodeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"COCodeCell" forIndexPath:indexPath];
    
    [cell assignWithGitFile:_data[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    COGitFile *file = _data[indexPath.row];
    if ([file.mode isEqualToString:@"file"]
        || [file.mode isEqualToString:@"image"]) {
        // 预览文件
        COCodePreViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COCodePreViewController"];
        controller.project = self.project;
        controller.ref = self.ref;
        controller.backendProjectPath = self.backendProjectPath;
        controller.gitFile = file;
        [self.navigationController pushViewController:controller animated:YES];
    }
    else {
        COCodeViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COCodeViewController"];
        controller.backendProjectPath = self.backendProjectPath;
        controller.ref = self.ref;
        controller.filePath = file.path;
        controller.project = self.project;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - action
- (IBAction)branchBtnAction:(UIButton *)sender
{
    // 查看分支 标签
    COCodeFilterController *popoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"COCodeFilterController"];
    popoverVC.backendProjectPath = _backendProjectPath;
    popoverVC.ref = self.ref;
    __weak typeof(self) weakSelf = self;
    popoverVC.selectedBranchTagBlock = ^(NSString *branchTag){
        if ([weakSelf.ref isEqualToString:branchTag]) {
            [weakSelf dismissPopover];
            return;
        }
        weakSelf.ref = branchTag;
        weakSelf.filterLabel.text = branchTag;
        [weakSelf dismissPopover];
        [weakSelf loadData];
    };
    [self popoverController:popoverVC];
}

#pragma mark - pop
- (void)popoverController:(UIViewController *)controller
{
    self.filterIcon.transform = CGAffineTransformRotate(self.filterIcon.transform, DEGREES_TO_RADIANS(180));
    
    if (self.maskView == nil) {
        self.maskView = [[UIButton alloc] initWithFrame:self.view.bounds];
        _maskView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
        [_maskView addTarget:self action:@selector(dismissPopover) forControlEvents:UIControlEventTouchUpInside];
    }
    
    CGRect frame = CGRectMake(0, _maskView.frame.size.height - 350 - 48, _maskView.frame.size.width, 350);
    controller.view.frame = CGRectMake(0, _maskView.frame.size.height, _maskView.frame.size.width, 350);
    
    _maskView.alpha = 0;
    controller.view.alpha = 0;
    
    [self.view addSubview:_maskView];
    
    self.popController = controller;
    [self addChildViewController:controller];
    [_maskView addSubview:controller.view];
    
    [UIView animateWithDuration:0.1 animations:^{
        _maskView.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            controller.view.frame = frame;
            controller.view.alpha = 1;
        } completion:^(BOOL finished) {
        }];
    }];
}

- (void)dismissPopover
{
    self.filterIcon.transform = CGAffineTransformRotate(self.filterIcon.transform, DEGREES_TO_RADIANS(180));

    CGRect frame = _popController.view.frame;
    frame.origin.y = _maskView.frame.size.height;
    
    [_popController viewWillDisappear:YES];
    [UIView animateWithDuration:0.1 animations:^{
        _popController.view.frame = frame;
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
