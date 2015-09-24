//
//  COProjectController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/14.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COSplitController.h"
#import "COProject.h"

#define OPProjectReloadNotification @"OPProjectReloadNotification"

@interface COProjectController : COSplitController

@property (nonatomic, strong) COUser *user;

- (void)showProject:(COProject *)project;
- (void)showUserProjects:(COUser *)user;

@end
