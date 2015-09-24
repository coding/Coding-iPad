//
//  COFileViewController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/24.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COFileViewController.h"

#import "ZLPhoto.h"
#import "UICustomCollectionView.h"
#import "Coding_FileManager.h"
#import "UIMessageInputView_Media.h"
#import "UIMessageInputView_CCell.h"
#import <SVProgressHUD.h>
#import "NSString+Common.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import "UIActionSheet+Common.h"
#import "COFile+Ext.h"

@interface COFileViewController () <ZLPhotoPickerViewControllerDelegate, ZLPhotoPickerBrowserViewControllerDelegate>

@property (strong, nonatomic) NSMutableArray *mediaList, *uploadMediaList;
@property (strong, nonatomic) NSString *uploadingPhotoName;

@property (atomic, assign) NSInteger uploadIndex;

@end

@implementation COFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    if (self.folderId) {
        _uploadBtn.enabled = YES;
    }
    else {
        _uploadBtn.enabled = NO;
    }
    
    if ([self.folderId integerValue] == 0
        || self.folder.parentId != 0) {
        _createBtn.enabled = NO;
    }
    else {
        _createBtn.enabled = YES;
    }
    
    [self loadData];
    
    [self setUpRefresh:self.tableView];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationUploadCompled object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification *aNotification) {
        //{NSURLResponse: response, NSError: error, ProjectFile: data}
        NSDictionary *userInfo = [aNotification userInfo];
        [self completionUploadWithResult:[userInfo objectForKey:@"data"] error:[userInfo objectForKey:@"error"]];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data
- (void)refresh
{
    [self loadAllCount];
}

- (void)loadData
{
    if (self.folderId == nil) {
        [self loadAllCount];
    }
    else {
        [self loadFolderFile];
    }
}

- (void)reloadData
{
    [self loadAllCount];
}

- (void)loadAllCount
{
    COFoldersCountRequest *request = [COFoldersCountRequest request];
    request.projectId = self.projectId;
    
    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        [weakself.refreshCtrl endRefreshing];
        [COEmptyView removeFormView:weakself.view];
        if ([weakself checkDataResponse:responseObject]) {
            [weakself parseCount:responseObject.data];
            [weakself loadFolders];
        }
    } failure:^(NSError *error) {
        [weakself.refreshCtrl endRefreshing];
//        [weakself showError:error];
        [weakself showErrorReloadView:^{
            [weakself reloadData];
        } padding:UIEdgeInsetsMake(44.0, 0.0, 0.0, 0.0)];
    }];
}

- (void)parseCount:(NSArray *)data
{
    NSMutableDictionary *counts = [NSMutableDictionary dictionary];
    for (COFileCount *count in data) {
        [counts setObject:@(count.count) forKey:@(count.folderId)];
    }
    self.filesCount = [NSDictionary dictionaryWithDictionary:counts];
}

- (void)loadFolderFile
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
            [weakself showFiles:responseObject.data];
        }
    } failure:^(NSError *error) {
        [weakself.refreshCtrl endRefreshing];
//        [weakself showError:error];
        [weakself showErrorReloadView:^{
            [weakself reloadData];
        } padding:UIEdgeInsetsMake(44.0, 0.0, 0.0, 0.0)];
    }];
}

- (void)loadFolders
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
            [weakself showFolders:responseObject.data];
        }
    } failure:^(NSError *error) {
        [weakself.refreshCtrl endRefreshing];
//        [weakself showError:error];
        [weakself showErrorReloadView:^{
            [weakself reloadData];
        } padding:UIEdgeInsetsMake(44.0, 0.0, 0.0, 0.0)];
    }];
}

- (void)showFolders:(NSArray *)folders
{
    self.rootFolders = folders;
    if (self.folderId) {
        [self loadFolderFile];
        return;
    }
    
    NSMutableArray *data = [NSMutableArray array];
    if (self.folderId == nil) {
        COFolder *defaultFolder = [[COFolder alloc] init];
        defaultFolder.fileId = 0;
        defaultFolder.type = 0;
        defaultFolder.name = @"默认文件夹";
        [data addObject:defaultFolder];
    }
    [data addObjectsFromArray:folders];
    self.allFiles = [NSArray arrayWithArray:data];
    [self.tableView reloadData];
}

- (void)showFiles:(NSArray *)files
{
    for (COFolder *folder in self.rootFolders) {
        if (folder.fileId == [self.folderId integerValue]) {
            if ([folder.subFolders count] > 0) {
                self.folders = folder.subFolders;
            }
        }
    }
    
    self.files = files;
    
    NSMutableArray *data = [NSMutableArray array];
    [data addObjectsFromArray:self.folders];
    [data addObjectsFromArray:files];
    
    self.allFiles = [NSArray arrayWithArray:data];
    [self.tableView reloadData];
}

- (NSArray *)selectedFiles
{
    NSArray *selectedIndexList = [self.tableView indexPathsForSelectedRows];
    NSMutableArray *files = [NSMutableArray array];
    for (NSIndexPath *one in selectedIndexList) {
        [files addObject:self.allFiles[one.row]];
    }
    
    return files;
}

- (void)finishEdit
{
    [self.tableView setEditing:NO animated:YES];
    self.reverseBtn.hidden = YES;
    self.editView.hidden = YES;
    self.normalView.hidden = NO;
    [self.editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3];
}

#pragma mark -Action
- (IBAction)createFolderAction:(id)sender
{
    [self createFolder];
}

