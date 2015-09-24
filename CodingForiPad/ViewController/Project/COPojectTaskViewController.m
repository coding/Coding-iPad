//
//  COPojectTaskViewController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/28.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COPojectTaskViewController.h"
#import "COProjectRequest.h"
#import "COTaskRequest.h"
#import "COTask.h"
#import "COProjectTaskCell.h"
#import "COIconSegmentControl.h"
#import "COProject.h"
#import "COTaskDetailController.h"
#import "CORootViewController.h"
#import "COTaskListController.h"
#import "COAddTask2ProjectController.h"

@interface COPojectTaskViewController ()

@property (nonatomic, strong) NSArray *members;
@property (nonatomic, strong) NSArray *memberHasTask;
@property (nonatomic, strong) NSMutableArray *tasksAll;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *tasksDoing;
@property (nonatomic, strong) NSMutableArray *tasksFinish;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) NSString *userKey;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet COIconSegmentControl *iconSegment;

@end

@implementation COPojectTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tasksAll = [NSMutableArray array];
    self.tasksDoing = [NSMutableArray array];
    self.tasksFinish = [NSMutableArray array];
    self.titleLabel.text = [NSString stringWithFormat:@"%@：任务", self.title];
    self.page = 1;
    
    [self setUpRefresh:self.tableView];
    [self setUpLoadMore:self.tableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTask:) name:COTaskReloadNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishTask:) name:COTaskFinishedNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadTasks];
    [self loadMemebers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
- (void)reloadTask:(NSNotification *)n
{
    [self refresh];
}

- (void)finishTask:(NSNotification *)n
{
    COTask *task = n.object;
    for (COTask *one in self.tasksAll) {
        if (one.taskId == task.taskId) {
            one.status = task.status;
        }
    }
    
    [self parseTask];
    [self.tableView reloadData];
}

- (void)refresh
{
    self.page = 1;
    [self loadTasks];
}

- (void)loadMore
{
    self.page += 1;
    [self loadTasks];
}

- (void)loadMemebers
{
    COProjectMembersRequest *request = [COProjectMembersRequest request];
    request.projectId = self.projectId;
    request.page = self.page;
    request.pageSize = 100;
    
    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        if ([weakself checkDataResponse:responseObject]) {
            weakself.members = responseObject.data;
            [weakself loadMemeberTaskCount];
        }
    } failure:^(NSError *error) {
        [weakself showError:error];
    }];
}

- (void)loadMemeberTaskCount
{
    COProjectMemberTaskCountRequest *request = [COProjectMemberTaskCountRequest request];
    request.projectId = @(self.projectId);
    
    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        if ([weakself checkDataResponse:responseObject]) {
            weakself.memberHasTask = responseObject.data;
            [weakself showMembers];
        }
    } failure:^(NSError *error) {
        [weakself showError:error];
    }];
}

- (void)showMembers
{
    NSMutableArray *memberAvatar = [NSMutableArray arrayWithCapacity:_members.count];
    [memberAvatar addObject:@""];
    NSMutableArray *members = [NSMutableArray arrayWithCapacity:_members.count];
    
    for (COProjectMember *member in _members) {
        for (COProjectMemberTaskCount *task in _memberHasTask) {
            if (task.userId == member.userId) {
                [memberAvatar addObject:member.user.avatar];
                [members addObject:member];
            }
        }
    }
    
    self.members = [NSArray arrayWithArray:members];
    
    __weak typeof(self) weakSelf = self;
    [_iconSegment setItemsWithIconArray:memberAvatar selectedBlock:^(NSInteger index) {
        if (index == 0) {
            weakSelf.userKey = nil;
        }
        else {
            COProjectMember *m = weakSelf.members[index - 1];
            weakSelf.userKey = m.user.globalKey;
        }
        [weakSelf loadTasks];
    }];
}

