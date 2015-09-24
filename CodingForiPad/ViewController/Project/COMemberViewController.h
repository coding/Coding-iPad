//
//  COMemberViewController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/24.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COBaseViewController.h"

@class COProject;
@interface COMemberViewController : COBaseViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) COProject *project;

- (void)dismissPopover;

@end
