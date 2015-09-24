//
//  COTweetViewController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/10.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COTweetViewController.h"
#import "COTweetCell.h"
#import "COTweetRequest.h"
#import "COUserController.h"
#import "CORootViewController.h"
#import "UIActionSheet+Common.h"
#import "COTweetDetailViewController.h"
#import "COWebViewController.h"
#import "UIViewController+Link.h"
#import "COSession.h"
#import "COTweetComment.h"
#import "COTweetAddCommentController.h"

#define COTweetPublic 0
#define COTweetFriend 1
#define COTweetHot    2
#define COTweetUser   3

#define COLastId  99999999

@interface COTweetViewController()<CORootBackgroudProtocol, UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *tweets;
@property (nonatomic, strong) NSMutableArray *publicTweets;
@property (nonatomic, strong) NSMutableArray *hotTweets;
@property (nonatomic, strong) NSMutableArray *friendTweets;
@property (nonatomic, strong) NSMutableArray *userTweets;
@property (nonatomic, assign) NSInteger typeIndex;
@property (nonatomic, strong) NSMutableArray *tableOffsets;

@end

@implementation COTweetViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.publicTweets = [NSMutableArray array];
    self.hotTweets = [NSMutableArray array];
    self.friendTweets = [NSMutableArray array];
    self.userTweets = [NSMutableArray array];
    
    self.tableOffsets = [NSMutableArray arrayWithObjects:@(0.0), @(0.0), @(0.0), @(0.0), nil];
    
    self.typeIndex = 0;
    
    if (self.user == nil) {
        __weak typeof(self) weakself = self;
        [_segmentControl setItemsWithTitleArray:@[@"冒泡广场", @"好友圈", @"热门冒泡"] selectedBlock:^(NSInteger index) {
              [weakself saveStatus];
              weakself.typeIndex = index;
              [weakself.refreshCtrl endRefreshing];
              [weakself.tableView.infiniteScrollingView stopAnimating];
              weakself.tableView.infiniteScrollingView.enabled = YES;
              if (0 == index) {
                  weakself.tweets = weakself.publicTweets;
                  if ([weakself.tweets count] > 0) {
                      [weakself removeEmptyView];
                      [weakself.tableView reloadData];
                      [weakself loadStatus];
                  }
                  else {
                      [weakself loadTweet:YES];
                  }
              }
              else if (1 == index) {
                  weakself.tweets = weakself.friendTweets;
                  if ([weakself.tweets count] > 0) {
                      [weakself removeEmptyView];
                      [weakself.tableView reloadData];
                      [weakself loadStatus];
                  }
                  else {
                      [weakself loadTweet:YES];
                  }
              }
              else {
                  weakself.tweets = weakself.hotTweets;
                  // 热门冒泡只有20条
                  weakself.tableView.infiniteScrollingView.enabled = NO;
                  if ([weakself.tweets count] > 0) {
                      [weakself removeEmptyView];
                      [weakself.tableView reloadData];
                      [weakself loadStatus];
                  }
                  else {
                      [weakself loadTweet:YES];
                  }
              }
          }];
        self.headView.hidden = YES;
        self.tweets = self.publicTweets;
    }
    else {
        self.typeIndex = 3;
        self.headView.hidden = NO;
        if ([_user.globalKey isEqualToString:[COSession session].user.globalKey]) {
            _titleLabel.text = @"我的冒泡";
        }
        else {
            _titleLabel.text = @"TA的冒泡";
        }
        self.tweets = self.userTweets;
        _tableOffset.constant = 0.0;
        _segmentHeight.constant = 0.0;
        _tableLeft.constant = 5.0;
        _tableRight.constant = 5.0;
    }
    
    [self loadTweet:YES];
    [self setUpRefresh:self.tableView];
    [self setUpLoadMore:self.tableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentNotification:) name:COTweetCommentNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNotification:) name:COTweetReloadNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshNotification:) name:COTweetRefreshNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tweetNotification:) name:COTweetDeleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tweetDetailNotification:) name:COTweetDetailNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tweetImageResizeNotification:) name:COTweetImageResizeNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
- (void)saveStatus
{
    self.tableOffsets[self.typeIndex] = @(self.tableView.contentOffset.y);
}

- (void)loadStatus
{
    CGFloat offset = [self.tableOffsets[self.typeIndex] floatValue];
    [self.tableView setContentOffset:CGPointMake(0.0, offset) animated:NO];
}

#pragma mark - Data
- (void)commentNotification:(NSNotification *)n
{
    [self.tableView reloadData];
}

- (void)reloadNotification:(NSNotification *)n
{
    [self loadTweet:YES];
}

- (void)refreshNotification:(NSNotification *)n
{
    [self.tableView reloadData];
}


- (void)tweetNotification:(NSNotification *)n
{
    UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"删除此冒泡" buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
        if (index == 0) {
            [self deleteTweet:n.object];
        }
    }];
    [actionSheet showInView:self.view];
}

- (void)tweetDetailNotification:(NSNotification *)n
{
    if (n.object) {
        COTweet *tweet = n.object;
        [self showTweetDetail:tweet];
    }
}

