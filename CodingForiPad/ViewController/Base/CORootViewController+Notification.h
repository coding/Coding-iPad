//
//  CORootViewController+Notification.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/8/1.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "CORootViewController.h"

@interface CORootViewController (Notification)

- (void)handleNotificationInfo:(NSDictionary *)userInfo applicationState:(UIApplicationState)applicationState;

@end
