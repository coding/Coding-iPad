//
//  COUserRePositionController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/28.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface COUserRePositionController : UIViewController

@property (nonatomic, copy) NSString *type;
@property (nonatomic, strong) NSArray *infoAry;
@property (nonatomic, strong) NSArray *selectedIndex;

@property (copy, nonatomic) void(^selectedBlock)(NSArray *selectedIndex, NSArray *selectedValue);

@end
