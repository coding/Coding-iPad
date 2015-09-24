//
//  TopicContentCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-27.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_TopicContent @"TopicContentCell"

#import <UIKit/UIKit.h>

@class COTopic;
typedef void (^CommentTopicBlock) ();
@interface TopicContentCell : UITableViewCell<UIWebViewDelegate>

@property (nonatomic, copy) void (^cellHeightChangedBlock)();
@property (nonatomic, copy) void (^loadRequestBlock)(NSURLRequest *curRequest);

@property (nonatomic, copy) void (^addLabelBlock)();
@property (nonatomic, copy) void (^delLabelBlock)(NSInteger index);

@property (nonatomic, copy) void (^deleteTopicBlock)(COTopic *);

+ (CGFloat)cellHeightWithObj:(id)obj md:(BOOL)isMD;

- (void)setCurTopic:(COTopic *)curTopic md:(BOOL)isMD;

@end