- (void)tweetImageResizeNotification:(NSNotification *)n
{
    [self.tableView reloadData];
}

- (void)deleteTweet:(COTweet *)tweet
{
    COTweetDeleteRequest *request = [COTweetDeleteRequest request];
    request.tweetId = @(tweet.tweetId);
    
    __weak typeof(self) weakself = self;
    [self showProgressHud];
    [request deleteWithSuccess:^(CODataResponse *responseObject) {
        [weakself dismissProgressHud];
        if ([weakself checkDataResponse:responseObject]) {
            [weakself showSuccess:@"删除成功！"];
            [weakself.tweets removeObject:tweet];
            [weakself.tableView reloadData];
        }
    } failure:^(NSError *error) {
        [weakself showErrorInHudWithError:error];
    }];
}

- (void)deleteComment:(COTweetComment *)comment ofTweet:(COTweet *)tweet
{
    COTweetCommentDeleteRequest *request = [COTweetCommentDeleteRequest request];
    request.tweetId = @(tweet.tweetId);
    request.commentId = @(comment.tweetcommentId);
    
    __weak typeof(self) weakself = self;
    [request deleteWithSuccess:^(CODataResponse *responseObject) {
        if ([weakself checkDataResponse:responseObject]) {
            [tweet.commentList removeObject:comment];
            [weakself.tableView reloadData];
        }
    } failure:^(NSError *error) {
        [weakself showErrorInHudWithError:error];
    }];
}

- (void)stopHud
{
    [self.refreshCtrl endRefreshing];
    [self.tableView.infiniteScrollingView stopAnimating];
}

- (void)refresh
{
    [self loadTweet:YES];
}

- (void)loadMore
{
    [self loadTweet:NO];
}

- (void)loadTweet:(BOOL)refresh
{
    switch (self.typeIndex) {
        case COTweetPublic:
            [self loadPublic:refresh];
            break;
       case COTweetFriend:
            [self loadFriend:refresh];
            break;
       case COTweetHot:
            [self loadHot:refresh];
            break;
        case COTweetUser:
            [self loadUser:refresh];
            break;
            
        default:
            break;
    }
}

- (void)loadUser:(BOOL)refresh
{
    COUserPublicTweetRequest *tweet = [COUserPublicTweetRequest request];
    if (refresh) {
        tweet.lastId = @(COLastId);
    }
    else {
        COTweet *last = self.userTweets.lastObject;
        if (last) {
            tweet.lastId = @(last.tweetId);
        }
        else {
            tweet.lastId = @(COLastId);
        }
    }
    tweet.userId = @(self.user.userId);
    __weak typeof(self) weakself = self;
    [tweet getWithSuccess:^(CODataResponse *responseObject) {
        [COEmptyView removeFormView:weakself.view];
        [weakself stopHud];
        [weakself showTweet:responseObject.data refresh:refresh typeIndex:COTweetUser];
    } failure:^(NSError *error) {
        [weakself stopHud];
        [weakself showErrorReloadView:^{
            [weakself loadUser:refresh];
        } padding:UIEdgeInsetsMake(44.0, 0.0, 0.0, 0.0)];
    }];
}

- (void)loadPublic:(BOOL)refresh
{
    COPublicTweetRequest *tweet = [COPublicTweetRequest request];
    tweet.sort = @"time";
    if (refresh) {
        tweet.lastId = @(COLastId);
    }
    else {
        COTweet *last = self.publicTweets.lastObject;
        if (last) {
            tweet.lastId = @(last.tweetId);
        }
        else {
            tweet.lastId = @(COLastId);
        }
    }
    __weak typeof(self) weakself = self;
    [tweet getWithSuccess:^(CODataResponse *responseObject) {
        [COEmptyView removeFormView:weakself.view];
        [weakself stopHud];
        [weakself showTweet:responseObject.data refresh:refresh typeIndex:COTweetPublic];
    } failure:^(NSError *error) {
        [weakself stopHud];
        [weakself showErrorReloadView:^{
            [weakself loadPublic:refresh];
        } padding:UIEdgeInsetsMake(44.0, 0.0, 0.0, 0.0)];
    }];
}

- (void)loadHot:(BOOL)refresh
{
    COPublicTweetRequest *tweet = [COPublicTweetRequest request];
    if (refresh) {
        tweet.lastId = @(COLastId);
    }
    else {
        COTweet *last = self.hotTweets.lastObject;
        if (last) {
            tweet.lastId = @(last.tweetId);
        }
        else {
            tweet.lastId = @(COLastId);
        }
    }
    tweet.sort = @"hot";
    __weak typeof(self) weakself = self;
    [tweet getWithSuccess:^(CODataResponse *responseObject) {
        [COEmptyView removeFormView:weakself.view];
        [weakself stopHud];
        [weakself showTweet:responseObject.data refresh:refresh typeIndex:COTweetHot];
    } failure:^(NSError *error) {
        [weakself stopHud];
        [weakself showErrorReloadView:^{
            [weakself loadHot:refresh];
        } padding:UIEdgeInsetsMake(44.0, 0.0, 0.0, 0.0)];
    }];
}

