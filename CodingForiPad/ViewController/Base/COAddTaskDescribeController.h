//
//  COAddTaskDescribeController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/8.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@class COTask;
@class COTaskDescription;
@interface COAddTaskDescribeController : UIViewController

@property (nonatomic, strong) COTask *task;
@property (nonatomic, assign) NSInteger type;// 0新增 1修改

@end
