//
//  COTaskPriorityController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/24.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@class COTask;
@interface COTaskPriorityController : UIViewController

@property (nonatomic, strong) COTask *task;
@property (nonatomic, assign) NSInteger type;// 0为任务修改 1为新任务设置

@end
