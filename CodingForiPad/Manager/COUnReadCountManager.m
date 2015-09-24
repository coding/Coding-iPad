//
//  COUnReadCountManager.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/8/23.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COUnReadCountManager.h"
#import "COAccountRequest.h"
#import "COProjectRequest.h"
#import "COSession.h"

#define kUnReadKey_messages @"messages"
#define kUnReadKey_notifications @"notifications"
#define kUnReadKey_project_update_count @"project_update_count"

@implementation COUnReadCountManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecameActivie:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

+ (instancetype)manager
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[[self class] alloc] init];
    });
    
    return manager;
}

- (void)applicationBecameActivie:(NSNotification *)n
{
    [self updateCount];
}

- (void)updateCount
{
    COUnreadCountRequest *request = [COUnreadCountRequest request];
    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        if (responseObject.code == 0
            && responseObject.error == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *dataDict = (NSDictionary *)responseObject.data;
                NSNumber *messages = [dataDict objectForKey:kUnReadKey_messages];
                NSNumber *notifications = [dataDict objectForKey:kUnReadKey_notifications];
                NSNumber *project_update_count = [dataDict objectForKey:kUnReadKey_project_update_count];
                [weakself updateMessage:[messages unsignedIntegerValue]];
                [weakself updateNotification:[notifications unsignedIntegerValue]];
                [weakself updateProject:[project_update_count unsignedIntegerValue]];
                NSInteger unreadCount = messages.integerValue +notifications.integerValue;
                [UIApplication sharedApplication].applicationIconBadgeNumber = unreadCount;
            });
        }
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)updateMessage:(NSUInteger)count
{
    [self willChangeValueForKey:@"messageCount"];
    _messageCount = count;
    [self didChangeValueForKey:@"messageCount"];
}

- (void)updateNotification:(NSUInteger)count
{
    [self willChangeValueForKey:@"notificationCount"];
    _notificationCount = count;
    [self didChangeValueForKey:@"notificationCount"];
}

- (void)updateProject:(NSUInteger)count
{
    [self willChangeValueForKey:@"projectCount"];
    _projectCount = count;
    [self didChangeValueForKey:@"projectCount"];
}

- (void)visitProject:(COProject *)project
{
    COProjectUpdateVisitRequest *request = [COProjectUpdateVisitRequest request];
    request.backendProjectPath = project.backendProjectPath;
    
    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        if (responseObject.code == 0
            && responseObject.error == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                project.unReadActivitiesCount = 0;
            });
            [weakself updateCount];
        }
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)readConversation:(COConversation *)conversation
{
    COConversationReadRequest *request = [COConversationReadRequest request];
    COUser *user = [COSession session].user;
    if ([conversation.sender.globalKey isEqualToString:user.globalKey]) {
        request.globalKey = conversation.friendUser.globalKey;
    }
    else {
        request.globalKey = conversation.sender.globalKey;
    }
    
    __weak typeof(self) weakself = self;
    [request postWithSuccess:^(CODataResponse *responseObject) {
        if (responseObject.code == 0
            && responseObject.error == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                conversation.unreadCount = 0;
            });
            [weakself updateCount];
        }
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)readNotification:(CONotification *)notification
{
    COMarkReadRequest *request = [COMarkReadRequest request];
    request.notificationId = notification.bId;
    __weak typeof(self) weakself = self;
    [request postWithSuccess:^(CODataResponse *responseObject) {
        if (responseObject.code == 0
            && responseObject.error == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                notification.status = @"1";
            });
            [weakself updateCount];
        }
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

@end
