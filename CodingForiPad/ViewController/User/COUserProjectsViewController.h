//
//  COUserProjectsViewController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/8/12.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COBaseViewController.h"
#import "COUser.h"

@interface COUserProjectsViewController : COBaseViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) COUser *user;

- (void)loadProjects;

@end
