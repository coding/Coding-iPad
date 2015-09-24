//
//  COCodeViewController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/24.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COBaseViewController.h"
#import "COProject.h"

@interface COCodeViewController : COBaseViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
//@property (nonatomic, copy) NSString *gloabKey;
//@property (nonatomic, copy) NSString *project;
@property (nonatomic, strong) COProject *project;
@property (nonatomic, copy) NSString *ref;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *backendProjectPath;

@end
