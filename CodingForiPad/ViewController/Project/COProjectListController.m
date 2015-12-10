//
//  COProjectListVC.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/14.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COProjectListController.h"
#import "COProjectCell.h"
#import "COSegmentControl.h"
#import "COProjectRequest.h"
#import "COProjectController.h"
#import "COAccountRequest.h"
#import "ODRefreshControl.h"
#import "COAddProjectController.h"
#import "CORootViewController.h"
#import "COSession.h"
#import "COUnReadCountManager.h"

@interface COProjectListController () <SWTableViewCellDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet COSegmentControl *segmentControl;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableDictionary *data;
@property (nonatomic, strong) NSDictionary        *originTypeData;
@property (nonatomic, strong) NSString *type;

@property (nonatomic, assign) NSInteger selectProjectID;

@end

@implementation COProjectListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
 
    self.data = [NSMutableDictionary dictionary];
    _searchBar.delegate = self;

    __weak typeof(self) weakSelf = self;
    if (self.user) {
        NSArray *titles = nil;
        if (self.user.userId == [[[COSession session] user] userId]) {
            titles = @[@"我参与的", @"我收藏的"];
        }
        else {
            titles = @[@"TA参与的", @"TA收藏的"];
        }
        [_segmentControl setItemsWithTitleArray:titles
                                  selectedBlock:^(NSInteger index) {
                                      [weakSelf.searchBar resignFirstResponder];
                                      if (0 == index) {
                                          weakSelf.type = @"project";
                                      }
                                      else if (1 == index) {
                                          weakSelf.type = @"stared";
                                      }
                                      [weakSelf reloadData];
                                  }];
        
        self.type = @"all";
    }
    else {
        [_segmentControl setItemsWithTitleArray:@[@"全部", @"我参与的", @"我创建的"]
                                  selectedBlock:^(NSInteger index) {
                                      [weakSelf.searchBar resignFirstResponder];
                                      if (0 == index) {
                                          weakSelf.type = @"all";
                                      }
                                      else if (1 == index) {
                                          weakSelf.type = @"joined";
                                      }
                                      else {
                                          weakSelf.type = @"created";
                                      }
                                      [weakSelf reloadData];
                                  }];
        
        self.type = @"all";
    }
    
    [self setUpRefresh:self.tableView];
    
    [self loadData];
//    [self.refreshCtrl beginRefreshing];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(projectReload:) name:OPProjectListReloadNotification object:nil];
}

