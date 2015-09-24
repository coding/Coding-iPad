//
//  COPojectTaskViewController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/28.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COBaseViewController.h"
#import "COProject.h"

@interface COPojectTaskViewController : COBaseViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSString *backendProjectPath;
@property (nonatomic, assign) NSInteger projectId;
@property (nonatomic, strong) COProject *project;

@end
