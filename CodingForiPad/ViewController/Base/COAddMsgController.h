//
//  COAddMsgController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/8.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@class COUser;
@interface COAddMsgController : UIViewController

+ (UINavigationController *)popSelf;

@property (nonatomic, strong) COUser *user;
@property (nonatomic, assign) NSInteger type;// 默认0右上角发私信 1个人中心发私信

@end
