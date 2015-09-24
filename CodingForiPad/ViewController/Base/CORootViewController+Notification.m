//
//  CORootViewController+Notification.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/8/1.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "CORootViewController+Notification.h"
#import "UIViewController+Utility.h"
#import <RegexKitLite.h>
#import "COMesageController.h"
#import "CODataRequest.h"
#import "COTopicDetailController.h"
#import "COTopic.h"
#import "COUserController.h"
#import "COProjectDetailController.h"
#import "COTaskDetailController.h"
#import "COFilePreViewController.h"
#import "COFileViewController.h"
#import "COFileRootViewController.h"
#import "COAccountRequest.h"
#import "COUnReadCountManager.h"
#import <UIAlertView+BlocksKit.h>
#import "COConversationListController.h"

#define kUnReadKey_messages @"messages"
#define kUnReadKey_notifications @"notifications"
#define kUnReadKey_project_update_count @"project_update_count"

@implementation CORootViewController (Notification)

- (void)handleNotificationInfo:(NSDictionary *)userInfo applicationState:(UIApplicationState)applicationState
{
    [[COUnReadCountManager manager] updateCount];
    [[NSNotificationCenter defaultCenter] postNotificationName:COConversationListReloadNotification object:nil];
    if (applicationState == UIApplicationStateInactive) {
        //If the application state was inactive, this means the user pressed an action button from a notification.
        //标记为已读
//        NSString *notification_id = [userInfo objectForKey:@"notification_id"];
//        if (notification_id) {
//            CONotification *notification = [[CONotification alloc] init];
//            notification.bId = notification_id;
//            [[COUnReadCountManager manager] readNotification:notification];
//        }
        //弹出临时会话
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSString *param_url = [userInfo objectForKey:@"param_url"];
            [self showPushNotification:param_url];
        });
    }
//    else if (applicationState == UIApplicationStateActive){
//        [[NSNotificationCenter defaultCenter] postNotificationName:COConversationListReloadNotification object:nil];
//    }
}

- (void)showPushNotification:(NSString *)linkStr
{
    [self performSegueWithIdentifier:@"message" sender:self.msgBtn];
//    [self.msgController showPushNotification:linkStr];
}

@end