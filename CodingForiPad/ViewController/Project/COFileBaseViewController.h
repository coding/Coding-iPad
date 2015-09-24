//
//  COFileBaseViewController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/7/25.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COBaseViewController.h"
#import "COProject.h"
#import "COFileRequest.h"
#import "COFolder.h"
#import "SWTableViewCell.h"
#import "COFileRequest.h"
#import "COFileCell.h"
#import "COFolder.h"
#import "COSubFolderCell.h"
#import "COFolderCell.h"
#import "COFilePreViewController.h"
#import "COCreateFolderViewController.h"
#import "CORootViewController.h"

#define COReloadFileNotification @"COReloadFileNotification"

@interface COFileBaseViewController : COBaseViewController <UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, assign) NSInteger projectId;
@property (nonatomic, strong) NSNumber *folderId;
@property (nonatomic, strong) NSArray *rootFolders;
@property (nonatomic, strong) COProject *project;
@property (nonatomic, strong) COFolder *folder;
@property (nonatomic, strong) NSDictionary *filesCount;


@property (nonatomic, strong) NSArray *allFiles;
@property (nonatomic, strong) NSArray *files;
@property (nonatomic, strong) NSArray *folders;

- (void)reloadData;

- (void)loadAllFolder:(void (^)(id objects))result;
- (void)loadAllCount:(void (^)(id objects))result;
- (void)loadAllFile:(void (^)(id objects))result;

- (void)createFolder;
- (void)willDeleteFiles:(NSArray *)files;
- (void)willMoveFiles:(NSArray *)files;

- (IBAction)backBtnAction:(id)sender;

@end
