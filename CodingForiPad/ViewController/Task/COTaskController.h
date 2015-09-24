//
//  COTaskController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/14.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COSplitController.h"

@class COTask;
@interface COTaskController : COSplitController

- (void)showTask:(COTask *)task;

@end
