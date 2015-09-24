//
//  COProjectDetailController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/14.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COProjectDetailController.h"
#import "COProjectDetailHeadCell.h"
#import "COProjectDetailBtnCell.h"
#import "COProjectDetailBtnFCell.h"
#import "COActivityCell.h"
#import "COProjectDetailRMCell.h"
#import "COProjectRequest.h"
#import "COProjectActivity.h"
#import "UIViewController+Utility.h"
#import "COUtility.h"
#import "COSession.h"
#import <FBKVOController.h>
#import "UIActionSheet+Common.h"
#import "COTaskDetailController.h"
#import "COTopicDetailController.h"
#import "COUserController.h"
#import "COFileViewController.h"
#import "COFilePreViewController.h"
#import "NSString+Common.h"
#import "COProjectController.h"
#import "UIViewController+Link.h"
#import "COUnReadCountManager.h"
#import "COGitRequest.h"

@interface COProjectDetailController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarBottomLayout;
@property (weak, nonatomic) IBOutlet UIView *toolbarView;
@property (weak, nonatomic) IBOutlet UILabel *markLabel;
@property (weak, nonatomic) IBOutlet UILabel *followLabel;
@property (weak, nonatomic) IBOutlet UILabel *forkLabel;

@property (nonatomic, assign) CGFloat reameHeight;

@property (nonatomic, strong) COProject *project;
@property (nonatomic, strong) COGitTree *projectTree;
@property (nonatomic, strong) COProject *originProject;  // 用于kvo消除红点
@property (nonatomic, strong) NSMutableDictionary *data;

@property (weak, nonatomic) IBOutlet UIButton *markBtn;
@property (weak, nonatomic) IBOutlet UIButton *followBtn;
@property (weak, nonatomic) IBOutlet UIButton *forkBtn;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) COProjectDetailRMCell *rmCell;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation COProjectDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _followBtn.layer.borderColor = [UIColor colorWithRed:155/255.0 green:155/255.0 blue:155/255.0 alpha:1.0].CGColor;
    _followBtn.layer.cornerRadius = 4;
    _markBtn.layer.borderColor = [UIColor colorWithRed:155/255.0 green:155/255.0 blue:155/255.0 alpha:1.0].CGColor;
    _markBtn.layer.cornerRadius = 4;
    _forkBtn.layer.borderColor = [UIColor colorWithRed:155/255.0 green:155/255.0 blue:155/255.0 alpha:1.0].CGColor;
    _forkBtn.layer.cornerRadius = 4;
    _forkBtn.layer.borderWidth = 1;
    
    _backBtn.hidden = [self.navigationController.viewControllers count] > 1 ? FALSE : TRUE;
    
    [self setUpRefresh:self.tableView];
//    [self setUpLoadMore:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)showProject:(COProject *)project
{
    if (self.originProject == nil) {
        self.originProject = project;
    }
    else {
        if (self.originProject.projectId != project.projectId) {
            self.originProject = project;
        }
    }
    
    self.data = [NSMutableDictionary dictionary];

    self.project = project;
    self.titleLabel.text = self.project.name;
    
    _toolbarBottomLayout.constant = _project.isPublic ? 0 : -_toolbarView.frame.size.height;
  
    [self.KVOController unobserveAll];
    
    self.reameHeight = 80.0;
    self.tableView.contentOffset = CGPointMake(0.0, 0.0);
    self.tableView.scrollEnabled = YES;
    self.rmCell.webView.scrollView.scrollEnabled = YES;
    if (self.rmCell) {
        self.rmCell.contentHeight = 0.0;
        self.rmCell.webViewHegiht.constant = 40.0;
        [self.rmCell setNeedsUpdateConstraints];
        [self.rmCell.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    }
    [self.tableView reloadData];
    
    if (!_project.isPublic && project.projectId > 0) {
        // 加载最近动态
//        [self loadData:YES];
    }
    
    if (_project.isPublic) {
        [self showFollowBtn];
        [self showMarkBtn];
        _forkLabel.text = [NSString stringWithFormat:@"%ld", (long)_project.forkCount];
        [self loadReadMe];
    }
    
    [self loadDetail];
}

- (void)refresh
{
    [self loadDetail];
}

- (void)loadReadMe
{
    COGitTreeRequest *request = [COGitTreeRequest request];
    request.ref = @"master";
    request.backendProjectPath = _project.backendProjectPath;
    NSInteger projectId = _project.projectId;
    if (self.rmCell) {
        [self.rmCell.activityIndicator startAnimating];
    }
    
    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        if (responseObject.error == nil
            && responseObject.code == 0) {
            [weakself showReadMe:responseObject.data projectId:projectId];
        }
    } failure:^(NSError *error) {
        // TODO: show error.
    }];
}

