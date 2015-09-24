//
//  COUserReNameController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/28.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface COUserReNameController : UIViewController

@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *content;

@property (copy, nonatomic) void(^selectedBlock)(NSString *content);

@end
