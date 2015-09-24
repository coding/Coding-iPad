//
//  COMemberAddController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/24.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@class COProject;
@interface COMemberAddController : UIViewController

@property (nonatomic, strong) COProject *project;
@property (copy, nonatomic) void(^popSelfBlock)();

- (void)configAddedArrayWithMembers:(NSArray *)memberArray;

@end