- (void)showReadMe:(COGitTree *)tree projectId:(NSInteger)projectId
{
    if (projectId == self.project.projectId) {
        self.projectTree = tree;
        [self.tableView reloadData];
    }
}

- (void)loadDetail
{
    COProjectDetailRequest *request = [COProjectDetailRequest request];
    request.projectName = _project.name;
    request.projectOwnerName = _project.ownerUserName;
    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        [weakself.refreshCtrl endRefreshing];
        [COEmptyView removeFormView:weakself.view];
        if ([weakself checkDataResponse:responseObject]) {
            weakself.project = responseObject.data;
            if (weakself.project.isPublic) {
                [weakself showFollowBtn];
                [weakself showMarkBtn];
                weakself.forkLabel.text = [NSString stringWithFormat:@"%ld", (long)weakself.project.forkCount];
            }
            else {
                [weakself loadData:YES];
            }
            weakself.toolbarBottomLayout.constant = weakself.project.isPublic ? 0 : -weakself.toolbarView.frame.size.height;
            [weakself.tableView reloadData];
        }
    } failure:^(NSError *error) {
        [weakself.refreshCtrl endRefreshing];
//        [weakself showError:error];
        [weakself showErrorReloadView:^{
            [weakself loadDetail];
        } padding:UIEdgeInsetsMake(44.0, 0.0, 0.0, 0.0)];
    }];
}

