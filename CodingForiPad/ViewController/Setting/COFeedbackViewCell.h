//
//  COFeedbackViewCell.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/19.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCellIdentifier_FeedbackContent @"FeedbackContentCell"

@class COTopic;
@interface COFeedbackViewCell : UITableViewCell

@property (nonatomic, copy) void (^cellHeightChangedBlock)();

@property (nonatomic, copy) void (^addLabelBlock)();
@property (nonatomic, copy) void (^delLabelBlock)(NSInteger index);

@property (strong, nonatomic) COTopic *curTopic;

+ (CGFloat)cellHeightWithObj:(id)obj;

@end
