//
//  COAddTask2ProjectController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/8.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COProject.h"

@interface COAddTask2ProjectController : UIViewController

- (void)createTaskForProject:(COProject *)project;

+ (UINavigationController *)popSelf;

@end
