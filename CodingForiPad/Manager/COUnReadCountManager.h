//
//  COUnReadCountManager.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/8/23.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "COProject.h"
#import "COConversation.h"

@interface COUnReadCountManager : NSObject

@property (nonatomic, readonly, assign) NSUInteger messageCount;
@property (nonatomic, readonly, assign) NSUInteger notificationCount;
@property (nonatomic, readonly, assign) NSUInteger projectCount;

+ (instancetype)manager;

- (void)updateCount;

- (void)visitProject:(COProject *)project;
- (void)readConversation:(COConversation *)conversation;
- (void)readNotification:(CONotification *)notification;

@end
