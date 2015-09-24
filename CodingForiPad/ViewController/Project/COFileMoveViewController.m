//
//  COFileMoveViewController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/7/25.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COFileMoveViewController.h"

@interface COFileMoveViewController ()

@end

@implementation COFileMoveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.folderId) {
        _moveBtn.enabled = YES;
    }
    else {
        _moveBtn.enabled = NO;
    }
    
    if ([self.folderId integerValue] == 0
        || self.folder.parentId != 0) {
        _createBtn.enabled = NO;
    }
    else {
        _createBtn.enabled = YES;
    }
    
    if (self.folderId == nil) {
        _createBtn.enabled = YES;
    }
    
    if (self.rootFolders == nil) {
        [self loadCount];
    }
    else {
        [self showFolders:self.rootFolders];
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        weakself.rootFolders = objects;
        [weakself showFolders:objects];
    }];
}

- (void)showFolders:(NSArray *)folders
{
    NSMutableArray *data = [NSMutableArray array];
    
    if (self.folderId == nil) {
        COFolder *defaultFolder = [[COFolder alloc] init];
        defaultFolder.fileId = 0;
        defaultFolder.type = 0;
        defaultFolder.name = @"默认文件夹";
        [data addObject:defaultFolder];
        [data addObjectsFromArray:folders];
    }
    else {
        for (COFolder *one in folders) {
            if (one.fileId == [self.folderId integerValue]) {
                [data addObjectsFromArray:one.subFolders];
                break;
            }
        }
    }
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id f = self.allFiles[indexPath.row];
    if ([f isKindOfClass:[COFolder class]]) {
        COFolder *folder = f;
        COFileMoveViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COFileMoveViewController"];
        controller.projectId = self.projectId;
        controller.folderId = @(folder.fileId);
        controller.folder = f;
        controller.filesCount = self.filesCount;
        controller.rootFolders = self.rootFolders;
        controller.srcFiles = self.srcFiles;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (IBAction)createFolderAction:(id)sender
{
    [self createFolder];
}

- (IBAction)moveBtnAction:(id)sender
{
    COMoveFileRequest *request = [COMoveFileRequest request];
    NSMutableArray *fileIds = [NSMutableArray array];
    for (COFile *file in self.srcFiles) {
        [fileIds addObject:[NSString stringWithFormat:@"%ld", (long)file.fileId]];
    }
    
    request.fileIds = [fileIds componentsJoinedByString:@","];
    request.projectId = @(self.projectId);
    request.destFolderId = self.folderId;
    
    __weak typeof(self) weakself = self;
    [request putWithSuccess:^(CODataResponse *responseObject) {
        if ([weakself checkDataResponse:responseObject]) {
            [weakself moveFinished];
        }
    } failure:^(NSError *error) {
        [weakself showErrorInHudWithError:error];
    }];
}

- (void)moveFinished
{
    NSEnumerator *re = [self.navigationController.childViewControllers reverseObjectEnumerator];
    id controller = nil;
    for (id one in re) {
        if (![one isKindOfClass:[COFileMoveViewController class]]) {
            controller = one;
            break;
        }
    }
    
    if (controller) {
        [self.navigationController popToViewController:controller animated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:COReloadFileNotification object:nil];
    }
}

@end
