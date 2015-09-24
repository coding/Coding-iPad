//
//  COConversationListController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/23.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COConversationListController.h"
#import "COMessageRequest.h"
#import "COMessageCell.h"
#import "CONotificationCell.h"
#import "COSegmentControl.h"
#import "COMesageController.h"
#import <RegexKitLite.h>
#import "CODataRequest.h"
#import "COTopicDetailController.h"
#import "COTopic.h"
#import "COUserController.h"
#import "COProjectDetailController.h"
#import "COTaskDetailController.h"
#import "COFilePreViewController.h"
#import "COFileViewController.h"
#import "COFileRootViewController.h"
#import "COTweetDetailViewController.h"
#import "COUnReadCountManager.h"
#import <FBKVOController.h>

#define COMsgTypeNotification 0
#define COMsgTypeConversation 1

@interface COConversationListController ()

@property (nonatomic, strong) NSMutableArray *conversations;
@property (nonatomic, strong) NSMutableArray *notifications;
@property (nonatomic, assign) NSInteger convPage;
@property (nonatomic, assign) NSInteger notifiPage;
@property (nonatomic, assign) NSInteger msgType;

@property (weak, nonatomic) IBOutlet COSegmentControl *segmentControl;

@property (nonatomic, assign) NSInteger conversationId;
@property (nonatomic, copy) NSString *selectBId;

@end

@implementation COConversationListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.msgCountView.layer.cornerRadius = 4.0;
    self.msgCountView.clipsToBounds = YES;
    self.msgCountView.hidden = YES;
    
    self.notifCountView.layer.cornerRadius = 4.0;
    self.notifCountView.clipsToBounds = YES;
    self.notifCountView.hidden = YES;
    
    self.conversations = [NSMutableArray array];
    self.notifications = [NSMutableArray array];
    self.convPage = 1;
    self.notifiPage = 1;
    self.msgType = COMsgTypeNotification;
    
    __weak typeof(self) weakSelf = self;
    [_segmentControl setItemsWithTitleArray:@[@"通知", @"私信"]
                              selectedBlock:^(NSInteger index) {

                                  weakSelf.tableView.infiniteScrollingView.enabled = YES;
                                  if (0 == index) {
                                      weakSelf.msgType = COMsgTypeNotification;
                                      [weakSelf loadNotification];
                                      COMesageController *controller = (COMesageController *)weakSelf.parentViewController;
                                      [controller showMessage:nil];

                                  }
                                  else {
                                      weakSelf.msgType = COMsgTypeConversation;
                                      [weakSelf loadConversation];
                                  }
                              }];
    
    [self loadNotification];
    
    [self setUpRefresh:self.tableView];
    [self setUpLoadMore:self.tableView];
    
    [self.KVOController observe:[COUnReadCountManager manager] keyPath:@"messageCount" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(id observer, COUnReadCountManager *object, NSDictionary *change) {
        self.msgCountView.hidden = object.messageCount == 0 ? YES : NO;
        self.notifCountView.hidden = object.notificationCount == 0 ? YES : NO;
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAll:) name:COConversationListReloadNotification object:nil];
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
- (void)reloadAll:(NSNotification *)n
{
    self.convPage = 1;
    [self loadConversation];
    self.notifiPage = 1;
    [self loadNotification];
}

- (void)reloadData
{
    [self refresh];
}

- (void)refresh
{
    if (self.msgType == COMsgTypeConversation) {
        self.convPage = 1;
        [self loadConversation];
    }
    else if (self.msgType == COMsgTypeNotification) {
        self.notifiPage = 1;
        [self loadNotification];
    }
}

- (void)loadMore
{
    if (self.msgType == COMsgTypeConversation) {
        self.convPage += 1;
        [self loadConversation];
    }
    else if (self.msgType == COMsgTypeNotification) {
        self.notifiPage += 1;
        [self loadNotification];
    }
}

- (void)stopHud
{
    [self.refreshCtrl endRefreshing];
    [self.tableView.pullToRefreshView stopAnimating];
    [self.tableView.infiniteScrollingView stopAnimating];
}

