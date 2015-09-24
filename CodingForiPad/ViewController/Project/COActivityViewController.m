//
//  COActivityViewController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/24.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COActivityViewController.h"
#import "COActivityCell.h"
#import "COProjectRequest.h"
#import "COProjectActivity.h"
#import "COSession.h"
#import <math.h>
#import "COSegmentControl.h"
#import "COUtility.h"
#import "COProjectDetailController.h"
#import "COTaskDetailController.h"
#import "COTopicDetailController.h"
#import "COUserController.h"
#import "COFileViewController.h"
#import "COFilePreViewController.h"
#import "NSString+Common.h"
#import "UIViewController+Link.h"
#import "COUnReadCountManager.h"

#define kCODefaultLastId 99999999
#define kCOOffset @"offset"
#define kCOLoadMore @"more"

@interface COActivityViewController ()

@property (nonatomic, strong) NSMutableDictionary *data;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSArray *typeArray;
@property (nonatomic, strong) NSNumber *lastId;
@property (nonatomic, strong) NSMutableDictionary *tableViewStatus;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet COSegmentControl *segmentControl;

@end

@implementation COActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.titleLabel.text = [NSString stringWithFormat:@"%@：动态", self.title];
    self.type = @"all";
    self.data = [NSMutableDictionary dictionary];
    self.tableViewStatus = [NSMutableDictionary dictionary];
    
    self.typeArray = @[@"all", @"task", @"topic", @"file", @"code", @"other"];
//    __weak typeof(self) weakSelf = self;
    [_segmentControl setItemsWithTitleArray:@[@"所有", @"任务", @"讨论", @"文档", @"代码", @"其他"]
                              selectedBlock:^(NSInteger index) {
                                  [self saveStatus];
                                  self.type = self.typeArray[index];
                                  [self loadStatus];
                                  self.lastId = [self currentLastId];
                                  NSMutableArray *typeData = self.data[self.type];
                                  if (typeData) {
                                      [self.tableView reloadData];
                                  }
                                  else {
                                      [self loadData];
                                  }
                              }];
    
    [self loadData];
    [self setUpRefresh:self.tableView];
    [self setUpLoadMore:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveStatus
{
    CGFloat offset = self.tableView.contentOffset.y;
    BOOL loadMore = self.tableView.infiniteScrollingView.enabled;
    
    NSDictionary *status = @{kCOOffset : @(offset), kCOLoadMore : @(loadMore)};
    self.tableViewStatus[self.type] = status;
}

- (void)loadStatus
{
    CGFloat offset = 0.0;
    BOOL loadMore = NO;
    NSDictionary *status = self.tableViewStatus[self.type];
    
    if (status) {
        offset = [status[kCOOffset] floatValue];
        loadMore = [status[kCOLoadMore] boolValue];
    }
    
    self.tableView.contentOffset = CGPointMake(0.0, offset);
    self.tableView.infiniteScrollingView.enabled = loadMore;
}

#pragma mark -
- (void)refresh
{
    self.lastId = @(kCODefaultLastId);
    [self loadData];
}

- (void)loadMore
{
    self.lastId = [self currentLastId];
    [self loadData];
}

- (void)loadData
{
    COProjectActivitiesRequest *request = [COProjectActivitiesRequest request];
    request.projectId = @(self.projectId);
    request.lastId = self.lastId;
    request.userId = @([COSession session].user.userId);
    request.type = self.type;
    
    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        [weakself.refreshCtrl endRefreshing];
        [weakself.tableView.infiniteScrollingView stopAnimating];
        if ([weakself checkDataResponse:responseObject]) {
            [weakself showData:responseObject.data];
        }
    } failure:^(NSError *error) {
        [weakself.refreshCtrl endRefreshing];
        [weakself showError:error];
    }];
}

- (NSTimeInterval)timestampToDay:(NSTimeInterval)timestamp
{
    NSTimeInterval day = round(timestamp / (24 * 60 * 60.0 * 1000));
    return day;
}

- (NSArray *)parseData:(NSArray *)data
{
    if ([data count] == 0) {
        return nil;
    }
    
    COProjectActivity *activity = [data firstObject];
    NSMutableArray *days = [NSMutableArray array];
    NSMutableArray *day = [NSMutableArray array];
    NSTimeInterval curDay = [self timestampToDay:activity.createdAt];
    
    [day addObject:activity];
    [days addObject:day];
    for (NSInteger i = 1; i < [data count]; i++) {
        COProjectActivity *one = data[i];
        if (curDay == [self timestampToDay:one.createdAt]) {
            [day addObject:one];
        }
        else {
            day = [NSMutableArray array];
            [day addObject:one];
            [days addObject:day];
            curDay = [self timestampToDay:one.createdAt];
        }
    }
    
    return [NSArray arrayWithArray:days];
}