- (IBAction)uploadFileAction:(id)sender
{
    ZLPhotoPickerViewController *pickerVc = [[ZLPhotoPickerViewController alloc] init];
    pickerVc.topShowPhotoPicker = NO;
    pickerVc.minCount = 6;
    pickerVc.status = PickerViewShowStatusCameraRoll;
    pickerVc.delegate = self;
    [pickerVc show];
}

- (IBAction)downloadAction:(id)sender
{
    NSArray *selectedFiles = [self selectedFiles];
    if (selectedFiles.count > 0) {
        Coding_FileManager *manager = [Coding_FileManager sharedManager];
        for (COFile *file in selectedFiles) {
            if ([file hasBeenDownload] || [file cDownloadTask]) {//已下载，或正在下载
            }else{
                [manager addDownloadTaskForFile:file completionHandler:nil];
            }
        }
        [self finishEdit];
    }
}

- (IBAction)moveAction:(id)sender
{
    NSArray *selectedFiles = [self selectedFiles];
    if (selectedFiles.count > 0) {
        [self willMoveFiles:selectedFiles];
        [self finishEdit];
    }
}

- (IBAction)deleteAction:(id)sender
{
    NSArray *selectedFiles = [self selectedFiles];
    if (selectedFiles.count > 0) {
        [self willDeleteFiles:selectedFiles];
        [self finishEdit];
    }
}

- (IBAction)reverseBtnAction:(id)sender
{
    if (self.tableView.isEditing) {
        NSArray *selectedIndexList = [self.tableView indexPathsForSelectedRows];
        NSMutableArray *reverseIndexList = [NSMutableArray array];
        for (NSInteger index = 0; index < self.allFiles.count; index++) {
            if ([self.allFiles[index] isKindOfClass:[COFile class]]) {
                NSIndexPath *curIndex = [NSIndexPath indexPathForRow:index inSection:0];
                if (![selectedIndexList containsObject:curIndex]) {
                    [reverseIndexList addObject:curIndex];
                }
            }
        }
        
        for (NSIndexPath *indexPath in selectedIndexList) {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        for (NSIndexPath *indexPath in reverseIndexList) {
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

- (IBAction)editBtnAction:(id)sender
{
    if ([self.tableView isEditing]) {
        [self.tableView setEditing:NO animated:YES];
        [self.editBtn setTitle:@"编辑" forState:UIControlStateNormal];
        self.reverseBtn.hidden = YES;
        self.editView.hidden = YES;
        self.normalView.hidden = NO;
    }
    else {
        [self.tableView setEditing:YES animated:YES];
        [self.editBtn setTitle:@"完成" forState:UIControlStateNormal];
        self.reverseBtn.hidden = NO;
        self.editView.hidden = NO;
        self.normalView.hidden = YES;
    }
}

#pragma mark - ZLPhotoPickerViewControllerDelegate
- (void)pickerViewControllerDoneAsstes:(NSArray *)assets
{
    _uploadMediaList = [[NSMutableArray alloc] initWithCapacity:assets.count];
    for (ZLPhotoAssets *asset in assets) {
        [_uploadMediaList addObject:[UIMessageInputView_Media mediaWithAsset:asset.asset urlStr:nil]];
    }
    self.uploadIndex = 0;
    [self doUploadMediaList];
}

- (void)pickerCollectionViewSelectCamera:(ZLPhotoPickerViewController *)pickerVc
{
}

- (void)doUploadMediaList
{
    if (self.uploadIndex < _uploadMediaList.count) {
        [self doUploadMedia:_uploadMediaList[self.uploadIndex] withIndex:self.uploadIndex];
    } else {
        [self showSuccess:@"上传完毕"];
        [[NSNotificationCenter defaultCenter] postNotificationName:COReloadFileNotification object:nil];
        [self loadFolderFile];
    }
}

- (void)doUploadMedia:(UIMessageInputView_Media *)media withIndex:(NSInteger)index
{
    //保存到app内
    NSString* originalFileName = [[media.curAsset defaultRepresentation] filename];
    NSString *fileName = [NSString stringWithFormat:@"%@|||%@|||%@", @(self.projectId), self.folderId, originalFileName];
    
    if ([Coding_FileManager writeUploadDataWithName:fileName andAsset:media.curAsset]) {
        [SVProgressHUD showProgress:0 status:[NSString stringWithFormat:@"正在上传第 %ld 张图片...", (long)index +1]];
        media.state = UIMessageInputView_MediaStateUploading;
        self.uploadingPhotoName = originalFileName;
        Coding_UploadTask *uploadTask =[[Coding_FileManager sharedManager] addUploadTaskWithFileName:fileName projectIsPublic:self.project.isPublic];
        [RACObserve(uploadTask, progress.fractionCompleted) subscribeNext:^(NSNumber *fractionCompleted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showProgress:MAX(0, fractionCompleted.floatValue-0.05) status:[NSString stringWithFormat:@"正在上传第 %ld 张图片...", (long)index +1] maskType:SVProgressHUDMaskTypeBlack];
            });
        }];
    } else {
        media.state = UIMessageInputView_MediaStateUploadFailed;
        [self showErrorMessageInHud:[NSString stringWithFormat:@"%@ 文件处理失败", originalFileName]];
    }
}

- (void)completionUploadWithResult:(id)responseObject error:(NSError *)error
{
    //移除文件（共有项目不能自动移除）
//    NSString *diskFileName = [NSString stringWithFormat:@"%ld|||%@|||%@", (long)self.topic.projectId, @"0", self.uploadingPhotoName];
//    [Coding_FileManager deleteUploadDataWithName:diskFileName];
    if (error) {
        [self showErrorInHudWithError:error];
    }
    else {
        self.uploadIndex += 1;
        [self doUploadMediaList];
    }
}

@end
