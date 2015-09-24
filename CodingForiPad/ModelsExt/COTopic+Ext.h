//
//  COTopic+Ext.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/9/21.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COTopic.h"

@interface COTopic (Ext)

- (BOOL)canEdit;

+ (COTopic *)topicWithPro:(COProject *)pro;
+ (COTopic *)feedbackTopic;

@end