#pragma mark - 最近动态
- (void)loadData:(BOOL)refresh
{
    COProjectActivitiesRequest *request = [COProjectActivitiesRequest request];
    request.projectId = @(_project.projectId);
    if (refresh) {
        request.lastId = @(99999999);
    }
    else {
        request.lastId = [self lastId];
    }
    request.userId = @([COSession session].user.userId);
    request.type = @"all";
    
    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        if ([weakself checkDataResponse:responseObject]) {
            [weakself showData:responseObject.data refresh:refresh];
        }
    } failure:^(NSError *error) {
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

- (void)showData:(NSArray *)data refresh:(BOOL)refresh
{
    if ([data count] == 0) {
        return;
    }
    
    NSMutableArray *typeData = self.data[@"all"];
    if (typeData) {
        if (refresh) {
            [typeData removeAllObjects];
        }
    }
    else {
        typeData = [NSMutableArray array];
        [self.data setObject:typeData forKey:@"all"];
    }
    [typeData addObjectsFromArray:[self parseData:data]];
    
    [self.tableView reloadData];
    self.tableView.scrollEnabled = YES;
}

- (NSNumber *)lastId
{
    id typeData = _data[@"all"];
    if (typeData) {
        NSArray *sectionData = [typeData lastObject];
        COProjectActivity *activity = [sectionData lastObject];
        return @(activity.activityID);
    }
    return @(99999999);
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (_project && !_project.isPublic) ? [_data[@"all"] count] + 1 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return _project ? (_project.isPublic ? 3 : 2) : 0;
    } else {
        return [self.data[@"all"][section - 1] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            COProjectDetailHeadCell *cell = [COProjectDetailHeadCell cellWithTableView:tableView];
            [cell assgnWithProject:self.project];
            return cell;
        } else if (indexPath.row == 1) {
            if (_project.isPublic) {
                // 4个功能入口
                COProjectDetailBtnCell *cell = [COProjectDetailBtnCell cellWithTableView:tableView];
                [cell assignWithProject:self.originProject];
                return cell;
            } else {
                // 6个功能入口
                COProjectDetailBtnFCell *cell = [COProjectDetailBtnFCell cellWithTableView:tableView];
                [cell assignWithProject:self.originProject];
                return cell;
            }
        } else {
            COProjectDetailRMCell *cell = [COProjectDetailRMCell cellWithTableView:tableView];
            self.rmCell = cell;
            self.rmCell.webView.scrollView.delegate = self;
            self.rmCell.webView.scrollView.scrollEnabled = YES;
            self.rmCell.loadRequestBlock = ^void(NSURLRequest *curRequest) {
                [self analyseLinkStr:curRequest.URL.absoluteString];
            };
            cell.heightChangeBlock = ^void(CGFloat newHeight) {
                if (self.reameHeight != newHeight) {
                    CGFloat height = CGRectGetHeight(self.tableView.frame);
                    if (newHeight > height) {
                        self.reameHeight = height;
                    }
                    else {
                        self.reameHeight = newHeight;
                    }
                    [self.tableView reloadData];
                }
            };
            
            if (self.projectTree) {
                [cell showReadMe:self.projectTree];
            }
            
            [cell setNeedsLayout];
            
            return cell;
        }
    } else {
        COActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"COActivityCell"];
        
//        NSLog(@"%d", indexPath.section);
        [cell assignWithActivity:self.data[@"all"][indexPath.section - 1][indexPath.row]];
        NSInteger index = indexPath.row;
        for (NSInteger i = 0; i<indexPath.section; i++) {
            index += [self.data[@"all"][i] count];
        }
        if (index < _project.unReadActivitiesCount) {
            cell.dot.layer.borderColor = [UIColor colorWithRed:59/255.0 green:189/255.0 blue:121/255.0 alpha:1.0].CGColor;
        } else {
            cell.dot.layer.borderColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0].CGColor;
        }
        
        cell.lineUp.hidden = indexPath.row == 0 ? TRUE : FALSE;
        cell.topHeightLayout.constant = cell.lineUp.hidden ? 0 : 0;
        cell.lineDown.hidden = indexPath.row == [self.data[@"all"][indexPath.section - 1] count] - 1 ? TRUE : FALSE;
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
    return nil;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return [COProjectDetailHeadCell cellHeight];
        } else if (indexPath.row == 1) {
            if (_project.isPublic) {
                return [COProjectDetailBtnCell cellHeight];
            } else {
               return [COProjectDetailBtnFCell cellHeight];
            }
        } else {
            if (self.reameHeight > 0.0) {
                return self.reameHeight;
            }
            return [COProjectDetailRMCell cellHeight];
        }
    } else {
        CGFloat h = [self heightForBasicCellAtIndexPath:indexPath];
        // 第一个和最后一个高度需要增加一点点
        if (indexPath.row == 0) h += 8;
        if (indexPath.row == [self.data[@"all"][indexPath.section - 1] count] - 1) h += 8;
        return h;
    }
    return 0;
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static COActivityCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:@"COActivityCell"];
    });
    
    
    COProjectActivity *activity = self.data[@"all"][indexPath.section - 1][indexPath.row];
    if (activity.height == 0.0) {
        [sizingCell assignWithActivity:activity];
    }
    
    return activity.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    }
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 8, CGRectGetWidth(tableView.frame), 40)];
    backView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, CGRectGetWidth(tableView.frame) - 40, 40)];
    titleLbl.textColor = [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0];
    titleLbl.font = [UIFont systemFontOfSize:14];
    
    COProjectActivity *activity = [_data[@"all"][section - 1] firstObject];
    titleLbl.text = [COUtility timestampToDayWithWeek:activity.createdAt];
    [backView addSubview:titleLbl];
    return backView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 0) {
        // 项目设置
    }
    else if (indexPath.section > 0) {
        [self showActivityAtIndexPath:indexPath];
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"COProjectSettingController"]) {
        return [COSession session].user.userId == _project.ownerId;
    }
    return YES;
}

