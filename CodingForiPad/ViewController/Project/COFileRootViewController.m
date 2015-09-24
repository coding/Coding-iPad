//
//  COFileRootViewController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/7/25.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COFileRootViewController.h"

@interface COFileRootViewController ()

@end

@implementation COFileRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self loadCount];
    
    [self setUpRefresh:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)refresh
{
    [self loadCount];
}

- (void)reloadData
{
    [self loadCount];
}

- (void)loadCount
{
    __weak typeof(self) weakself = self;
    [self loadAllCount:^(id objects) {
        [weakself parseCount:objects];
        [weakself loadFolder];
    }];
}

- (void)loadFolder
{
    __weak typeof(self) weakself = self;
    [self loadAllFolder:^(id objects) {
        [weakself showFolders:objects];
    }];
}

- (void)showFolders:(NSArray *)folders
{
    self.rootFolders = folders;
    
    NSMutableArray *data = [NSMutableArray array];
    COFolder *defaultFolder = [[COFolder alloc] init];
    defaultFolder.fileId = 0;
    defaultFolder.type = 0;
    defaultFolder.name = @"默认文件夹";
    [data addObject:defaultFolder];
    [data addObjectsFromArray:folders];
    
    self.allFiles = [NSArray arrayWithArray:data];
    [self.tableView reloadData];
}

- (void)parseCount:(NSArray *)data
{
    NSMutableDictionary *counts = [NSMutableDictionary dictionary];
    for (COFileCount *count in data) {
        [counts setObject:@(count.count) forKey:@(count.folderId)];
    }
    self.filesCount = [NSDictionary dictionaryWithDictionary:counts];
}

- (IBAction)createFolderAction:(id)sender
{
    [self createFolder];
}

@end
