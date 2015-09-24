//
//  COTweetDetailViewController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/7/26.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COTweetDetailViewController.h"
#import "COTweetDetailCell.h"
#import "COTweetCommentListView.h"
#import "COTweetRequest.h"
#import "COTweetViewController.h"
#import "UIViewController+Link.h"
#import "ZLPhoto.h"
#import "COSession.h"
#import "COTweetAddCommentController.h"
#import "UIActionSheet+Common.h"
#import "COReportIllegalViewController.h"
#import "CORootViewController.h"

@interface COTweetDetailViewController () <ZLPhotoPickerBrowserViewControllerDataSource, ZLPhotoPickerBrowserViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, assign) CGFloat tweetHeight;

@end

@implementation COTweetDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    if (_targetWidth < 650.0) {
        self.tableLeft.constant = 5.0;
        self.tableRight.constant = 5.0;
    }
    else {
        self.tableLeft.constant = 85.0;
        self.tableRight.constant = 85.0;
    }
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (self.tweet) {
        [self loadComments];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNotification:) name:COTweetReloadNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNotification:) name:COTweetCommentNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(delTweetNotification:) name:COTweetDeleteNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)loadTweetDetail:(NSString *)globalKey tweetId:(NSNumber *)tweetId
{
    COTweetDetailRequest *request = [COTweetDetailRequest request];
    request.globalKey = globalKey;
    request.tweetId = tweetId;
    
//    [self showProgressHud];

    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
//        [weakself dismissProgressHud];
        if ([weakself checkDataResponse:responseObject]) {
            weakself.tweet = responseObject.data;
            [weakself loadComments];
        }
    } failure:^(NSError *error) {
        [weakself showErrorInHudWithError:error];
    }];
}

- (void)commentNotification:(NSNotification *)n
{
    [self.tableView reloadData];
}

- (void)reloadNotification:(NSNotification *)n
{
    [self loadComments];
}

- (void)delTweetNotification:(NSNotification *)n
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)moreBtnAction:(id)sender
{
    UIActionSheet *sheet = [UIActionSheet bk_actionSheetCustomWithTitle:nil buttonTitles:@[@"举报"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
        if (index == 0) {
            COReportIllegalViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COReportIllegalViewController"];
            controller.content = [NSString stringWithFormat:@"%@", @(self.tweet.tweetId)];
            [[CORootViewController currentRoot] popoverController:controller withSize:CGSizeMake(kPopWidth, kPopHeight)];
        }
    }];
    [sheet showInView:self.view];
}

- (IBAction)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadComments
{
    COTweetCommentsRequest *request = [COTweetCommentsRequest request];
    request.tweetId = @(_tweet.tweetId);
    request.page = 1;
    request.pageSize = 99999;
    
    __weak typeof(self) weakself = self;
//    [self showProgressHud];
    [request getWithSuccess:^(CODataResponse *responseObject) {
//        [weakself dismissProgressHud];
        if ([weakself checkDataResponse:responseObject]) {
            weakself.comments = responseObject.data;
            [weakself.tableView reloadData];
        }
    } failure:^(NSError *error) {
        [weakself showErrorInHudWithError:error];
    }];
}

#pragma mark -
#pragma mark loadCellRequest
- (void)loadRequest:(NSURLRequest *)curRequest {
    NSString *linkStr = curRequest.URL.absoluteString;
    [self analyseLinkStr:linkStr];
}

- (void)analyseLinkStr:(NSString *)linkStr {
    if (linkStr.length <= 0) {
        return;
    }
    
    //可能是图片链接
    int i = 0;
    for (HtmlMediaItem *item in _images) {
        if ((item.src.length > 0 && [item.src isEqualToString:linkStr])
            || (item.href.length > 0 && [item.href isEqualToString:linkStr])) {
            [self setupPhotoBrowser:i];
            return;
        }
        i ++;
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

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1 + _comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        COTweetDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"COTweetDetailCell"];
        
        cell.cellHeightChangedBlock = ^(CGFloat height){
            _tweetHeight = height;
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        };
        
        cell.loadRequestBlock = ^(NSURLRequest *curRequest){
            [self loadRequest:curRequest];
        };
        [cell assignWithTweet:self.tweet];
        self.images = cell.htmlMedia.imageItems;
        return cell;
    }
    else {
        COTweetCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"COTweetCommentCell"];
        [cell assignWithComment:_comments[indexPath.row - 1]];
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        if (_tweetHeight > 0.0) {
            return _tweetHeight;
        }
        return 110.0;
    }
    return [COTweetCommentCell calcHeight:_comments[indexPath.row - 1] width:_targetWidth];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        return;
    }
    
    // @某人评论或删除自己评论
    __weak typeof(self) weakself = self;
    COTweetComment *comment = _comments[indexPath.row - 1];
    if ([comment.owner.globalKey isEqualToString:[COSession session].user.globalKey]) {
        UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"删除此评论" buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
            if (index == 0) {
                [weakself deleteComment:comment ofTweet:weakself.tweet];
            }
        }];
        [actionSheet showInView:weakself.view];
    } else {
        COTweetAddCommentController *commentVC = [COTweetAddCommentController show:_tweet];
        [commentVC AtUser:comment.owner.name];
    }
}

- (void)deleteComment:(COTweetComment *)comment ofTweet:(COTweet *)tweet
{
    COTweetCommentDeleteRequest *request = [COTweetCommentDeleteRequest request];
    request.tweetId = @(tweet.tweetId);
    request.commentId = @(comment.tweetcommentId);
    
    __weak typeof(self) weakself = self;
    [request deleteWithSuccess:^(CODataResponse *responseObject) {
        if ([weakself checkDataResponse:responseObject]) {
            for (COTweetComment *cc in tweet.commentList) {
                if (cc.tweetcommentId == comment.tweetcommentId) {
                    [tweet.commentList removeObject:cc];
                    tweet.comments--;
                    break;
                }
            }
            [tweet cleanHeight];
            [[NSNotificationCenter defaultCenter] postNotificationName:COTweetCommentNotification object:nil];
        }
    } failure:^(NSError *error) {
        [weakself showErrorInHudWithError:error];
    }];
}

#pragma mark - ZLPhotoPickerBrowserViewControllerDataSource
- (NSInteger)numberOfSectionInPhotosInPickerBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser
{
    return 1;
}

- (NSInteger)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser numberOfItemsInSection:(NSUInteger)section
{
    return _images.count;
}

- (ZLPhotoPickerBrowserPhoto *)photoBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser photoAtIndexPath:(NSIndexPath *)indexPath
{
    HtmlMediaItem *item = _images[indexPath.row];
    ZLPhotoPickerBrowserPhoto *photo = [ZLPhotoPickerBrowserPhoto photoAnyImageObjWith:item.src];
    //photo.toView = cell.imageView;// 没有来源图
    return photo;
}

- (void)setupPhotoBrowser:(NSInteger)curIndex
{
    ZLPhotoPickerBrowserViewController *pickerBrowser = [[ZLPhotoPickerBrowserViewController alloc] init];
    pickerBrowser.status = UIViewAnimationAnimationStatusFade;
    pickerBrowser.delegate = self;
    pickerBrowser.dataSource = self;
    pickerBrowser.editing = NO;
    pickerBrowser.currentIndexPath = [NSIndexPath indexPathForRow:curIndex inSection:0];
    [pickerBrowser show];
}

@end
