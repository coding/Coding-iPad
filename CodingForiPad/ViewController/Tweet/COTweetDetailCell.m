//
//  COTweetDetailCell.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/8/16.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COTweetDetailCell.h"
#import "UIImageView+WebCache.h"
#import "COUtility.h"
#import "COTweetRequest.h"
#import "COTweetViewController.h"
#import "COTweetAddCommentController.h"
#import "COSession.h"
#import "WebContentManager.h"

@interface COTweetDetailCell()<UIWebViewDelegate>

@property (nonatomic, strong) COTweet *tweet;
@property (nonatomic, assign) CGFloat cellHeight;

@end

@implementation COTweetDetailCell

- (void)awakeFromNib
{
    _cellHeight = 0.0;
    self.avatar.layer.cornerRadius = 25.0;
    self.avatar.layer.masksToBounds = YES;
}

- (void)assignWithTweet:(COTweet *)tweet
{
    self.tweet = tweet;
    
    COUser *user = [[COSession session] user];
    if (user.userId == tweet.ownerId) {
        self.deleteBtn.hidden = NO;
    }
    else {
        self.deleteBtn.hidden = YES;
    }
    
    self.timeLabel.text = [COUtility timestampToBefore:tweet.createdAt];
    
    if ([tweet.location length] > 0) {
        [self.locationBtn setTitle:tweet.location forState:UIControlStateNormal];
        self.fromLabelSpace.constant = 10.0;
    }
    else {
        [self.locationBtn setTitle:@"" forState:UIControlStateNormal];
        self.fromLabelSpace.constant = -30.0;
    }
    
    [_avatar sd_setImageWithURL:[COUtility urlForImage:tweet.owner.avatar] placeholderImage:[COUtility placeHolder]];
    
    _nameLabel.text = tweet.owner.name;
    if ([tweet.device length] > 0) {
        _fromLabel.text = [NSString stringWithFormat:@"来自%@", tweet.device];
    }
    else {
        _fromLabel.text = @"";
    }
    
    _zanBtn.selected = tweet.liked;
    
    self.webContentView.delegate = self;
    self.webContentView.scrollView.scrollEnabled = NO;
    self.webContentView.scrollView.scrollsToTop = NO;
    self.webContentView.scrollView.bounces = NO;
    self.webContentView.backgroundColor = [UIColor clearColor];
    self.webContentView.opaque = NO;
    
    if (!_webContentView.isLoading) {
        [_activityIndicator startAnimating];
        self.htmlMedia = [HtmlMedia htmlMediaWithString:_tweet.content showType:MediaShowTypeNone];
        if (_htmlMedia.contentOrigional) {
            [self.webContentView loadHTMLString:[WebContentManager bubblePatternedWithContent:_htmlMedia.contentOrigional] baseURL:nil];
        }
    }
    
    if (_cellHeight > 0.0) {
        self.contentHeight.constant = _cellHeight;
    }
    
    [self.tweetLikeView prepareForReuse];
    if (_tweet.likeUsers) {
        [self.tweetLikeView assignWithUsers:_tweet.likeUsers];
    }
}

#pragma mark -
- (void)unlikeTweet
{
    self.tweet.liked = NO;
    NSMutableArray *users = [NSMutableArray array];
    for (COUser *user in _tweet.likeUsers) {
        if ([user.globalKey isEqualToString:[COSession session].user.globalKey]) {
            continue;
        }
        else {
            [users addObject:user];
        }
    }
    
    _tweet.likeUsers = [NSArray arrayWithArray:users];
    _tweet.likes = _tweet.likeUsers.count;
    [self.tweetLikeView prepareForReuse];
    [self.tweetLikeView assignWithUsers:_tweet.likeUsers];
    
    if ([_tweet.likeUsers count] == 0) {
        _cellHeightChangedBlock(_cellHeight + 155.0);
    }
    
    [_tweet cleanHeight];
    [[NSNotificationCenter defaultCenter] postNotificationName:COTweetCommentNotification object:nil];
}

- (void)likeTweet
{
    self.tweet.liked = YES;
    NSMutableArray *users = [NSMutableArray arrayWithObject:[COSession session].user];
    [users addObjectsFromArray:_tweet.likeUsers];
    NSInteger count = [_tweet.likeUsers count];
    _tweet.likeUsers = [NSArray arrayWithArray:users];
    _tweet.likes = _tweet.likeUsers.count;
    [self.tweetLikeView prepareForReuse];
    [self.tweetLikeView assignWithUsers:_tweet.likeUsers];
    
    if (count == 0) {
        _cellHeightChangedBlock(_cellHeight + 155.0);
    }
    
    [_tweet cleanHeight];
    [[NSNotificationCenter defaultCenter] postNotificationName:COTweetCommentNotification object:nil];
}

- (IBAction)avatarAction:(id)sender
{
    COUser *user = _tweet.owner;
    user.userId = _tweet.ownerId;
    [[NSNotificationCenter defaultCenter] postNotificationName:COTweetUserInfoNotification object:user];
}

- (IBAction)zanAction:(id)sender
{
    _zanBtn.selected = !_zanBtn.selected;
    
    if (_zanBtn.selected) {
        COTweetLikeRequest *request = [COTweetLikeRequest request];
        request.tweetId = @(self.tweet.tweetId);
        __weak typeof(self) weakself = self;
        [request postWithSuccess:^(CODataResponse *responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself likeTweet];
            });
        } failure:^(NSError *error) {
            // TODO: 处理错误
            weakself.zanBtn.selected = NO;
        }];
    }
    else {
        COTweetUnlikeRequest *request = [COTweetUnlikeRequest request];
        request.tweetId = @(self.tweet.tweetId);
        __weak typeof(self) weakself = self;
        [request postWithSuccess:^(CODataResponse *responseObject) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself unlikeTweet];
            });
        } failure:^(NSError *error) {
            // TODO: 处理错误
            weakself.zanBtn.selected = YES;
        }];
    }
}

- (IBAction)commentAction:(id)sender
{
    [COTweetAddCommentController show:_tweet];
}

- (IBAction)deleteBtnAction:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:COTweetDeleteNotification object:self.tweet];
}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *strLink = request.URL.absoluteString;
    if ([strLink rangeOfString:@"about:blank"].location != NSNotFound) {
        return YES;
    }else{
        if (_loadRequestBlock) {
            _loadRequestBlock(request);
        }
        return NO;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [_activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self refreshwebContentView];
    [_activityIndicator stopAnimating];
    CGFloat scrollHeight = webView.scrollView.contentSize.height;
    if (ABS(scrollHeight - _cellHeight) > 5) {
        _cellHeight = scrollHeight;
        webView.scalesPageToFit = YES;
        if (_cellHeightChangedBlock) {
            CGFloat h = 0;
            if (_tweet.likeUsers.count == 0) h = 105.0;
            else h = 155.0;
            _cellHeightChangedBlock(scrollHeight + h);
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [_activityIndicator stopAnimating];
//    if([error code] == NSURLErrorCancelled)
//        return;
//    else
//        DebugLog(@"%@", error.description);
}


- (void)refreshwebContentView
{
    if (_webContentView) {
        //修改服务器页面的meta的值
        NSString *meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\"", CGRectGetWidth(_webContentView.frame)];
        [_webContentView stringByEvaluatingJavaScriptFromString:meta];
    }
}

@end