#pragma mark -
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"projectActivity"]){
        [segue.destinationViewController setValue:@(_project.projectId) forKey:@"projectId"];
        [segue.destinationViewController setValue:_project forKey:@"project"];
        [segue.destinationViewController setValue:_project.name forKey:@"title"];
        if (self.project.unReadActivitiesCount > 0) {
            [[COUnReadCountManager manager] visitProject:self.originProject];
        }
    }
    else if( [segue.identifier isEqualToString:@"projectTask"]) {
        [segue.destinationViewController setValue:@(_project.projectId) forKey:@"projectId"];
        [segue.destinationViewController setValue:_project forKey:@"project"];
        [segue.destinationViewController setValue:_project.backendProjectPath forKey:@"backendProjectPath"];
        [segue.destinationViewController setValue:_project.name forKey:@"title"];
    }
    else if( [segue.identifier isEqualToString:@"projectTopic"]) {
        [segue.destinationViewController setValue:_project.backendProjectPath forKey:@"backendProjectPath"];
        [segue.destinationViewController setValue:_project forKey:@"project"];
    }
    else if( [segue.identifier isEqualToString:@"projectFile"]) {
        [segue.destinationViewController setValue:@(_project.projectId) forKey:@"projectId"];
        [segue.destinationViewController setValue:_project forKey:@"project"];
    }
    else if( [segue.identifier isEqualToString:@"projectCode"]) {
        [segue.destinationViewController setValue:_project.backendProjectPath forKey:@"backendProjectPath"];
        [segue.destinationViewController setValue:_project forKey:@"project"];
        [segue.destinationViewController setValue:@"master" forKey:@"ref"];
    }
    else if( [segue.identifier isEqualToString:@"projectMember"]) {
        [segue.destinationViewController setValue:_project forKey:@"project"];
    }
    else if ([segue.identifier isEqualToString:@"COProjectSettingController"]) {
        [segue.destinationViewController setValue:_project forKey:@"project"];
    }
}

#pragma mark - click
- (IBAction)markBtnClick:(UIButton *)sender
{
    if (_project.stared) {
        COProjectUnstarRequest *request = [COProjectUnstarRequest request];
        request.projectName = _project.name;
        request.projectOwnerName = _project.ownerUserName;
        __weak typeof(self) weakself = self;
        [request postWithSuccess:^(CODataResponse *responseObject) {
            if ([weakself checkDataResponse:responseObject]) {
                weakself.project.stared = FALSE;
                weakself.project.starCount--;
                [weakself showMarkBtn];
            }
        } failure:^(NSError *error) {
            [weakself showError:error];
        }];
    } else {
        COProjectStarRequest *request = [COProjectStarRequest request];
        request.projectName = _project.name;
        request.projectOwnerName = _project.ownerUserName;
        __weak typeof(self) weakself = self;
        [request postWithSuccess:^(CODataResponse *responseObject) {
            if ([weakself checkDataResponse:responseObject]) {
                weakself.project.stared = TRUE;
                weakself.project.starCount++;
                [weakself showMarkBtn];
            }
        } failure:^(NSError *error) {
            [weakself showError:error];
        }];
    }
}

- (IBAction)followBtnClick:(UIButton *)sender
{
    if (_project.watched) {
        COProjectUnwatchRequest *request = [COProjectUnwatchRequest request];
        request.projectName = _project.name;
        request.projectOwnerName = _project.ownerUserName;
        __weak typeof(self) weakself = self;
        [request postWithSuccess:^(CODataResponse *responseObject) {
            if ([weakself checkDataResponse:responseObject]) {
                _project.watched = FALSE;
                _project.watchCount--;
                [weakself showFollowBtn];
            }
        } failure:^(NSError *error) {
            [weakself showError:error];
        }];
    } else {
        COProjectWatchRequest *request = [COProjectWatchRequest request];
        request.projectName = _project.name;
        request.projectOwnerName = _project.ownerUserName;
        __weak typeof(self) weakself = self;
        [request postWithSuccess:^(CODataResponse *responseObject) {
            if ([weakself checkDataResponse:responseObject]) {
                weakself.project.watched = TRUE;
                weakself.project.watchCount++;
                [weakself showFollowBtn];
            }
        } failure:^(NSError *error) {
            [weakself showError:error];
        }];
    }
}

