//
//  COUserReTagController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/28.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface COUserReTagController : UIViewController

@property (strong, nonatomic) NSArray *allTags;
@property (strong, nonatomic) NSArray *selectedTags;

@property (copy, nonatomic) void(^selectedBlock)(NSArray *selectedTags);

@end
