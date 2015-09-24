//
//  COTweetCommentListView.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/18.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COHtmlContentView.h"
#import "COTweetLikeView.h"
#import "COTweet.h"

typedef void(^COcommentDeleteBlock)(COTweetComment *comment);

@interface COTweetCommentCell : UITableViewCell

@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) COHtmlContentView *commentView;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UIView *lineView;

- (void)assignWithComment:(COTweetComment *)comment;
+ (CGFloat)calcHeight:(COTweetComment *)comment width:(CGFloat)width;

@end

@interface COTweetCommentListView : UIView

@property (nonatomic, strong) COTweetLikeView *likeView;
@property (nonatomic, strong) UITableView *listView;
@property (nonatomic, assign) CGFloat targetWith;

- (void)addLinkBlock:(COItemLinkBlock)block;
- (void)addDeleteBlock:(COcommentDeleteBlock)block;

- (void)prepareForReuse;

- (void)assignWithTweet:(COTweet *)tweet;

+ (CGFloat)heightForTweet:(COTweet *)tweet width:(CGFloat)width;

@end