- (void)loadNotification
{
    CONotificationRequest *request = [CONotificationRequest request];
    request.page = self.notifiPage;
    request.pageSize = 20;
    
    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        [weakself stopHud];
        if (responseObject.error == nil
            && responseObject.code == 0) {
            // TODO:  show data
            [weakself reloadNotification:responseObject.data];
        }
    } failure:^(NSError *error) {
        [weakself stopHud];
        [weakself showError:error];
    }];
}

- (void)loadConversation
{
    COConversationListRequest *reqeust = [COConversationListRequest request];
    reqeust.page = self.convPage;
    reqeust.pageSize = 20;
    
    __weak typeof(self) weakself = self;
    [reqeust getWithSuccess:^(CODataResponse *responseObject) {
        [weakself stopHud];
        if (responseObject.error == nil
            && responseObject.code == 0) {
            // TODO:  show data
            [weakself reloadConversation:responseObject.data];
        }
    } failure:^(NSError *error) {
        [weakself stopHud];
        [weakself showError:error];
    }];
}

- (void)reloadNotification:(NSArray *)data
{
    @synchronized(self) {
        if (1 == self.notifiPage) {
            [self.notifications removeAllObjects];
            if ([data count] == 0) {
                [self showEmptyView];
            }
            else {
                [self removeEmptyView];
            }
        }
        [self.notifications addObjectsFromArray:data];
        
    }
    
    if (self.msgType == COMsgTypeNotification) {
        if (data.count < 20) {
            self.tableView.infiniteScrollingView.enabled = NO;
        }
        else {
            self.tableView.infiniteScrollingView.enabled = YES;
        }
    }
    
    [_tableView reloadData];
}

- (void)reloadConversation:(NSArray *)data
{
    @synchronized(self) {
        if (1 == self.convPage) {
            [self.conversations removeAllObjects];
            if ([data count] == 0) {
                [self showEmptyView];
            }
            else {
                [self removeEmptyView];
            }
        }
        [self.conversations addObjectsFromArray:data];
    }
    
    if (self.msgType == COMsgTypeConversation) {
        if (data.count < 20) {
            self.tableView.infiniteScrollingView.enabled = NO;
        }
        else {
            self.tableView.infiniteScrollingView.enabled = YES;
        }
    }
    [_tableView reloadData];
}

#pragma mark -
- (void)showEmptyView
{
    [COEmptyView removeFormView:self.view];
    
    COEmptyView *view = nil;
    if (COMsgTypeConversation == self.msgType) {
        view = [COEmptyView emptyViewWithImage:[UIImage imageNamed:@"blankpage_image_Hi"] andTips:@"无私信\n找朋友打个招呼吧~"];
    }
    else {
        //这个还什么都没有\n快弄起来弄出点动静吧~
        view = [COEmptyView emptyViewWithImage:[UIImage imageNamed:@"blankpage_image_Sleep"] andTips:@"这个还什么都没有\n快弄起来弄出点动静吧~"];
    }
    [view showInView:self.view padding:UIEdgeInsetsMake(50.0, 0.0, 0.0, 0.0)];
}

