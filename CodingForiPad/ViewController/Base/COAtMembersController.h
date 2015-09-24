//
//  COAtMembersController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/8.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@class COUser;
@interface COAtMembersController : UIViewController

@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger projectId;

@property (copy, nonatomic) void(^selectUserBlock)(COUser *selectedUser);

@end
