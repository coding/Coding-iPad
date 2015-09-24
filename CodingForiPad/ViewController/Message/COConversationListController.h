//
//  COConversationListController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/23.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COBaseViewController.h"

#define COConversationListReloadNotification @"COConversationListReloadNotification"

@interface COConversationListController : COBaseViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *msgCountView;
@property (weak, nonatomic) IBOutlet UIView *notifCountView;

- (void)showPushNotification:(NSString *)linkStr;

@end
