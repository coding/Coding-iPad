//
//  COSelectFriendsController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/8.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@class COUser;
@interface COAtFriendsController : UIViewController

@property (nonatomic, assign) NSInteger type;

@property (copy, nonatomic) void(^selectUserBlock)(COUser *selectedUser);

@end
