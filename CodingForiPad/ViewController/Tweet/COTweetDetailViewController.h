//
//  COTweetDetailViewController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/7/26.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COBaseViewController.h"
#import "COTweet.h"

@interface COTweetDetailViewController : COBaseViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) COTweet *tweet;
@property (nonatomic, assign) CGFloat targetWidth;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableRight;

- (void)loadTweetDetail:(NSString *)globalKey tweetId:(NSNumber *)tweetId;

@end
