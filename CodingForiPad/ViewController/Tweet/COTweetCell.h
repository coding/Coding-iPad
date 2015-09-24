//
//  COTweetCell.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/10.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COTweetImagesView.h"
#import "COHtmlContentView.h"
#import "COTweetCommentListView.h"
#import "COTweet.h"

@interface COTweetCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *avatar;
@property (nonatomic, weak) IBOutlet COHtmlContentView *tweetContentView;
@property (nonatomic, weak) IBOutlet COTweetImagesView *imagesView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (nonatomic, weak) IBOutlet UILabel *fromLabel;
@property (nonatomic, weak) IBOutlet UIButton *zanBtn;
@property (nonatomic, weak) IBOutlet UIButton *commentBtn;
@property (nonatomic, weak) IBOutlet COTweetCommentListView *commentList;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imagesHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationWith;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fromLabelSpace;
@property (weak, nonatomic) IBOutlet UIButton *locationBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imagesWidth;

- (void)addLinkBlock:(COItemLinkBlock)block;
- (void)addDeleteBlock:(COcommentDeleteBlock)block;

- (CGFloat)heightForWidth;
- (void)assignWithTweet:(COTweet *)tweet width:(CGFloat)width;

@end