- (void)loadTasks
{
    COTasksOfProjectRequest *request = [COTasksOfProjectRequest request];
    request.page = self.page;
    request.backendProjectPath = self.backendProjectPath;
    request.gloalKey = self.userKey;
    
    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        [COEmptyView removeFormView:weakself.view];
        if ([weakself checkDataResponse:responseObject]) {
            [weakself showTasks:responseObject.data];
        }
    } failure:^(NSError *error) {
        [weakself.refreshCtrl endRefreshing];
        [weakself.tableView.infiniteScrollingView stopAnimating];
        [weakself showErrorReloadView:^{
            [weakself loadTasks];
        } padding:UIEdgeInsetsMake(44.0, 0.0, 0.0, 0.0)];
    }];
}

- (void)showTasks:(NSArray *)tasks
{
    [self.refreshCtrl endRefreshing];
    [self.tableView.infiniteScrollingView stopAnimating];
    if (1 == self.page) {
        [self.tasksAll removeAllObjects];
        if (tasks.count == 0) {
            [self showEmptyView];
        }
        else {
            [self removeEmptyView];
        }
    }
    
    if ([tasks count] < 20) {
        self.tableView.showsInfiniteScrolling = NO;
    }
    else {
        self.tableView.showsInfiniteScrolling = YES;
    }
    
    [self.tasksAll addObjectsFromArray:tasks];
    [self parseTask];
    
    [self.tableView reloadData];
}

- (void)parseTask
{
    [_tasksDoing removeAllObjects];
    [_tasksFinish removeAllObjects];
    
    for (COTask *task in self.tasksAll) {
        if (task.status == 2) {
            [_tasksFinish addObject:task];
        }
        else {
            [_tasksDoing addObject:task];
        }
    }
    
    self.dataSource = [NSMutableArray array];
    if (self.tasksDoing.count > 0) {
        [self.dataSource addObject:self.tasksDoing];
    }
    if (self.tasksFinish.count > 0) {
        [self.dataSource addObject:self.tasksFinish];
    }
}

- (void)showEmptyView
{
    COEmptyView *view = [COEmptyView emptyViewForTask];
    [view showInView:self.view padding:UIEdgeInsetsMake(44.0, 0.0, 0.0, 0.0)];
}

- (void)removeEmptyView
{
    [COEmptyView removeFormView:self.view];
}

#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *data = self.dataSource[section];
    return data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    COProjectTaskCell *cell = [tableView dequeueReusableCellWithIdentifier:@"COTaskCell"];
    
    NSArray *data = self.dataSource[indexPath.section];
    [cell assignWithTask:data[indexPath.row] withLeft:NO];
    
    cell.clickedBlock = ^(COTask *task){
        if (task.isRequesting) {
            return;
        } else {
            task.isRequesting = YES;
        }
        COTaskStatusRequest *request = [COTaskStatusRequest request];
        request.taskId = @(task.taskId);
        request.status = task.status != 1 ? @1 : @2;
        
        __weak typeof(self) weakself = self;
        [request putWithSuccess:^(CODataResponse *responseObject) {
            if ([weakself checkDataResponse:responseObject]) {
                task.status = task.status != 1 ? 1 : 2;
                [weakself.tableView reloadData];
                task.isRequesting = NO;
            }
        } failure:^(NSError *error) {
            [weakself showErrorInHudWithError:error];
        }];
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 30)];
    backView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, CGRectGetWidth(tableView.frame) - 30, 30)];
    titleLbl.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    titleLbl.font = [UIFont systemFontOfSize:12];
    
    NSMutableArray *data = self.dataSource[section];
    if (data == self.tasksDoing) {
        titleLbl.text = @"进行中的任务";
    } else {
        titleLbl.text = @"已完成的任务";
    }
   
    [backView addSubview:titleLbl];
    return backView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    COTask *task = nil;
    
    NSMutableArray *data = self.dataSource[indexPath.section];
    task = data[indexPath.row];
    
    COTaskDetailController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COTaskDetailController"];
    [self.navigationController pushViewController:controller animated:YES];
    [controller showTask:task];
}

#pragma mark - click
- (void)doneBtnAction:(UIButton *)sender
{
}

- (IBAction)backBtnAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)newTaskAction:(id)sender
{
    UINavigationController *popoverVC = [COAddTask2ProjectController popSelf];
    COAddTask2ProjectController *vc = popoverVC.viewControllers.firstObject;
    [vc createTaskForProject:self.project];
}

@end