- (void)removeEmptyView
{
    [COEmptyView removeFormView:self.view];
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (COMsgTypeNotification == self.msgType) {
        return self.notifications.count;
    }
    return self.conversations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if (COMsgTypeNotification == self.msgType) {
        CONotificationCell *ncell = [tableView dequeueReusableCellWithIdentifier:@"CONotificationCell"];
        [ncell assignWithNotification:_notifications[indexPath.row]];
        __weak typeof(self) weakSelf = self;
        ncell.linkClickedBlock = ^(HtmlMediaItem *item, CONotification *tip){
            [weakSelf analyseHtmlMediaItem:item andTip:tip];
        };
        cell = ncell;
    }
    else {
        COMessageCell *mcell = [tableView dequeueReusableCellWithIdentifier:@"COMessageCell"];
        [mcell assignWithConversation:_conversations[indexPath.row]];
        cell = mcell;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (COMsgTypeConversation == self.msgType) {
        return 94.0;
    }
    else if (COMsgTypeNotification == self.msgType) {
        return [CONotificationCell calcHeight:_notifications[indexPath.row]];
    }
    return 0.0;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row) {
        NSIndexPath *selectedIndexPath = [tableView indexPathForSelectedRow];
        if (!selectedIndexPath) {
            if (COMsgTypeNotification != self.msgType) {
                // 聊天详情
                NSInteger selecetIndex = 0;
                if (_conversationId>0 && _conversations && [_conversations count]>0) {
                    NSInteger index = 0;
                    for (COConversation *conversation in _conversations) {
                        if (conversation.conversationId == _conversationId) {
                            selecetIndex = index;
                            break;
                        }
                        index++;
                    }
                }
//                [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selecetIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
//                COMesageController *controller = (COMesageController *)self.parentViewController;
//                COConversation *conversation = _conversations[selecetIndex];
//                [controller showMessage:conversation];
//                _conversationId = conversation.conversationId;
            } else {
                if (_selectBId.length>0 && _notifications && [_notifications count]>0) {
                    NSInteger index = 0;
                    for (CONotification *notification in _notifications) {
                        if ([notification.bId isEqualToString:_selectBId]) {
                            [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
                            break;
                        }
                        index++;
                    }
                }
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (COMsgTypeNotification != self.msgType) {
        // 聊天详情
        COMesageController *controller = (COMesageController *)self.parentViewController;
        COConversation *conversation = _conversations[indexPath.row];
        [controller showMessage:conversation];
        _conversationId = conversation.conversationId;
        [[COUnReadCountManager manager] readConversation:conversation];
    } else {
        CONotification *notification = _notifications[indexPath.row];
        _selectBId = notification.bId;
       COMesageController *controller = (COMesageController *)self.parentViewController;
        [controller showMessage:nil];
        [[COUnReadCountManager manager] readNotification:_notifications[indexPath.row]];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma makr -
- (void)showPushNotification:(NSString *)linkStr
{
    if (COMsgTypeNotification != self.msgType) {
        [self.segmentControl selectIndex:0];
    }
    
    [self analyseVCFromLinkStr:linkStr];
}

- (void)analyseHtmlMediaItem:(HtmlMediaItem *)item andTip:(CONotification *)tip{
    [[COUnReadCountManager manager] readNotification:tip];
    NSString *linkStr = item.href;
    if ([self analyseVCFromLinkStr:linkStr]){
        
    } else {
        //网页
//        WebViewController *webVc = [WebViewController webVCWithUrlStr:linkStr];
//        [self.navigationController pushViewController:webVc animated:YES];
    }
}

- (BOOL)analyseVCFromLinkStr:(NSString *)linkStr
{
    if (!linkStr || linkStr.length <= 0) {
        return NO;
    }
    else if (![linkStr hasPrefix:@"/"] && ![linkStr hasPrefix:@"https://coding.net"]){
        return NO;
    }
    
    NSString *userRegexStr = @"/u/([^/]+)$";
    NSString *userTweetRegexStr = @"/u/([^/]+)/bubble$";
    NSString *ppRegexStr = @"/u/([^/]+)/pp/([0-9]+)$";
    NSString *topicRegexStr = @"/u/([^/]+)/p/([^/]+)/topic/(\\d+)";
    NSString *taskRegexStr = @"/u/([^/]+)/p/([^/]+)/task/(\\d+)";
    NSString *gitMRPRCommitRegexStr = @"/u/([^/]+)/p/([^/]+)/git/(merge|pull|commit)/(\\d+)";
    NSString *conversionRegexStr = @"/user/messages/history/([^/]+)$";
    NSString *projectRegexStr = @"/u/([^/]+)/p/([^/]+)";
    NSArray *matchedCaptures = nil;
    
    if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:ppRegexStr]).count > 0) {
        //冒泡
        NSString *user_global_key = matchedCaptures[1]; // globalKey
        NSString *pp_id = matchedCaptures[2];           // 冒泡ID
        NSLog(@"%@, %@", user_global_key, pp_id);
        COTweetDetailViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COTweetDetailViewController"];
        // FixMe: 宽度调整
        controller.targetWidth = 574.0;
        COMesageController *root = (COMesageController *)self.parentViewController;
        [root pushDetail:controller];
        [controller loadTweetDetail:user_global_key tweetId:@([pp_id integerValue])];
        return YES;
    }
    else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:gitMRPRCommitRegexStr]).count > 0) {
        //MR
        NSString *path = [linkStr stringByReplacingOccurrencesOfString:@"https://coding.net" withString:@""];
        NSString *projectName = matchedCaptures[2];
        NSString *globalKey = matchedCaptures[1];
        NSString *commitId = matchedCaptures[3];
        NSLog(@"%@,%@,%@,%@", path, projectName, globalKey, commitId);
        return YES;
    }
    else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:topicRegexStr]).count > 0) {
        //讨论
        NSString *topic_id = matchedCaptures[3];
        COTopicDetailController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COTopicDetailController"];
        COTopic *topic = [[COTopic alloc] init];
        topic.topicId = [topic_id integerValue];
        controller.topic = topic;
        COMesageController *root = (COMesageController *)self.parentViewController;
        [root pushDetail:controller];
        return YES;
    }
    else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:taskRegexStr]).count > 0) {
        //任务
        NSString *user_global_key = matchedCaptures[1];
        NSString *project_name = matchedCaptures[2];
        NSString *taskId = matchedCaptures[3];
        NSString *backend_project_path = [NSString stringWithFormat:@"/user/%@/project/%@", user_global_key, project_name];
        COTaskDetailController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COTaskDetailController"];
        COMesageController *root = (COMesageController *)self.parentViewController;
        [root pushDetail:controller];
        [controller loadTaskDetail:[taskId integerValue] backendProjectPath:backend_project_path];
        
        return YES;
    }
    else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:conversionRegexStr]).count > 0) {
        //私信
//        NSString *user_global_key = matchedCaptures[1];
        //        if ([presentingVC isKindOfClass:[ConversationViewController class]]) {
        //            ConversationViewController *vc = (ConversationViewController *)presentingVC;
        //            if ([vc.myPriMsgs.curFriend.global_key isEqualToString:user_global_key]) {
        //                [vc doPoll];
        //                analyseVCIsNew = NO;
        //                analyseVC = vc;
        //            }
        //        }
        //        if (!analyseVC) {
        //            ConversationViewController *vc = [[ConversationViewController alloc] init];
        //            vc.myPriMsgs = [PrivateMessages priMsgsWithUser:[User userWithGlobalKey:user_global_key]];
        //            analyseVC = vc;
        //        }
        return YES;
    }
    else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:userRegexStr]).count > 0) {
        //AT某人
        NSString *user_global_key = matchedCaptures[1];
        COUserController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COUserController"];
        [self rootPushViewController:controller animated:YES];
        [controller showUserWithGlobalKey:user_global_key];
        return YES;
    }
    else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:userTweetRegexStr]).count > 0) {
        //某人的冒泡
        //            UserTweetsViewController *vc = [[UserTweetsViewController alloc] init];
        NSString *user_global_key = matchedCaptures[1];
        COUserController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COUserController"];
        [self rootPushViewController:controller animated:YES];
        [controller showUserWithGlobalKey:user_global_key];
        return YES;
    }
    else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:projectRegexStr]).count > 0) {
        //项目
        NSString *user_global_key = matchedCaptures[1];
        NSString *project_name = matchedCaptures[2];
        COProject *project = [[COProject alloc] init];
        project.name = project_name;
        project.ownerUserName = user_global_key;
        COProjectDetailController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COProjectDetailController"];
        COMesageController *root = (COMesageController *)self.parentViewController;
        [root pushDetail:controller];
        [controller showProject:project];
        return YES;
    }
    //    }
    //    if (isNewVC) {
    //        *isNewVC = analyseVCIsNew;
    //    }
    return NO;
}

@end
