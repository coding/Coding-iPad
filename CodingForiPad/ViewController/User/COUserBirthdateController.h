//
//  COUserBirthdateController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/28.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface COUserBirthdateController : UIViewController

@property (nonatomic, strong) NSDate *selectedDate;

@property (copy, nonatomic) void(^selectedBlock)(NSDate *selectedDate);

@end
