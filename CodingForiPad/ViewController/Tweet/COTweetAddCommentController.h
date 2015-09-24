//
//  COTweetAddCommentController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/7/12.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@class COTweet;
@interface COTweetAddCommentController : UIViewController

@property (nonatomic, strong) COTweet *tweet;

+ (COTweetAddCommentController *)show:(COTweet *)tweet;

- (void)AtUser:(NSString *)name;

- (void)hideKeyboard;

@end
