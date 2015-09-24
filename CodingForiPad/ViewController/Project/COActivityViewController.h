//
//  COActivityViewController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/24.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COBaseViewController.h"
#import "COProject.h"

@interface COActivityViewController : COBaseViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, assign) NSInteger projectId;
@property (nonatomic, strong) COProject *project;

@end
