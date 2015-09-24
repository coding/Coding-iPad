//
//  COTopic+Ext.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/9/21.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COTopic+Ext.h"
#import "COSession.h"

@implementation COTopic (Ext)
- (BOOL)canEdit
{
    return (self.ownerId == [COSession session].user.userId                 // 讨论创建者
            || self.project.ownerId == [COSession session].user.userId);    // 项目创建者
}

+ (COTopic *)topicWithPro:(COProject *)pro
{
    COTopic *topic = [[COTopic alloc] init];
    topic.owner = [COSession session].user;
    topic.ownerId = [COSession session].user.userId;
    topic.project = pro;
    topic.projectId = pro.projectId;
    return topic;
}

+ (COTopic *)feedbackTopic
{
    COTopic *topic = [[COTopic alloc] init];
    topic.project = [COProject project_FeedBack];
    topic.projectId = topic.project.projectId;
    topic.owner = [COSession session].user;
    topic.ownerId = topic.owner.userId;
    return topic;
}

@end
