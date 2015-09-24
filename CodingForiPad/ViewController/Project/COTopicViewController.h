//
//  COTopicViewController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/24.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COBaseViewController.h"

@class COProject;
@interface COTopicViewController : COBaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSString *backendProjectPath;
@property (nonatomic, strong) COProject *project;

@end
