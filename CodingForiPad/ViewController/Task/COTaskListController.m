//
//  COTaskListController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/24.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COTaskListController.h"
#import "COTaskRequest.h"
#import "COSegmentControl.h"
#import "COTask.h"
#import "COProjectTaskCell.h"
#import "COTaskController.h"

@interface COTaskListController ()

@property (nonatomic, strong) NSMutableArray *tasksAll;
@property (nonatomic, strong) NSMutableArray *tasksDoing;
@property (nonatomic, strong) NSMutableArray *tasksFinish;
@property (nonatomic, assign) NSInteger doningIndex;
@property (nonatomic, assign) NSInteger finishIndex;
@property (nonatomic, assign) NSInteger indexType;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet COSegmentControl *segmentControl;

@property (weak, nonatomic) IBOutlet UILabel *hLabel;

@property (nonatomic, assign) NSInteger selectTaskID;

@end

@implementation COTaskListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tasksAll = [NSMutableArray array];
    self.tasksDoing = [NSMutableArray array];
    self.tasksFinish = [NSMutableArray array];
    self.doningIndex = 1;
    self.finishIndex = 1;
    self.indexType = 0;
  
    __weak typeof(self) weakSelf = self;
    [_segmentControl setItemsWithTitleArray:@[@"正在进行", @"已完成的"]
                              selectedBlock:^(NSInteger index) {
                                  weakSelf.indexType = index;
                                  if (index == 1) {
                                      if (weakSelf.tasksFinish.count == 0) {
                                          [weakSelf refresh];
                                      }
                                      else {
                                          [weakSelf.tableView reloadData];
                                      }
                                  }
                                  else {
                                      [weakSelf.tableView reloadData];
                                  }
                              }];
    
    [self refresh];
    
    [self setUpRefresh:self.tableView];
    [self setUpLoadMore:self.tableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTask:) name:COTaskReloadNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark 
- (void)showEmptyView
{
    COEmptyView *view = [COEmptyView emptyViewForTask];
    [view showInView:self.view padding:UIEdgeInsetsMake(44.0, 0.0, 0.0, 0.0)];
}

- (void)removeEmptyView
{
    [COEmptyView removeFormView:self.view];
}

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
    
    [self.tableView reloadData];
}

- (void)refresh
{
    if (self.indexType == 0) {
        self.doningIndex = 1;
        [self loadDoing];
    }
    else {
        self.finishIndex = 1;
        [self loadFinish];
    }
}

- (void)loadMore
{
    if (self.indexType == 0) {
        [self loadDoing];
        self.doningIndex += 1;
    }
    else {
        self.finishIndex += 1;
        [self loadFinish];
    }
}

- (void)loadDoing
{
    COMyTasksRequest *request = [COMyTasksRequest request];
    request.type = @"processing";
    request.page = self.doningIndex;
    request.pageSize = 20;
    
    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        if ([weakself checkDataResponse:responseObject]) {
            [weakself showDoingTasks:responseObject];
        }
    } failure:^(NSError *error) {
        [weakself showErrorInHudWithError:error];
    }];
}

- (void)showDoingTasks:(CODataResponse *)response
{
    [self.refreshCtrl endRefreshing];
    [self.tableView.infiniteScrollingView stopAnimating];
    if (0 == self.indexType) {
        if (self.doningIndex <= [response.extraData[@"totalPage"] integerValue]) {
            self.tableView.infiniteScrollingView.enabled = YES;
        }
        else {
            self.tableView.infiniteScrollingView.enabled = NO;
        }
    }
    
    NSArray *tasks = response.data;
    
    if (1 == self.doningIndex) {
        [self.tasksDoing removeAllObjects];
        if (tasks.count == 0) {
            [self showEmptyView];
        }
        else {
            [self removeEmptyView];
        }
    }
    
    [self.tasksDoing addObjectsFromArray:tasks];
    
    if (0 == self.indexType) {
        [self.tableView reloadData];
    }
}