- (void)showMarkBtn
{
    if (_project.stared) {
        _markBtn.backgroundColor = [UIColor colorWithRed:59/255.0 green:189/255.0 blue:121/255.0 alpha:1.0];
        [_markBtn setTitle:@"已收藏" forState:UIControlStateNormal];
        [_markBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_markBtn setImage:[UIImage imageNamed:@"icon_model_selected_white"] forState:UIControlStateNormal];
        [[self.view viewWithTag:1001] setBackgroundColor:[UIColor whiteColor]];
        _markBtn.layer.borderWidth = 0;
        _markLabel.textColor = [UIColor whiteColor];
    } else {
        _markBtn.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
        [_markBtn setTitle:@"收藏" forState:UIControlStateNormal];
        [_markBtn setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_markBtn setImage:[UIImage imageNamed:@"icon_project_mark"] forState:UIControlStateNormal];
        [[self.view viewWithTag:1001] setBackgroundColor:[UIColor colorWithHex:@"#dddddd"]];
        _markBtn.layer.borderWidth = 1;
        _markLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    }
    _markLabel.text = [NSString stringWithFormat:@"%ld", (long)_project.starCount];
}

- (void)showFollowBtn
{
    if (_project.watched) {
        _followBtn.backgroundColor = [UIColor colorWithRed:59/255.0 green:189/255.0 blue:121/255.0 alpha:1.0];
        [_followBtn setTitle:@"已关注" forState:UIControlStateNormal];
        [_followBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_followBtn setImage:[UIImage imageNamed:@"icon_model_selected_white"] forState:UIControlStateNormal];
        [[self.view viewWithTag:1002] setBackgroundColor:[UIColor whiteColor]];
        _followBtn.layer.borderWidth = 0;
        _followLabel.textColor = [UIColor whiteColor];
    } else {
        _followBtn.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
        [_followBtn setTitle:@"关注" forState:UIControlStateNormal];
        [_followBtn setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_followBtn setImage:[UIImage imageNamed:@"icon_project_follow"] forState:UIControlStateNormal];
        [[self.view viewWithTag:1002] setBackgroundColor:[UIColor colorWithHex:@"#dddddd"]];
        _followBtn.layer.borderWidth = 1;
        _followLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    }
    _followLabel.text = [NSString stringWithFormat:@"%ld", (long)_project.watchCount];
}

- (IBAction)forkBtnClick:(UIButton *)sender
{
    [[UIActionSheet bk_actionSheetCustomWithTitle:@"fork将会将此项目复制到您的个人空间，确定要fork吗?" buttonTitles:@[@"确定"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
        if (index == 0) {
            [self forkRequest];
        }
    }] showInView:self.view];
}

- (void)forkRequest
{
    COProjectForkRequest *request = [COProjectForkRequest request];
    request.projectName = _project.name;
    request.projectOwnerName = _project.ownerUserName;
    __weak typeof(self) weakself = self;
    [request postWithSuccess:^(CODataResponse *responseObject) {
        if ([weakself checkDataResponse:responseObject]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakself.project.forked = TRUE;
                weakself.project.forkCount++;
                [[NSNotificationCenter defaultCenter] postNotificationName:OPProjectReloadNotification object:nil];
                [weakself gotoForkProject];
            });
        }
    } failure:^(NSError *error) {
        [weakself showError:error];
    }];
}

