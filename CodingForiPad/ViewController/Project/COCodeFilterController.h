//
//  COCodeFilterController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/28.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface COCodeFilterController : UIViewController

@property (nonatomic, copy) void(^selectedBranchTagBlock)(NSString *branchTag);

@property (nonatomic, copy) NSString *backendProjectPath;
@property (nonatomic, copy) NSString *ref;

@end