- (void)showData:(NSArray *)data
{
    if ([data count] == 0) {
        self.tableView.infiniteScrollingView.enabled = NO;
        return;
    }
    
    // TODO: 返回数据条目
    if ([data count] < 20) {
        self.tableView.infiniteScrollingView.enabled = NO;
    }
    else {
        self.tableView.infiniteScrollingView.enabled = YES;
    }
    
    NSMutableArray *typeData = self.data[self.type];
    if (typeData) {
        if ([self.lastId integerValue] == kCODefaultLastId) {
            [typeData removeAllObjects];
        }
    }
    else {
        typeData = [NSMutableArray array];
        [self.data setObject:typeData forKey:self.type];
    }
    [typeData addObjectsFromArray:[self parseData:data]];
    
    [self.tableView reloadData];
}

- (NSNumber *)currentLastId
{
    id typeData = _data[self.type];
    if (typeData) {
        NSArray *sectionData = [typeData lastObject];
        COProjectActivity *activity = [sectionData lastObject];
        return @(activity.activityID);
    }
    return @(kCODefaultLastId);
}

#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_data[self.type] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data[self.type][section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    COActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"COActivityCell"];
    
    [cell assignWithActivity:self.data[self.type][indexPath.section][indexPath.row]];
    NSInteger index = indexPath.row;
    for (NSInteger i = 0; i<indexPath.section; i++) {
        index += [self.data[self.type][i] count];
    }
    if ([self.type isEqualToString:@"all"] && index < _project.unReadActivitiesCount) {
         cell.dot.layer.borderColor = [UIColor colorWithRed:59/255.0 green:189/255.0 blue:121/255.0 alpha:1.0].CGColor;
    } else {
        cell.dot.layer.borderColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0].CGColor;
    }
    cell.lineUp.hidden = indexPath.row == 0 ? TRUE : FALSE;
    cell.topHeightLayout.constant = cell.lineUp.hidden ? 0 : 0;
    cell.lineDown.hidden = indexPath.row == [self.data[self.type][indexPath.section] count] - 1 ? TRUE : FALSE;
    cell.lineBottom.hidden = cell.lineDown.hidden;
    
    cell.avatarAction = ^void(COUser *user) {
        [self showUser:user];
    };
    
    cell.linkAction = ^void(id obj) {
        HtmlMediaItem *item = obj;
        [self analyseLinkStr:item.href];
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat h = [self heightForBasicCellAtIndexPath:indexPath];
    // 第一个和最后一个高度需要增加一点点
    if (indexPath.row == 0) h += 8;
    if (indexPath.row == [self.data[self.type][indexPath.section] count] - 1) h += 8;
    return h;
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static COActivityCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:@"COActivityCell"];
    });
    
    
    COProjectActivity *activity = self.data[self.type][indexPath.section][indexPath.row];
    if (activity.height == 0.0) {
        [sizingCell assignWithActivity:activity];
    }
    
    return activity.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 8, CGRectGetWidth(tableView.frame), 40)];
    backView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, CGRectGetWidth(tableView.frame) - 40, 40)];
    titleLbl.textColor = [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0];
    titleLbl.font = [UIFont systemFontOfSize:14];
    
    COProjectActivity *activity = [_data[self.type][section] firstObject];
    titleLbl.text = [COUtility timestampToDayWithWeek:activity.createdAt];
    [backView addSubview:titleLbl];
    return backView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    COProjectActivity *activity = self.data[self.type][indexPath.section][indexPath.row];
    NSString *type = activity.targetType;
    SEL parser = NSSelectorFromString([NSString stringWithFormat:@"show%@:", type]);
    if ([self respondsToSelector:parser]) {
        @try {
            IMP imp = [self methodForSelector:parser];
            void (*function)(id, SEL, COProjectActivity *) = (__typeof__(function))imp;
            function(self, parser, activity);
        }
        @catch (NSException *exception) {
            // TODO: 处理错误数据
        }
        @finally {
        }
    }
}

#pragma mark - Show Activity
- (void)showProject:(COProjectActivity *)activity
{
//    COProjectDetailController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COProjectDetailController"];
}

- (void)showProjectMember:(COProjectActivity *)activity
{
    if ([activity.action isEqualToString:@"quit"]) {
        //退出项目
        
    }else{
        //添加了某成员
        COUserController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COUserController"];
        [self rootPushViewController:controller animated:YES];
        [controller showUserWithGlobalKey:activity.targetUser.globalKey];
    }
}

- (void)showTask:(COProjectActivity *)activity
{
    if (![activity.action isEqualToString:@"delete"]) {
        COTaskDetailController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COTaskDetailController"];
        [self.navigationController pushViewController:controller animated:YES];
        [controller showWithTaskPath:activity.task.path];
    }
}

