//
//  COBaseViewController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/10.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+Utility.h"
#import "ODRefreshControl.h"
#import <SVPullToRefresh.h>
#import "COEmptyView.h"

@interface COBaseViewController : UIViewController

@property (nonatomic, strong) ODRefreshControl *refreshCtrl;

- (void)setUpRefresh:(UITableView *)tableView;
- (void)setUpLoadMore:(UITableView *)tableView;
- (void)refresh;
- (void)loadMore;

@end
