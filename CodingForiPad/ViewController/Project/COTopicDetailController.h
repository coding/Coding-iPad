//
//  COTopidDetailController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/24.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COBaseViewController.h"

@class COTopic;
@interface COTopicDetailController : COBaseViewController

@property (nonatomic, strong) COTopic *topic;

- (void)dismissPopover;

@end
