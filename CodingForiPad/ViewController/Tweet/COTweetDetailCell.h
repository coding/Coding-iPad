//
//  COTweetDetailCell.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/8/16.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COTweetImagesView.h"
#import "COHtmlContentView.h"
#import "COTweetCommentListView.h"
#import "COTweet.h"

@interface COTweetDetailCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *avatar;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (nonatomic, weak) IBOutlet UILabel *fromLabel;
@property (nonatomic, weak) IBOutlet UIButton *zanBtn;
@property (nonatomic, weak) IBOutlet UIButton *commentBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationWith;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fromLabelSpace;
@property (weak, nonatomic) IBOutlet UIButton *locationBtn;
@property (weak, nonatomic) IBOutlet UIWebView *webContentView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet COTweetLikeView *tweetLikeView;
@property (nonatomic, strong) HtmlMedia *htmlMedia;
@property (nonatomic, copy) void (^loadRequestBlock)(NSURLRequest *curRequest);

@property (nonatomic, copy) void (^cellHeightChangedBlock) (CGFloat height);

- (void)assignWithTweet:(COTweet *)tweet;

@end
