//
//  COFileBaseViewController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/7/25.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COFileBaseViewController.h"
#import "COFileViewController.h"
#import "COFileBaseViewController.h"
#import "UIActionSheet+Common.h"
#import "Coding_FileManager.h"
#import "COFile+Ext.h"
#import "COFileMoveViewController.h"

@interface COFileBaseViewController ()

@end

@implementation COFileBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNotification:) name:COReloadFileNotification object:nil];
    if (self.folder) {
        self.titleLabel.text = [NSString stringWithFormat:@"%@：%@", self.project.name, self.folder.name];
    }
    else {
        self.titleLabel.text = [NSString stringWithFormat:@"%@：文档", self.project.name];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadNotification:(NSNotification *)n
{
    [self reloadData];
}

- (void)reloadData
{
    
}

- (void)loadAllFolder:(void (^)(id objects))result
{
    COFoldersRequest *request = [COFoldersRequest request];
    request.projectId = self.projectId;
    request.page = 1;
    request.pageSize = 1000;
    
    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        [weakself.refreshCtrl endRefreshing];
        [COEmptyView removeFormView:weakself.view];
        if ([weakself checkDataResponse:responseObject]) {
            result(responseObject.data);
        }
    } failure:^(NSError *error) {
        [weakself.refreshCtrl endRefreshing];
//        [weakself showError:error];
        [weakself showErrorReloadView:^{
            [weakself reloadData];
        } padding:UIEdgeInsetsMake(44.0, 0.0, 0.0, 0.0)];
    }];
}

- (void)loadAllCount:(void (^)(id objects))result
{
    COFoldersCountRequest *request = [COFoldersCountRequest request];
    request.projectId = self.projectId;
    
    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        [COEmptyView removeFormView:weakself.view];
        [weakself.refreshCtrl endRefreshing];
        if ([weakself checkDataResponse:responseObject]) {
            result(responseObject.data);
        }
    } failure:^(NSError *error) {
        [weakself.refreshCtrl endRefreshing];
//        [weakself showError:error];
        [weakself showErrorReloadView:^{
            [weakself reloadData];
        } padding:UIEdgeInsetsMake(44.0, 0.0, 0.0, 0.0)];
    }];
}

- (void)loadAllFile:(void (^)(id objects))result
{
    COFolderFilesRequest *request = [COFolderFilesRequest request];
    request.projectId = self.projectId;
    request.folderId = [self.folderId integerValue];
    request.height = @(90);
    request.width = @(90);
    
    __weak typeof(self) weakself = self;
    
    [request getWithSuccess:^(CODataResponse *responseObject) {
        [weakself.refreshCtrl endRefreshing];
        [COEmptyView removeFormView:weakself.view];
        if ([weakself checkDataResponse:responseObject]) {
            result(responseObject.data);
        }
    } failure:^(NSError *error) {
        [weakself.refreshCtrl endRefreshing];
//        [weakself showError:error];
        [weakself showErrorReloadView:^{
            [weakself reloadData];
        } padding:UIEdgeInsetsMake(44.0, 0.0, 0.0, 0.0)];
    }];
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allFiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    id f = self.allFiles[indexPath.row];
    if ([f isKindOfClass:[COFolder class]]) {
        COFolder *folder = f;
        COFolderCell *fcell = [tableView dequeueReusableCellWithIdentifier:@"COFolderCell"];
        [fcell assignWithFoler:f count:[self.filesCount[@(folder.fileId)] integerValue]];
        
        [fcell setRightUtilityButtons:[self rightButtonsForFolder] WithButtonWidth:85];
        fcell.delegate = self;
        
        cell = fcell;
    }
    else {
        COFileCell *fcell = [tableView dequeueReusableCellWithIdentifier:@"COFileCell"];
        [fcell assignWithFile:f projectId:_projectId];
        fcell.showBlock = ^void(COFile *file) {
            COFilePreViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COFilePreViewController"];
            controller.curFile = file;
            [self.navigationController pushViewController:controller animated:YES];
        };
        [fcell setRightUtilityButtons:[self rightButtonsForFile] WithButtonWidth:85];
        fcell.delegate = self;
        
        cell = fcell;
    }
    
    
    return cell;
}

