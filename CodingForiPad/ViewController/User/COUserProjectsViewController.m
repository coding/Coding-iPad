//
//  COUserProjectsViewController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/8/12.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COUserProjectsViewController.h"
#import "COUserProjectCell.h"
#import "COSession.h"
#import "COProjectRequest.h"
#import "COProjectDetailController.h"

@interface COUserProjectsViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *joinedProjects;
@property (nonatomic, strong) NSMutableArray *starProjects;
@property (nonatomic, strong) NSMutableArray *projects;

@end

@implementation COUserProjectsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    if (self.user.userId == [[[COSession session] user] userId]) {
        [self.segmentedControl setTitle:@"我参与的" forSegmentAtIndex:0];
        [self.segmentedControl setTitle:@"我收藏的" forSegmentAtIndex:1];
    }
    else {
        [self.segmentedControl setTitle:@"TA参与的" forSegmentAtIndex:0];
        [self.segmentedControl setTitle:@"TA收藏的" forSegmentAtIndex:1];
    }
    
    [self.segmentedControl addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.segmentedControl setSelectedSegmentIndex:0];
    
    [self loadProjects];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (IBAction)segmentValueChanged:(id)sender
{
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        self.projects = self.joinedProjects;
    }
    else {
        self.projects = self.starProjects;
    }
    
    if (self.projects == nil) {
        [self loadProjects];
    } else {
        if (self.projects.count > 0) {
            [self removeEmptyView];
        } else {
            [self showEmptyView];
        }
        [self.tableView reloadData];
    }
}

- (void)loadProjects
{
    COUserProjectsRequest *request = [COUserProjectsRequest request];
    if (0 == self.segmentedControl.selectedSegmentIndex) {
        request.type = @"project";
    }
    else {
        request.type = @"stared";
    }
    request.page = 1;
    request.pageSize = 9999;
    request.globalKey = self.user.globalKey;
    
    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        if ([weakself checkDataResponse:responseObject]) {
            [weakself showData:responseObject.data type:request.type];
        } else {
            [weakself showErrorReloadView:^{
                [weakself loadProjects];
            } padding:UIEdgeInsetsMake(44.0, 0.0, 0.0, 0.0)];
        }
    } failure:^(NSError *error) {
        [weakself showErrorReloadView:^{
            [weakself loadProjects];
        } padding:UIEdgeInsetsMake(44.0, 0.0, 0.0, 0.0)];
        [weakself showErrorInHudWithError:error];
    }];
}

- (void)showEmptyView
{
    [COEmptyView removeFormView:self.view];
    
    COEmptyView *view = [COEmptyView emptyViewForProject];
    [view showInView:self.view padding:UIEdgeInsetsMake(40.0, 0.0, 0.0, 0.0)];
}

- (void)removeEmptyView
{
    [COEmptyView removeFormView:self.view];
}

- (void)showData:(NSArray *)data type:(NSString *)type
{
    [self.refreshCtrl endRefreshing];
    // 常用项目置顶
    
    if (data.count == 0) {
        [self showEmptyView];
    }
    else {
        [self removeEmptyView];
    }
    
    if ([type isEqualToString:@"project"]) {
        self.joinedProjects = [NSMutableArray arrayWithArray:data];
        self.projects = self.joinedProjects;
    }
    else {
        self.starProjects = [NSMutableArray arrayWithArray:data];
        self.projects = self.starProjects;
    }
    
    [self.tableView reloadData];
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.projects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    COUserProjectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"COUserProjectCell"];
    [cell assignWithProject:self.projects[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    COProjectDetailController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COProjectDetailController"];
    [self.navigationController pushViewController:controller animated:YES];
    [controller showProject:self.projects[indexPath.row]];
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