- (void)projectReload:(NSNotification *)n
{
    NSInteger projectId = [n.userInfo[@"projectID"] integerValue];
    NSString *icon = n.userInfo[@"icon"];
    for (NSArray *ary in self.data.allValues) {
        for (COProject *project in ary) {
            if (project.projectId == projectId) {
                project.icon = icon;
            }
        }
    }
    [self.tableView reloadData];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data
- (void)showEmptyView
{
    [COEmptyView removeFormView:self.view];
    
    if (self.user) {
        COEmptyView *view = [COEmptyView emptyViewForProject];
        [view showInView:self.view padding:UIEdgeInsetsMake(84.0, 0.0, 0.0, 0.0)];
    }
    else {
        if ([self.type isEqualToString:@"all"]) {
            COEmptyView *view = [COEmptyView emptyViewForCreateProject:^{
                [self createProject];
            }];
            [view showInView:self.view padding:UIEdgeInsetsMake(40.0, 0.0, 0.0, 0.0)];
        }
        else {
            COEmptyView *view = [COEmptyView emptyViewForCreateProject:nil];
            [view showInView:self.view padding:UIEdgeInsetsMake(40.0, 0.0, 0.0, 0.0)];
        }
    }
}

- (void)createProject
{
    [COAddProjectController popSelf];
}

- (void)removeEmptyView
{
    [COEmptyView removeFormView:self.view];
}

- (void)refresh
{
    COProjectController *controller = (COProjectController *)self.parentViewController;
    [controller showProject:nil];
    [self loadData];
}

- (void)reloadProject:(NSInteger)selectProjectID
{
    self.selectProjectID = selectProjectID;
    self.data = [NSMutableDictionary dictionary];
    [self loadData];
}

- (void)reloadProject
{
    self.data = [NSMutableDictionary dictionary];
    [self loadData];
}

- (void)reloadData
{
    if ([self.data[self.type] count] == 0) {
        if (self.data[self.type] == nil) {
            [self loadData];
        }
        else {
            [self showEmptyView];
        }
    }
    else {
        [self removeEmptyView];
    }
    [self.tableView reloadData];
}

- (void)loadData
{
    if (self.user) {
        COUserProjectsRequest *request = [COUserProjectsRequest request];
        request.type = self.type;
        request.page = 1;
        request.pageSize = 9999;
        request.globalKey = self.user.globalKey;
        
        __weak typeof(self) weakself = self;
        [request getWithSuccess:^(CODataResponse *responseObject) {
            if ([weakself checkDataResponse:responseObject]) {
                [weakself showData:responseObject.data];
            }
        } failure:^(NSError *error) {
            [weakself showErrorInHudWithError:error];
        }];
    }
    else {
        COProjectsRequest *request = [COProjectsRequest alloc];
        request.type = self.type;
        if ([request.type isEqualToString:@"all"]) {
            request.sort = @"hot";
        }
        request.page = 1;
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
}

- (void)showData:(NSArray *)data
{
    [self.refreshCtrl endRefreshing];
    // 常用项目置顶
    NSMutableArray *pin = [NSMutableArray array];
    NSMutableArray *unpin = [NSMutableArray array];
    NSMutableArray *all = [NSMutableArray array];
    
    for (COProject *one in data) {
        if (one.pin) {
            [pin addObject:one];
        }
        else {
            [unpin addObject:one];
        }
    }
    [all addObjectsFromArray:pin];
    [all addObjectsFromArray:unpin];
    
    if (all.count == 0) {
        [self showEmptyView];
    }
    else {
        [self removeEmptyView];
    }
    
    [self.data setObject:all forKey:self.type];
    self.originTypeData = [NSDictionary dictionaryWithDictionary:self.data];
    [self.tableView reloadData];
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
    for (COProject *project in self.originTypeData[@"all"]) {
        NSRange range = [[project.name lowercaseString] rangeOfString:[searchText lowercaseString] options:0];
        if (range.location != NSNotFound) {
            [result addObject:project];
        }
    }
    
    [self.data setObject:result forKey:self.type];
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
    searchBar.text = @"";
    self.data = [NSMutableDictionary dictionaryWithDictionary:self.originTypeData];
    [self.tableView reloadData];
    [self.searchBar resignFirstResponder];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data[self.type] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    COProjectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"COProjectCell" forIndexPath:indexPath];
    
    COProject *project = self.data[self.type][indexPath.row];
    if (project.pin) {
        [cell setRightUtilityButtons:[COProjectCell pinedRightButtons] WithButtonWidth:[COProjectCell cellHeight]];
    }
    else {
        [cell setRightUtilityButtons:[COProjectCell unPinRightButtons] WithButtonWidth:[COProjectCell cellHeight]];
    }
    cell.delegate = self;
    
    [cell assignWithProject:project];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row) {
        NSIndexPath *selectedIndexPath = [tableView indexPathForSelectedRow];
        if (!selectedIndexPath) {
            NSInteger selecetIndex = 0;
           if (_selectProjectID>0 && self.data && [self.data[self.type] count]>0) {
               NSInteger index = 0;
               for (COProject *project in self.data[self.type]) {
                    if (project.projectId == _selectProjectID) {
                        selecetIndex = index;
                        break;
                    }
                    index++;
                }
            }
            
            [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selecetIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            COProject *project = self.data[self.type][selecetIndex];
            if (_selectProjectID != project.projectId) {
                _selectProjectID = project.projectId;
                COProjectController *controller = (COProjectController *)self.parentViewController;
                [controller showProject:project];
                if (project.unReadActivitiesCount > 0) {
                    [[COUnReadCountManager manager] visitProject:project];
                }
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    COProjectController *controller = (COProjectController *)self.parentViewController;
    COProject *project = self.data[self.type][indexPath.row];
    _selectProjectID = project.projectId;
    [controller showProject:project];
    if (project.unReadActivitiesCount > 0) {
        [[COUnReadCountManager manager] visitProject:project];
    }
    
    [_searchBar resignFirstResponder];
//    if ([_searchBar isFirstResponder]) {
//        [_searchBar.delegate searchBarCancelButtonClicked:_searchBar];
//    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - SWTableViewCellDelegate
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    if (self.user) {
        return NO;
    }
    return YES;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    [cell hideUtilityButtonsAnimated:YES];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    // 钉住
    COProject *project = self.data[self.type][indexPath.row];
    COAccountProjectsPinRequest *request = [COAccountProjectsPinRequest request];
    request.ids = [NSString stringWithFormat:@"%ld", (long)project.projectId];
    __weak typeof(self) weakself = self;
    if (project.pin) {
        [request deleteWithSuccess:^(CODataResponse *responseObject) {
            [weakself loadData];
        } failure:^(NSError *error) {
            [weakself showErrorInHudWithError:error];
        }];
    }
    else {
        [request postWithSuccess:^(CODataResponse *responseObject) {
            [weakself loadData];
        } failure:^(NSError *error) {
            [weakself showErrorInHudWithError:error];
        }];
    }
}

@end
