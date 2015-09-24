//
//  COTopicEditController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/24.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COBaseViewController.h"

@class COTopic;
@interface COTopicEditController : COBaseViewController

@property (nonatomic, assign) NSInteger type;// 0新增 1修改
@property (nonatomic, strong) COTopic *topic;

@property (copy, nonatomic) void(^topicChangedBlock)();

- (void)dismissPopover;

@end
