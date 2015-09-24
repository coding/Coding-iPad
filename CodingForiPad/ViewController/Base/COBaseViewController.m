//
//  COBaseViewController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/10.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COBaseViewController.h"

@implementation COBaseViewController

- (void)setUpRefresh:(UITableView *)tableView
{
    self.refreshCtrl = [[ODRefreshControl alloc] initInScrollView:tableView];
    [self.refreshCtrl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
}

- (void)setUpLoadMore:(UITableView *)tableView
{
    [tableView addInfiniteScrollingWithActionHandler:^{
        [self loadMore];
    }];
}

- (void)refresh
{
    
}

- (void)loadMore
{
    
}

@end
