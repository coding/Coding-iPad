//
//  COAddTask2ProjectController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/8.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COAddTask2ProjectController.h"
#import "COProjectCell.h"
#import "COProjectRequest.h"
#import "UIViewController+Utility.h"
#import "CORootViewController.h"
#import "COAddTaskViewController.h"
#import "COTask.h"
#import "COSession.h"

@interface COAddTask2ProjectController () <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) NSMutableArray *originData;
@property (nonatomic, strong) COTask *task;

@end

@implementation COAddTask2ProjectController

+ (UINavigationController *)popSelf
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *popoverVC = [storyboard instantiateViewControllerWithIdentifier:@"addTaskNav"];
    [[CORootViewController currentRoot] popoverController:popoverVC withSize:CGSizeMake(kPopWidth, kPopHeight)];
    return popoverVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.searchBar.delegate = self;
    self.data = @[].mutableCopy;
    
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadData
{
    COProjectsRequest *request = [COProjectsRequest request];
    request.type = @"all";
    request.sort = @"hot";
    request.page = 1;// 增加页面呢
    request.pageSize = 9999;
    
    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        if ([weakself checkDataResponse:responseObject]) {
            [weakself showData:responseObject.data];
        }
    } failure:^(NSError *error) {
        [weakself showErrorInHudWithError:error];
    }];
}

- (void)showData:(NSArray *)data
{
    data = [data filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isPublic == %d", NO]];
    if (data.count <= 0) {
        return;
    }
    self.originData = [NSMutableArray arrayWithArray:data];
    // 页面判断
    [self.data addObjectsFromArray:data];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    COProjectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"COProjectCell" forIndexPath:indexPath];
    
    [cell assignWithProjectSimple:self.data[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [_searchBar resignFirstResponder];
    
    COProject *project = self.data[indexPath.row];
    [self createTaskForProject:project];
}

- (void)createTaskForProject:(COProject *)project
{
    if (!self.task) {
        self.task = [COTask new];
        _task.creator = [COSession session].user;   // 创建者，自己
        _task.content = @"";                        // 概要，空
        _task.priority = 2;                         // 优先级，正常处理
        _task.deadline = nil;                       // 截止日期，未指定
        _task.owner = [COSession session].user;     // 管理者，默认自己
        _task.ownerId = _task.owner.userId;
        _task.hasDescription = FALSE;               // 描述，无
    }

    if (_task.project && _task.project.projectId != project.projectId) {
        _task.owner = [COSession session].user;     // 管理者，回到自己
        _task.ownerId = _task.owner.userId;
    }
    
    _task.project = project;                        // 指定项目
    _task.projectId = project.projectId;
    
    // 进入下一步
    COAddTaskViewController *popoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"COAddTaskViewController"];
    popoverVC.task = _task;
    [self.navigationController pushViewController:popoverVC animated:YES];
}

#pragma mark -
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
    
    for (id cc in [searchBar.subviews[0] subviews]) {
        if ([cc isKindOfClass:[UIButton class]]) {
            UIButton *sbtn = (UIButton *)cc;
            [sbtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [sbtn setTitleColor:[UIColor colorWithRed:59/255.0 green:189/255.0 blue:121/255.0 alpha:1.0] forState:UIControlStateNormal];
        }
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSMutableArray *result = [NSMutableArray array];
    for (COProject *project in self.originData) {
        NSRange range = [[project.name lowercaseString] rangeOfString:[searchText lowercaseString] options:0];
        if (range.location != NSNotFound) {
            [result addObject:project];
            continue;
        }
        range = [[project.ownerUserName lowercaseString] rangeOfString:[searchText lowercaseString] options:0];
        if (range.location != NSNotFound) {
            [result addObject:project];
            continue;
        }
    }
    
    self.data = [NSMutableArray arrayWithArray:result];
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
    searchBar.text = @"";
    self.data = [NSMutableArray arrayWithArray:self.originData];
    [self.tableView reloadData];
    [self.searchBar resignFirstResponder];
}

#pragma mark - action
- (IBAction)cancelBtnAction:(UIButton *)sender
{
    [[CORootViewController currentRoot] dismissPopover];
}

@end
