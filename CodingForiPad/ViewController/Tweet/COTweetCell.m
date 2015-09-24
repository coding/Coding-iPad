//
//  COTweetCell.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/10.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COTweetCell.h"
#import "UIImageView+WebCache.h"
#import "COUtility.h"
#import "COTweetRequest.h"
#import "COTweetViewController.h"
#import "COTweetAddCommentController.h"
#import "COSession.h"
#import "ImageSizeManager.h"

@interface COTweetCell()

@property (nonatomic, strong) COTweet *tweet;

@end

@implementation COTweetCell

- (void)initSubviews
{
//    self.avatar = [[UIImageView alloc] initWithFrame:CGRectZero];
//    self.tweetContentView = [[COHtmlContentView alloc] initForTweetContent];
}

- (void)awakeFromNib
{
    self.avatar.layer.cornerRadius = 25.0;
    self.avatar.layer.masksToBounds = YES;
    [_tweetContentView configForTweetContent];
}

- (void)prepareForReuse
{
    [self.commentList prepareForReuse];
}

- (void)addLinkBlock:(COItemLinkBlock)block
{
    [self.tweetContentView addLinkBlock:block];
    [self.commentList addLinkBlock:block];
}

- (void)addDeleteBlock:(COcommentDeleteBlock)block
{
    [self.commentList addDeleteBlock:block];
}

- (CGFloat)heightForWidth
{
    // TODO: 计算高度
    return 0.0;
}

- (void)assignWithTweet:(COTweet *)tweet width:(CGFloat)width
{
    self.tweet = tweet;
    self.commentList.targetWith = width;
    
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
    [_tweetContentView setHtmlContent:tweet.content];
    
    if (tweet.contentHeight == 0.0) {
        CGSize contentSize = [_tweetContentView.contentLabel sizeThatFits:CGSizeMake(width - 79.0, 12.0)];
        tweet.contentHeight = contentSize.height == 0 ? _tweetContentView.frame.size.height : contentSize.height;
        tweet.height = 130 + tweet.contentHeight;
//        NSLog(@"%.2f %.2f %@", tweet.contentHeight, tweet.height, tweet.content);
    }
    
    _nameLabel.text = tweet.owner.name;
    if ([tweet.device length] > 0) {
        _fromLabel.text = [NSString stringWithFormat:@"来自%@", tweet.device];
    }
    else {
        _fromLabel.text = @"";
    }
    
    // 洋葱猴和照片
    NSInteger imageCount = _tweetContentView.htmlMedia.imageItems.count;
    if (imageCount > 0) {
        // 有
        if (tweet.imagesHeight == 0.0) {
            if (imageCount == 1) {
                HtmlMediaItem *item = _tweetContentView.htmlMedia.imageItems.firstObject;
                if (item.type == HtmlMediaItemType_EmotionMonkey) {
                    tweet.imagesHeight = COMulityImageHeight + 10.0;
                }
                else {
                    if ([[ImageSizeManager shareManager] hasSrc:item.src]) {
                        CGSize size = [[ImageSizeManager shareManager] sizeWithSrc:item.src originalWidth:300.0 maxHeight:500.0];
                        tweet.imagesHeight = size.height + 10.0;
                    }
                    else {
                        tweet.imagesHeight = COSingleImageHeight + 10.0;
                    }
                }
            }
            else {
                tweet.imagesHeight = ((imageCount - 1) / 3 + 1) * (COMulityImageHeight + 10.0);
            }
            tweet.height += tweet.imagesHeight;
        }
        else {
            CGFloat height = 0.0;
            if (imageCount == 1) {
                HtmlMediaItem *item = _tweetContentView.htmlMedia.imageItems.firstObject;
                if (item.type == HtmlMediaItemType_EmotionMonkey) {
                    tweet.imagesHeight = COMulityImageHeight + 10.0;
                }
                else if ([[ImageSizeManager shareManager] hasSrc:item.src]) {
                    CGSize size = [[ImageSizeManager shareManager] sizeWithSrc:item.src originalWidth:300.0 maxHeight:500.0];
                    height = size.height + 10.0;
                    tweet.height -= tweet.imagesHeight;
                    tweet.height += height;
                    tweet.imagesHeight = height;
                }
            }
        }
    }
    if (imageCount == 1) {
        HtmlMediaItem *item = _tweetContentView.htmlMedia.imageItems.firstObject;
        if (item.type == HtmlMediaItemType_EmotionMonkey) {
            self.imagesWidth.constant = 150.0;
        }
        else {
            self.imagesWidth.constant = 300.0;
        }
    }
    else {
        self.imagesWidth.constant = 500.0;
    }

    
    CGRect frame = _imagesView.frame;
    frame.size.height = tweet.imagesHeight;
    _imagesView.frame = frame;
    _imagesHeight.constant = tweet.imagesHeight;
    _contentHeight.constant = tweet.contentHeight;
    [_imagesView loadImages:_tweetContentView.htmlMedia.imageItems];
    
    _zanBtn.selected = tweet.liked;
    if (tweet.commentHeight == 0.0) {
        CGFloat commentHeight = [COTweetCommentListView heightForTweet:tweet width:width];
        tweet.commentHeight = commentHeight;
        tweet.height += commentHeight;
    }
    _commentHeight.constant = tweet.commentHeight;
    if (tweet.comments == 0 && tweet.likes == 0) {
        _commentList.hidden = YES;
    }
    else {
        _commentList.hidden = NO;
    }
    [_commentList assignWithTweet:tweet];
}

#pragma mark -
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
                weakself.tweet.liked = YES;
                weakself.tweet.likes += 1;
                NSMutableArray *users = [NSMutableArray arrayWithObject:[COSession session].user];
                [users addObjectsFromArray:weakself.tweet.likeUsers];
                weakself.tweet.likeUsers = [NSArray arrayWithArray:users];
                [weakself.tweet cleanHeight];
                [[NSNotificationCenter defaultCenter] postNotificationName:COTweetRefreshNotification object:nil];
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
                weakself.tweet.liked = NO;
                weakself.tweet.likes -= 1;
                [weakself.tweet cleanHeight];
                NSMutableArray *users = [NSMutableArray arrayWithArray:weakself.tweet.likeUsers];
                for (COUser *user in users) {
                    if ([user.globalKey isEqualToString:[COSession session].user.globalKey]) {
                        [users removeObject:user];
                        break;
                    }
                }
                weakself.tweet.likeUsers = [NSArray arrayWithArray:users];
                [[NSNotificationCenter defaultCenter] postNotificationName:COTweetRefreshNotification object:nil];
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


@end
