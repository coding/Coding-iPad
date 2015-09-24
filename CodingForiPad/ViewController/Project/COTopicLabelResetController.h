//
//  COTopicLabelReNameController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/24.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@class COTopic;
@class COTopicLabel;
@interface COTopicLabelResetController : UIViewController

@property (strong, nonatomic) COTopicLabel *ptLabel;
@property (nonatomic, strong) COTopic *topic;

@property (copy, nonatomic) void(^topicChangedBlock)(COTopicLabel *ptLabel);

@end
