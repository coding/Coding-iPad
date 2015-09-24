//
//  COTweetViewController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/10.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COBaseViewController.h"
#import "COSegmentControl.h"
#import "COUser.h"

#define COTweetCommentNotification @"COTweetCommentNotification"
#define COTweetReloadNotification @"COTweetReloadNotification"
#define COTweetRefreshNotification @"COTweetRefreshNotification"
#define COTweetUserInfoNotification @"COTweetUserInfoNotification"
#define COTweetDeleteNotification @"COTweetDeleteNotification"
#define COTweetDetailNotification @"COTweetDetailNotification"
#define COTweetImageResizeNotification @"COTweetImageResizeNotification"

@interface COTweetViewController : COBaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) COUser *user;

@property (weak, nonatomic) IBOutlet UIView *headView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet COSegmentControl *segmentControl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableOffset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableLeft;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
