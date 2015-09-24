//
//  COTaskViewController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/10.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COBaseViewController.h"

@class COTask;
@interface COTaskDetailController : COBaseViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void)showTask:(COTask *)task;
- (void)showWithTaskPath:(NSString *)taskPath;
- (void)loadTaskDetail:(NSInteger)taskId backendProjectPath:(NSString *)backendProjectPath;

@end