- (void)gotoForkProject
{
    COProjectDetailRequest *request = [COProjectDetailRequest request];
    request.projectName = _project.name;
    request.projectOwnerName = [COSession session].user.globalKey;
    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        if ([weakself checkDataResponse:responseObject]) {
            COProjectDetailController *nextVC = [self.storyboard instantiateViewControllerWithIdentifier:@"COProjectDetailController"];
            [self.navigationController pushViewController:nextVC animated:YES];
            [nextVC showProject:responseObject.data];
        }
    } failure:^(NSError *error) {
        [weakself showError:error];
    }];
}

- (IBAction)backBtnAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
- (void)showActivityAtIndexPath:(NSIndexPath *)indexPath
{
    COProjectActivity *activity = self.data[@"all"][indexPath.section - 1][indexPath.row];
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
        curFile.projectId = _project.projectId;
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
        controller.projectId = _project.projectId;
        controller.project = _project;
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

#pragma mark -
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.reameHeight <= self.rmCell.contentHeight) {
        if (scrollView == self.rmCell.webView.scrollView) {
            if (scrollView.contentOffset.y == 0) {
                self.tableView.scrollEnabled = YES;
                self.rmCell.webView.scrollView.scrollEnabled = NO;
            }
        }
        else if (scrollView == self.tableView) {
            if (scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height) {
                self.tableView.scrollEnabled = NO;
                self.rmCell.webView.scrollView.scrollEnabled = YES;
            }
        }
    }
//    NSLog(@"-----1----");
//    NSLog(@"-->%@", NSStringFromCGSize(self.rmCell.webView.scrollView.contentSize));
//    NSLog(@"-->%@", NSStringFromCGPoint(self.rmCell.webView.scrollView.contentOffset));
//    NSLog(@"-->%d", self.rmCell.webView.scrollView.scrollEnabled ? 1 : 0);
//    NSLog(@"-->%@", NSStringFromCGRect(self.rmCell.webView.frame));
//    NSLog(@"-----2----");
//    NSLog(@"-->%@", NSStringFromCGSize(self.tableView.contentSize));
//    NSLog(@"-->%@", NSStringFromCGPoint(self.tableView.contentOffset));
//    NSLog(@"-->%d", self.tableView.scrollEnabled ? 1 : 0);
}
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    if (self.reameHeight <= self.rmCell.contentHeight) {
//        if (scrollView == self.rmCell.webView.scrollView) {
//            if (scrollView.contentOffset.y == 0) {
//                self.tableView.scrollEnabled = YES;
//                self.rmCell.webView.scrollView.scrollEnabled = NO;
//            }
//        }
//        else if (scrollView == self.tableView) {
//            if (scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height) {
//                self.tableView.scrollEnabled = NO;
//                self.rmCell.webView.scrollView.scrollEnabled = YES;
//            }
//        }
//    }
//}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
//    NSLog(@"-----1----");
//    NSLog(@"-->%@", NSStringFromCGSize(self.rmCell.webView.scrollView.contentSize));
//    NSLog(@"-->%@", NSStringFromCGPoint(self.rmCell.webView.scrollView.contentOffset));
//    NSLog(@"-->%d", self.rmCell.webView.scrollView.scrollEnabled ? 1 : 0);
//    NSLog(@"-----2----");
//    NSLog(@"-->%@", NSStringFromCGSize(self.tableView.contentSize));
//    NSLog(@"-->%@", NSStringFromCGPoint(self.tableView.contentOffset));
//    NSLog(@"-->%d", self.tableView.scrollEnabled ? 1 : 0);
//    if (!decelerate) {
//        if (self.reameHeight <= self.rmCell.contentHeight) {
//            if (scrollView == self.rmCell.webView.scrollView) {
//                if (scrollView.contentOffset.y == 0) {
//                    self.tableView.scrollEnabled = YES;
//                    self.rmCell.webView.scrollView.scrollEnabled = NO;
//                }
//            }
//            else if (scrollView == self.tableView) {
//                if (scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height) {
//                    self.tableView.scrollEnabled = NO;
//                    self.rmCell.webView.scrollView.scrollEnabled = YES;
//                }
//            }
//        }
//    }
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