- (void)loadFriend:(BOOL)refresh
{
    COFriendTweetRequest *tweet = [COFriendTweetRequest request];
    if (refresh) {
        tweet.lastId = @(COLastId);
    }
    else {
        COTweet *last = self.friendTweets.lastObject;
        if (last) {
            tweet.lastId = @(last.tweetId);
        }
        else {
            tweet.lastId = @(COLastId);
        }
    }
    __weak typeof(self) weakself = self;
    [tweet getWithSuccess:^(CODataResponse *responseObject) {
        [COEmptyView removeFormView:weakself.view];
        [weakself stopHud];
        [weakself showTweet:responseObject.data refresh:YES typeIndex:COTweetFriend];
    } failure:^(NSError *error) {
        [weakself stopHud];
        [weakself showErrorReloadView:^{
            [weakself loadFriend:refresh];
        } padding:UIEdgeInsetsMake(44.0, 0.0, 0.0, 0.0)];
    }];
}

- (void)showTweet:(NSArray *)data refresh:(BOOL)refresh typeIndex:(NSInteger)index
{
    NSMutableArray *tweetdata = nil;
    switch (index) {
        case COTweetPublic:
            tweetdata = self.publicTweets;
            break;
        case COTweetFriend:
            tweetdata = self.friendTweets;
            break;
        case COTweetHot:
            tweetdata = self.hotTweets;
            break;
        case COTweetUser:
            tweetdata = self.userTweets;
            break;
            
        default:
            break;
    }

    if (refresh) {
        [tweetdata removeAllObjects];
        if (index == self.typeIndex) {
            if (data.count == 0) {
                [self showEmptyView];
            }
            else {
                [self removeEmptyView];
            }
        }
    }
    
    [tweetdata addObjectsFromArray:data];
    if (index == self.typeIndex) {
        [self.tableView reloadData];
    }
}

- (void)showEmptyView
{
    [COEmptyView removeFormView:self.view];
    
    COEmptyView *view = [COEmptyView emptyViewWithImage:[UIImage imageNamed:@"blankpage_image_Hi"] andTips:@"无冒泡\n来，冒个泡吧"];
    [view showInView:self.view padding:UIEdgeInsetsMake(50.0, 0.0, 0.0, 0.0)];
}

- (void)removeEmptyView
{
    [COEmptyView removeFormView:self.view];
}

- (void)showTweetDetail:(COTweet *)tweet
{
    COTweetDetailViewController *c = [self.storyboard instantiateViewControllerWithIdentifier:@"COTweetDetailViewController"];
    c.tweet = tweet;
    CGFloat width = 759.0;
    if (self.user) {
        width = 564.0;
    }
    c.targetWidth = width;
    [self.navigationController pushViewController:c animated:YES];
}

#pragma mark -
- (UIImage *)imageForBackgroud
{
    return [UIImage imageNamed:@"background_bubble"];
}

#pragma mark - Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    COTweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"COTweetCell"];
    
    CGFloat width = 759.0;
    if (self.user) {
        width = 564.0;
    }
    
    COTweet *tweet = self.tweets[indexPath.row];
    [cell assignWithTweet:tweet width:width];
    
    __weak typeof(self) weakself = self;
    
    [cell addLinkBlock:^(HtmlMediaItem *item) {
//        NSLog(@"%@", item.href);
//        COWebViewController *wc = [COWebViewController webVCWithUrlStr:item.href];
//        [self rootPushViewController:wc animated:YES];
        [weakself analyseLinkStr:item.href];
    }];
    
    [cell addDeleteBlock:^(COTweetComment *comment) {
        if ([comment.owner.globalKey isEqualToString:[COSession session].user.globalKey]) {
            UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"删除此评论" buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
                if (index == 0) {
                    [weakself deleteComment:comment ofTweet:tweet];
                }
            }];
            [actionSheet showInView:weakself.view];
        } else {
            COTweetAddCommentController *commentVC = [COTweetAddCommentController show:tweet];
            [commentVC AtUser:comment.owner.name];
        }
    }];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForBasicCellAtIndexPath:indexPath];
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath
{
    static COTweetCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:@"COTweetCell"];
    });
    
    
    COTweet *tweet = self.tweets[indexPath.row];
    if (tweet.height == 0.0) {
        CGFloat width = 759.0;
        if (self.user) {
            width = 564.0;
        }
        [sizingCell assignWithTweet:self.tweets[indexPath.row] width:width];
    }

//    NSLog(@"%.2f %.2f %@", tweet.contentHeight, tweet.height, tweet.content);
    return tweet.height;//[self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell
{
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
//    [sizingCell updateConstraints];
    
    CGSize size = sizingCell.contentView.frame.size; //[sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
//    NSLog(@"---> %.2f", size.height);
    return size.height + 1.0f; // Add 1.0f for the cell separator height
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self showTweetDetail:self.tweets[indexPath.row]];
}

#pragma mark -
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
