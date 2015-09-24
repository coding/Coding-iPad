//
//  COProjectActivity.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/24.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
#import "COUser.h"
#import "COProject.h"
#import "COFolder.h"
#import "COTask.h"
#import "COTopic.h"
#import "COGitTree.h"

typedef enum : NSUInteger {
    COProjectActivityTypeAll = 0,
    COProjectActivityTypeTask,
    COProjectActivityTypeTopic,
    COProjectActivityTypeFile,
    COProjectActivityTypeCode,
    COProjectActivityTypeOther
} COProjectActivityType;

@interface COProjectFileComment : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy)   NSString *content;
@property (nonatomic, copy)   COUser *owner;
@property (nonatomic, assign) NSInteger fileCommentId;

@end

@interface COProjectActivity : MTLModel<MTLJSONSerializing>

@property (nonatomic, assign) NSInteger activityID;
@property (nonatomic, copy)   NSString *targetType;
@property (nonatomic, copy)   NSString *actionMsg;
@property (nonatomic, copy)   NSString *action;
@property (nonatomic, assign) NSTimeInterval createdAt;
@property (nonatomic, strong) COUser *user;
@property (nonatomic, copy)   NSString *content;

@property (nonatomic, strong) COProject *project;

// 任务
@property (nonatomic, strong) COTask *originTask;
@property (nonatomic, strong) COTask *task;
// 任务评论
@property (nonatomic, strong) COTaskComment *taskComment;
@property (nonatomic, strong) COTaskComment *originTaskComment;
// 讨论
@property (nonatomic, strong) COTopic *projectTopic;
// 文件
@property (nonatomic, copy)   NSString *fileType;
@property (nonatomic, strong) COFile *file;
// 代码
@property (nonatomic, strong) COGitDepot *depot;
@property (nonatomic, strong) COGitDepot *sourceDepot;
@property (nonatomic, copy)   NSString *refPath;
@property (nonatomic, copy)   NSString *oldShaPath;
@property (nonatomic, copy)   NSString *oldSha;
@property (nonatomic, copy)   NSString *ref;

@property (nonatomic, strong) NSArray *commits;

// pull reqeust
@property (nonatomic, copy) NSString *pullRequestTitle;
@property (nonatomic, copy) NSString *pullRequestPath;

// mergeRequestTitle
@property (nonatomic, copy) NSString *mergeRequestTitle;
@property (nonatomic, copy) NSString *mergeRequestPath;

@property (nonatomic, copy) NSString *commentContent;

// 成员（其他）
@property (nonatomic, strong) COUser *targetUser;

// line note
@property (nonatomic, strong) COProjectLineNote *lineNote;

// 文件评论
@property (nonatomic, strong) COProjectFileComment *fileComment;
@property (nonatomic, strong) COFile *projectFile;

@property (nonatomic, assign) float height;

@end