- (void)showTaskComment:(COProjectActivity *)activity
{
    if (![activity.action isEqualToString:@"delete"]) {
        COTaskDetailController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COTaskDetailController"];
        [self.navigationController pushViewController:controller animated:YES];
        [controller showWithTaskPath:activity.task.path];
    }
//    Task *task = proAct.task;
//    NSArray *pathArray = [proAct.project.full_name componentsSeparatedByString:@"/"];
//    if (pathArray.count >= 2) {
//        EditTaskViewController *vc = [[EditTaskViewController alloc] init];
//        vc.myTask = [Task taskWithBackend_project_path:[NSString stringWithFormat:@"/user/%@/project/%@", pathArray[0], pathArray[1]] andId:task.id.stringValue];
//        [self.navigationController pushViewController:vc animated:YES];
//    }else{
//        [self showHudTipStr:@"任务不存在"];
//    }
//    
//    COTaskDetailController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COTaskDetailController"];
//    [self.navigationController pushViewController:controller animated:YES];
//    [controller showWithTaskPath:activity.task.path];
}

- (void)showProjectTopic:(COProjectActivity *)activity
{
    NSArray *pathArray;
    if ([activity.action isEqualToString:@"comment"]) {
        pathArray = [activity.projectTopic.parent.path componentsSeparatedByString:@"/"];
    }else{
        pathArray = [activity.projectTopic.path componentsSeparatedByString:@"/"];
    }
    if (pathArray.count >= 7) {
        NSInteger topicId = [pathArray[6] integerValue];
        COTopic *topic = [[COTopic alloc] init];
        topic.topicId = topicId;
        COTopicDetailController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"COTopicDetailController"];
        detail.topic = topic;
        [self.navigationController pushViewController:detail animated:YES];
    }else{
        // TODO: 讨论不存在
//        [self showHudTipStr:@"讨论不存在"];
    }
}

- (void)showProjectFile:(COProjectActivity *)activity
{
    if ([activity.action hasPrefix:@"delete"]) {
        return;
    }
    COFile *file = activity.file;
    NSArray *pathArray = [file.path componentsSeparatedByString:@"/"];
    BOOL isFile = [activity.fileType isEqualToString:@"file"];
    
    if (isFile && pathArray.count >= 9) {
        //文件
        NSString *fileIdStr = pathArray[8];
        COFile *curFile = [[COFile alloc] init];// [ProjectFile fileWithFileId:@(fileIdStr.integerValue) andProjectId:@(project.id.integerValue)];
        curFile.fileId = [fileIdStr integerValue];
        curFile.projectId = _projectId;
        curFile.name = file.name;
        COFilePreViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"COFilePreViewController"];
        vc.curFile = curFile;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (!isFile && pathArray.count >= 7){
        //文件夹
        COFolder *folder;
        NSString *folderIdStr = pathArray[6];
        if (![folderIdStr isEqualToString:@"default"] && [folderIdStr isPureInt]) {
            folder =  [[COFolder alloc] init];
            folder.fileId = folderIdStr.integerValue;
            folder.name = file.name;
        }else{
            folder =  [[COFolder alloc] init];
            folder.fileId = 0;
            folder.name = @"默认文件夹";
        }

        COFileViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COFileViewController"];
        controller.projectId = _projectId;
        controller.folderId = @(folder.fileId);
        [self.navigationController pushViewController:controller animated:YES];
    }else{
        [self showInfoWithStatus:(isFile? @"文件不存在" :@"文件夹不存在")];
    }
}

- (void)showDepot:(COProjectActivity *)activity
{
    
}

- (void)showQcTask:(COProjectActivity *)activity
{
    
}

- (void)showProjectStar:(COProjectActivity *)activity
{
    
}

- (void)showProjectWatcher:(COProjectActivity *)activity
{
    
}

- (void)showPullRequestBean:(COProjectActivity *)activity
{
    
}

- (void)showPullRequestComment:(COProjectActivity *)activity
{
    
}

- (void)showMergeRequestBean:(COProjectActivity *)activity
{
    
}

- (void)showMergeRequestComment:(COProjectActivity *)activity
{
    
}

- (void)showCommitLineNote:(COProjectActivity *)activity
{
    
}

#pragma mark - click
- (IBAction)backBtnAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showUser:(COUser *)user
{
    COUserController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COUserController"];
    [self rootPushViewController:controller animated:YES];
    [controller showUserWithGlobalKey:user.globalKey];
}

- (void)analyseLinkStr:(NSString *)linkStr
{
    if (linkStr.length <= 0) {
        return;
    }
    
    [self analyseVCFromLinkStr:linkStr showBlock:^(UIViewController *controller, COLinkShowType showType, NSString *link) {
        if (showType == COLinkShowTypeWeb) {
            [self rootPushViewController:controller animated:YES];
        }
        else if (showType == COLinkShowTypeRight) {
            [self.navigationController pushViewController:controller animated:YES];
        }
        else if (showType == COLinkShowTypePush) {
            [self rootPushViewController:controller animated:YES];
        }
        else if (showType == COLinkShowTypeUnSupport) {
            
        }
    }];
}

@end