- (NSArray *)rightButtonsForFolder
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1] icon:[UIImage imageNamed:@"icon_model_settag_rename"]];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:255/255.0 green:69/255.0 blue:98/255.0 alpha:1] icon:[UIImage imageNamed:@"icon_model_settag_delete"]];
    return rightUtilityButtons;
}

- (NSArray *)rightButtonsForFile
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1] icon:[UIImage imageNamed:@"icon_document_move"]];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:255/255.0 green:69/255.0 blue:98/255.0 alpha:1] icon:[UIImage imageNamed:@"icon_model_settag_delete"]];
    return rightUtilityButtons;
}
#pragma mark -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id f = self.allFiles[indexPath.row];
    if ([tableView isEditing]) {
        if ([f isKindOfClass:[COFolder class]]) {
            [self showInfoWithStatus:@"文件夹不能批处理"];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if ([f isKindOfClass:[COFolder class]]) {
            COFolder *folder = f;
            COFileViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COFileViewController"];
            controller.projectId = self.projectId;
            controller.folderId = @(folder.fileId);
            controller.folder = f;
            controller.project = self.project;
            controller.filesCount = self.filesCount;
            controller.rootFolders = self.rootFolders;
            [self.navigationController pushViewController:controller animated:YES];
        } else {
            COFilePreViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COFilePreViewController"];
            controller.curFile = f;
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

#pragma mark - SWTableViewCellDelegate
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    // 默认文件夹不能右扫
    if (self.folderId == nil) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        if (indexPath.row == 0) {
            return NO;
        }
    }
    return YES;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    [cell hideUtilityButtonsAnimated:YES];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    id f = self.allFiles[indexPath.row];
    if ([f isKindOfClass:[COFolder class]]) {
        if (index == 0) {
            // 重命名
            COCreateFolderViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COCreateFolderViewController"];
            controller.rename = YES;
            controller.projectId = @(self.projectId);
            COFolder *folder = f;
            controller.content = folder.name;
            controller.parentId = @(folder.fileId);
            [[CORootViewController currentRoot] popoverController:controller withSize:CGSizeMake(kPopWidthS, kPopHeightS)];
        }
        else {
            // 删除
            [self willDeleteFolder:f];
        }
    }
    else {
        //COFileCell *fileCell = (COFileCell *)cell;
        if (index == 0) {
            // 移动
            [self willMoveFiles:@[f]];
        } else {
            // 删除
            [self willDeleteFile:f];
        }
    }
}

- (void)willDeleteFolder:(COFolder *)folder
{
    NSString *title = [NSString stringWithFormat:@"确定要删除文件夹：%@？", folder.name];
    UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:title buttonTitles:@[@"确认删除"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
        switch (index) {
            case 0:
                [self didDeleteFolder:folder];
                break;
            default:
                break;
        }
    }];
    [actionSheet showInView:self.view];
}

- (void)didDeleteFolder:(COFolder *)folder
{
    CODeleteFolderRequest *request = [CODeleteFolderRequest request];
    request.projectId = @(self.projectId);
    request.folderId = @(folder.fileId);
    
    __weak typeof(self) weakself = self;
    [self showProgressHud];
    
    [request deleteWithSuccess:^(CODataResponse *responseObject) {
        [weakself dismissProgressHud];
        if ([weakself checkDataResponse:responseObject]) {
            [weakself reloadData];
        }
    } failure:^(NSError *error) {
        [weakself showErrorInHudWithError:error];
    }];
}