- (void)loadFinish
{
    COMyTasksRequest *request = [COMyTasksRequest request];
    request.page = self.finishIndex;
    request.type = @"done";
    request.pageSize = 20;
    
    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        if ([weakself checkDataResponse:responseObject]) {
            [weakself showFinishTasks:responseObject];
        }
    } failure:^(NSError *error) {
        [weakself showErrorInHudWithError:error];
    }];
}

- (void)showFinishTasks:(CODataResponse *)response
{
    [self.refreshCtrl endRefreshing];
    [self.tableView.infiniteScrollingView stopAnimating];
    if (1 == self.indexType) {
        if (self.finishIndex <= [response.extraData[@"totalPage"] integerValue]) {
            self.tableView.infiniteScrollingView.enabled = YES;
        }
        else {
            self.tableView.infiniteScrollingView.enabled = NO;
        }
    }
    
    NSArray *tasks = response.data;
    
    if (1 == self.finishIndex) {
        [self.tasksFinish removeAllObjects];
        if (tasks.count == 0) {
            [self showEmptyView];
        }
        else {
            [self removeEmptyView];
        }
    }
    
    [self.tasksFinish addObjectsFromArray:tasks];
    
    if (1 == self.indexType) {
        [self.tableView reloadData];
    }
}
    
#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == _indexType) {
        return self.tasksDoing.count;
    }
    
    return self.tasksFinish.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    COProjectTaskCell *cell = [tableView dequeueReusableCellWithIdentifier:@"COTaskCell"];
    
    if (0 == _indexType) {
        [cell assignWithTask:_tasksDoing[indexPath.row] withLeft:YES];
    } else {
        [cell assignWithTask:_tasksFinish[indexPath.row] withLeft:YES];
    }
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    COTask *task;
    if (0 == _indexType) {
       task = _tasksDoing[indexPath.row];
    } else {
       task = _tasksFinish[indexPath.row];
    }
    _hLabel.text = [NSString stringWithFormat:@"      %@", task.content];
    [_hLabel setNeedsLayout];
    [_hLabel layoutIfNeeded];
    CGFloat height = _hLabel.frame.size.height;
    if ([task.deadline length] > 0) {
        height += 20 + 36 + 12 + 20;
    } else {
        height += 20 + 18 + 12 + 20;
    }
    return height;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row) {
        NSIndexPath *selectedIndexPath = [tableView indexPathForSelectedRow];
        if (!selectedIndexPath) {
            NSInteger selecetIndex = 0;
            if (0 == _indexType) {
                if (_selectTaskID>0 && _tasksDoing && [_tasksDoing count]>0) {
                    NSInteger index = 0;
                    for (COTask *task in _tasksDoing) {
                        if (task.taskId == _selectTaskID) {
                            selecetIndex = index;
                            break;
                        }
                        index++;
                    }
                }
            } else {
                if (_selectTaskID>0 && _tasksFinish && [_tasksFinish count]>0) {
                    NSInteger index = 0;
                    for (COTask *task in _tasksFinish) {
                        if (task.taskId == _selectTaskID) {
                            selecetIndex = index;
                            break;
                        }
                        index++;
                    }
                }
            }

            [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selecetIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            COTask *task = nil;
            if (0 == _indexType) {
                task = _tasksDoing[selecetIndex];
            } else {
                task = _tasksFinish[selecetIndex];
            }
            COTaskController *controller = (COTaskController *)self.parentViewController;
            [controller showTask:task];
            _selectTaskID = task.taskId;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    COTask *task = nil;
    if (0 == _indexType) {
        task = _tasksDoing[indexPath.row];
    } else {
        task = _tasksFinish[indexPath.row];
    }
    COTaskController *controller = (COTaskController *)self.parentViewController;
    [controller showTask:task];
    _selectTaskID = task.taskId;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end
