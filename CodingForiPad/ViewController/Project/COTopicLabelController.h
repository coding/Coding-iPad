//
//  COTopicLabelController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/24.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@class COTopic;
@interface COTopicLabelController : UIViewController

@property (nonatomic, strong) COTopic *topic;
@property (assign, nonatomic) BOOL isSaveChange;

@property (copy, nonatomic) void(^topicChangedBlock)();

@end