- (void)willDeleteFile:(COFile *)file
{
    __weak typeof(self) weakSelf = self;
    __weak typeof(file) weakFile = file;
    
    NSURL *fileUrl = [file hasBeenDownload];
    Coding_DownloadTask *cDownloadTask = [file cDownloadTask];
    UIActionSheet *actionSheet;
    
    if (fileUrl) {
        actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"只是删除本地文件还是连同服务器文件一起删除？" buttonTitles:@[@"仅删除本地文件"] destructiveTitle:@"一起删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
            switch (index) {
                case 0:
                    [weakSelf deleteFile:weakFile fromDisk:YES];
                    break;
                case 1:
                    [weakSelf deleteFile:weakFile fromDisk:NO];
                    break;
                default:
                    break;
            }
        }];
    }else if (cDownloadTask){
        actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"确定将服务器上的该文件删除？" buttonTitles:@[@"只是取消下载"] destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
            switch (index) {
                case 0:
                    [weakSelf deleteFile:weakFile fromDisk:YES];
                    break;
                case 1:
                    [weakSelf deleteFile:weakFile fromDisk:NO];
                    break;
                default:
                    break;
            }
        }];
    }else{
        actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"确定将服务器上的该文件删除？" buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
            if (index == 0) {
                [weakSelf deleteFile:weakFile fromDisk:NO];
            }
        }];
    }
    [actionSheet showInView:self.view];
}

- (void)deleteFile:(COFile *)file fromDisk:(BOOL)fromDisk{
    
    //    取消当前的下载任务
    Coding_DownloadTask *cDownloadTask = [file cDownloadTask];
    if (cDownloadTask) {
        [[Coding_FileManager sharedManager] removeCDownloadTaskForKey:file.storageKey];
    }
    //    删除本地文件
    NSURL *fileUrl = [file hasBeenDownload];
    NSString *filePath = fileUrl.path;
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:filePath]) {
        NSError *fileError;
        [fm removeItemAtPath:filePath error:&fileError];
        if (fileError) {
            [self showError:fileError];
        }
    }

    //    删除服务器文件
    if (!fromDisk) {
        [self didDeleteFiles:@[file]];
    }
}

- (void)willDeleteFiles:(NSArray *)files
{
    if ([files count] == 0) {
        return;
    }
    
    NSString *title = nil;

    title = [NSString stringWithFormat:@"确认删除选定的%ld个文档？\n删除后将无法恢复！", (unsigned long)files.count];
    
    UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:title buttonTitles:@[@"确认删除"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
        switch (index) {
            case 0:
                [self didDeleteFiles:files];
                break;
            default:
                break;
        }
    }];
    [actionSheet showInView:self.view];
}

- (void)didDeleteFiles:(NSArray *)files
{
    NSMutableArray *fileIds = [NSMutableArray array];
    for (COFile *file in files) {
        [fileIds addObject:[NSString stringWithFormat:@"%ld", (long)file.fileId]];
        [self deleteFile:file fromDisk:YES]; //先要处理正在下载的和已下载的文件
    }
    
    CODeleteFileRequest *request = [CODeleteFileRequest request];
    request.fileIds = [fileIds componentsJoinedByString:@","];
    
    request.projectId = @(self.projectId);
    
    __weak typeof(self) weakself = self;
    [self showProgressHud];
    
    [request deleteWithSuccess:^(CODataResponse *responseObject) {
        [weakself dismissProgressHud];
        if ([weakself checkDataResponse:responseObject]) {
            [weakself reloadData];
        }
    } failure:^(NSError *error) {
        [weakself showErrorInHudWithError:error];
    }];
}

- (void)willMoveFiles:(NSArray *)files
{
    COFileMoveViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COFileMoveViewController"];
    controller.projectId = self.projectId;
    controller.rootFolders = self.rootFolders;
    controller.project = self.project;
    controller.srcFiles = files;
    controller.filesCount = self.filesCount;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)createFolder
{
    COCreateFolderViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COCreateFolderViewController"];
    controller.projectId = @(self.projectId);
    controller.parentId = self.folderId;
    [[CORootViewController currentRoot] popoverController:controller withSize:CGSizeMake(kPopWidthS, kPopHeightS)];
}

- (IBAction)backBtnAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
