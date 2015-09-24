//
//  COTaskViewController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/10.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COTaskDetailController.h"
#import "COTaskViewCell.h"
#import "COCommentCell.h"
#import "COTaskManagerController.h"
#import "COTaskProgressController.h"
#import "COTaskPriorityController.h"
#import "COTaskDeadlineController.h"
#import "CORootViewController.h"
#import "COTask.h"
#import "COTaskRequest.h"
#import "COPlaceHolderTextView.h"
#import "NSString+Emojize.h"
#import "TaskCommentCell.h"
#import "COAddTaskDescribeController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import <FBKVOController.h>
#import "ZLPhoto.h"
#import "UICustomCollectionView.h"
#import "Coding_FileManager.h"
#import "UIMessageInputView_Media.h"
#import "UIMessageInputView_CCell.h"
#import <SVProgressHUD.h>
#import "NSString+Common.h"
#import "COTaskListController.h"
#import "COSession.h"
#import "UIActionSheet+Common.h"
#import "UIViewController+Link.h"

#define kMessageInputView_MediaPadding 1.0

@interface COTaskDetailController () <ZLPhotoPickerViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ZLPhotoPickerBrowserViewControllerDataSource, ZLPhotoPickerBrowserViewControllerDelegate, TTTAttributedLabelDelegate>

@property (nonatomic, strong) COTask *task;
@property (nonatomic, strong) COTask *myCopyTask;
@property (nonatomic, strong) NSMutableArray *comments;

@property (weak, nonatomic) IBOutlet COPlaceHolderTextView *inputTextView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputHLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayout;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mediaHLayout;
@property (weak, nonatomic) IBOutlet UICustomCollectionView *mediaView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollHLayout;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) NSMutableArray *mediaList, *uploadMediaList;
@property (strong, nonatomic) NSString *uploadingPhotoName;

@property (nonatomic, strong) COUser *commentToUser;

@end

@implementation COTaskDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.comments = [NSMutableArray array];
    self.mediaList = @[].mutableCopy;
    self.uploadMediaList = @[].mutableCopy;
    
    _scrollView.layer.borderWidth = 0.5;
    _scrollView.layer.borderColor = [UIColor colorWithRed:155/255.0 green:155/255.0 blue:155/255.0 alpha:1.0].CGColor;
    _scrollView.layer.cornerRadius = 20;
    _scrollView.layer.masksToBounds = YES;
    _scrollView.alwaysBounceVertical = YES;
    
    [_inputTextView setPlaceholder:@"撰写评论"];
    _inputTextView.type = 1;
    
    _backBtn.hidden = [self.navigationController.viewControllers count] > 1 ? FALSE : TRUE;

    [_tableView registerClass:[TaskCommentCell class] forCellReuseIdentifier:kCellIdentifier_TaskComment];
    [_tableView registerClass:[TaskCommentCell class] forCellReuseIdentifier:kCellIdentifier_TaskComment_Media];
    
    _mediaView.scrollEnabled = NO;
    [_mediaView setBackgroundView:nil];
    [_mediaView setBackgroundColor:[UIColor clearColor]];
    [_mediaView registerClass:[UIMessageInputView_CCell class] forCellWithReuseIdentifier:kCCellIdentifier_UIMessageInputView_CCell];

    @weakify(self);
    RAC(self.okBtn, enabled) =
    [RACSignal combineLatest:@[RACObserve(self, myCopyTask.owner),
                               RACObserve(self, myCopyTask.priority),
                               RACObserve(self, myCopyTask.status),
                               RACObserve(self, myCopyTask.deadline),
                               RACObserve(self, task.taskDescription.markdown)] reduce:^id (COUser *owner, NSNumber *priority, NSNumber *status, NSString *deadline) {
                                   @strongify(self);
                                   BOOL enabled = ![self.myCopyTask isSameToTask:self.task];
                                   [self.tableView reloadData];
                                   return @(enabled);
                               }];
    [self.KVOController observe:self keyPath:@"myCopyTask.content" options:NSKeyValueObservingOptionNew block:^(id observer, NSString *content, NSDictionary *change) {
        self.okBtn.enabled = ![self.myCopyTask isSameToTask:self.task];
    }];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationUploadCompled object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification *aNotification) {
        //{NSURLResponse: response, NSError: error, ProjectFile: data}
        NSDictionary *userInfo = [aNotification userInfo];
        [self completionUploadWithResult:[userInfo objectForKey:@"data"] error:[userInfo objectForKey:@"error"]];
    }];
}

- (void)dealloc
{
    [self.KVOController unobserveAll];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([self.task.project.name length] > 0) {
        self.titleLabel.text = [NSString stringWithFormat:@"%@：任务详情", self.task.project.name];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(handleKeyboardWillShow:)
                   name:UIKeyboardWillShowNotification
                 object:nil];
    [center addObserver:self selector:@selector(handleKeyboardWillHide:)
                   name:UIKeyboardWillHideNotification
                 object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleKeyboardWillShow:(NSNotification *)paramNotification
{
    if (![_inputTextView isFirstResponder]) {
        return;
    }
    NSUInteger animationCurve = 0;
    double animationDuration = 0.0f;
    CGFloat height = [COUtility getKeyboardHeight:paramNotification andCurve:&animationCurve andDuration:&animationDuration];
    
    _bottomLayout.constant = height - 10;
    
    [UIView beginAnimations:@"changeViewFrame" context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    [self.view layoutIfNeeded];
    
    [UIView commitAnimations];
}

- (void)handleKeyboardWillHide:(NSNotification *)paramNotification
{
    NSUInteger animationCurve = 0;
    double animationDuration = 0.0f;
    [COUtility hideKeyboardInfo:paramNotification andCurve:&animationCurve andDuration:&animationDuration];
    
    _bottomLayout.constant = 0;
    
    [UIView beginAnimations:@"changeViewFrame" context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    [self.view layoutIfNeeded];
    
    [UIView commitAnimations];
}

- (void)showTask:(COTask *)task
{
    self.task = task;
    self.titleLabel.text = [NSString stringWithFormat:@"%@：任务详情", self.task.project.name];
    self.myCopyTask = [COTask taskWithTask:_task];
    
    _okBtn.enabled = FALSE;

    [_tableView reloadData];
   
    if (_task.hasDescription) {
        COTaskDescriptionRequest *request = [COTaskDescriptionRequest request];
        
        request.taskId = @(_task.taskId);
        
        __weak typeof(self) weakself = self;
        [request getWithSuccess:^(CODataResponse *responseObject) {
            if ([weakself checkDataResponse:responseObject]) {
                COTaskDescription *taskD = (COTaskDescription *)responseObject.data;
                weakself.task.taskDescription = taskD;
                [weakself.tableView reloadData];
            }
        } failure:^(NSError *error) {
            [weakself showError:error];
        }];
    }
    
    // 加载评论
    [self loadComments];
}

- (void)showWithTaskPath:(NSString *)taskPath
{
    NSArray *pathArray = [taskPath componentsSeparatedByString:@"/"];
    if (pathArray.count >= 7) {
        NSString *backentProjectPath = [NSString stringWithFormat:@"/user/%@/project/%@", pathArray[2], pathArray[4]];
        NSString *taskId = pathArray[6];
        [self loadTaskDetail:[taskId integerValue] backendProjectPath:backentProjectPath];
    }else{
        [self showErrorWithStatus:@"任务不存在"];
    }
}

- (void)loadTaskDetail:(NSInteger)taskId backendProjectPath:(NSString *)backendProjectPath
{
    COTaskDetailRequest *request = [COTaskDetailRequest request];
    request.backendProjectPath = backendProjectPath;
    request.taskId = @(taskId);
    
    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        [COEmptyView removeFormView:weakself.view];
        if ([weakself checkDataResponse:responseObject]) {
            [weakself showTask:responseObject.data];
        }
    } failure:^(NSError *error) {
//        [weakself showErrorInHudWithError:error];
        [weakself showErrorReloadView:^{
            [weakself loadTaskDetail:taskId backendProjectPath:backendProjectPath];
        } padding:UIEdgeInsetsMake(44.0, 0.0, 0.0, 0.0)];
    }];
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _task ? 1 + _comments.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        COTaskViewCell *taskCell = [tableView dequeueReusableCellWithIdentifier:@"COTaskViewCell"];
        [taskCell.managerBtn addTarget:self action:@selector(managerBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [taskCell.deadlineBtn addTarget:self action:@selector(deadlineBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [taskCell.priorityBtn addTarget:self action:@selector(priorityBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [taskCell.progressBtn addTarget:self action:@selector(progressBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [taskCell assignWithTask:_myCopyTask withDescribe:!(_task.hasDescription)];
        taskCell.commentsLabel.text = [NSString stringWithFormat:@"%lu条评论", (unsigned long)_comments.count];
        cell = taskCell;
    } else {
        COTaskComment *comment = _comments[indexPath.row - 1];
        TaskCommentCell *commentCell = [tableView dequeueReusableCellWithIdentifier:comment.htmlMedia.imageItems.count > 0 ? kCellIdentifier_TaskComment_Media : kCellIdentifier_TaskComment forIndexPath:indexPath];
        commentCell.curComment = comment;
        commentCell.contentLabel.delegate = self;
        cell = commentCell;
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return [COTaskViewCell cellHeight];
    }
    return [TaskCommentCell cellHeightWithObj:_comments[indexPath.row - 1]];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.view endEditing:YES];
    
    if (indexPath.row == 0) {
        return;
    } else {
        COTaskComment *comment = _comments[indexPath.row - 1];
        if ([comment.owner.globalKey isEqualToString:[COSession session].user.globalKey]) {
            // 删除
            __weak typeof(self) weakself = self;
            UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"删除此评论" buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
                if (index == 0) {
                    [weakself deleteComment:comment];
                }
            }];
            [actionSheet showInView:weakself.view];
        } else {
            // @评论
            self.commentToUser = comment.owner;
            [_inputTextView setPlaceholder:[NSString stringWithFormat:@"@%@", comment.owner.name]];
            [_inputTextView becomeFirstResponder];
        }
    }
}

- (void)deleteComment:(COTaskComment *)comment
{
    COTaskCommentDeleteRequest *request = [COTaskCommentDeleteRequest request];
    request.taskId = @(comment.taskId);
    request.commentId = @(comment.taskCommentId);
    
    __weak typeof(self) weakself = self;
    [request deleteWithSuccess:^(CODataResponse *responseObject) {
        if ([weakself checkDataResponse:responseObject]) {
            [weakself.comments removeObject:comment];
            weakself.myCopyTask.comments--;
            weakself.task.comments--;
            [weakself.tableView reloadData];
            
            //TODO: 刷新左边的列表
            [[NSNotificationCenter defaultCenter] postNotificationName:COTaskReloadNotification object:nil];
        }
    } failure:^(NSError *error) {
        [weakself showErrorInHudWithError:error];
    }];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // 按下return键
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        // 发送评论
        [self postComment:textView.text];
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    CGFloat h = textView.contentSize.height;
    if (h < kInputTextHeightMax) {
        _inputHLayout.constant = h > kInputTextHeightMin ? h : kInputTextHeightMin;
    }
    
    CGFloat mediaHeight = ceilf(_mediaList.count/3.0)* ([self collectionView:_mediaView layout:nil sizeForItemAtIndexPath:nil].height+ kMessageInputView_MediaPadding) - kMessageInputView_MediaPadding;
    _mediaHLayout.constant = mediaHeight;
    if (mediaHeight + _inputHLayout.constant < kInputTextHeightMax) {
        _scrollHLayout.constant = kInputTextHeightMin + mediaHeight;
    } else {
        _scrollHLayout.constant = kInputTextHeightMin + kInputTextHeightMax - _inputHLayout.constant;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

- (void)changeHeight
{
    CGFloat mediaHeight = ceilf(_mediaList.count/3.0)* ([self collectionView:_mediaView layout:nil sizeForItemAtIndexPath:nil].height+ kMessageInputView_MediaPadding) - kMessageInputView_MediaPadding;
    _mediaHLayout.constant = mediaHeight;
    if (mediaHeight + _inputHLayout.constant < kInputTextHeightMax) {
        _scrollHLayout.constant = kInputTextHeightMin + mediaHeight;
    } else {
        _scrollHLayout.constant = kInputTextHeightMin + kInputTextHeightMax - _inputHLayout.constant;
    }
}

#pragma mark - click
- (void)managerBtnClick
{
    [self.view endEditing:YES];

    COTaskManagerController *popoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"COTaskManagerController"];
    popoverVC.task = _myCopyTask;
    [[CORootViewController currentRoot] popoverController:popoverVC withSize:CGSizeMake(kPopWidthS, kPopHeightS)];
}

- (void)deadlineBtnClick
{
    [self.view endEditing:YES];

    COTaskDeadlineController *popoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"COTaskDeadlineController"];
    popoverVC.task = _myCopyTask;
    [[CORootViewController currentRoot] popoverController:popoverVC withSize:CGSizeMake(kPopWidthS, kPopHeightSS)];
}

- (void)priorityBtnClick
{
    [self.view endEditing:YES];

    COTaskPriorityController *popoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"COTaskPriorityController"];
    popoverVC.task = _myCopyTask;
    [[CORootViewController currentRoot] popoverController:popoverVC withSize:CGSizeMake(kPopWidthS, kPopHeightSS)];
}

- (void)progressBtnClick
{
    [self.view endEditing:YES];

    COTaskProgressController *popoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"COTaskProgressController"];
    popoverVC.task = _myCopyTask;
    [[CORootViewController currentRoot] popoverController:popoverVC withSize:CGSizeMake(kPopWidthS, kPopHeightSS)];
}

#pragma makr - 
- (void)loadComments
{
    COTaskCommentsRequest *request = [COTaskCommentsRequest request];
    request.taskId = @(_task.taskId);
    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        if ([weakself checkDataResponse:responseObject]) {
            // TODO : show success
            [self showComments:responseObject.data];
        }
    } failure:^(NSError *error) {
        [weakself showErrorInHudWithError:error];
    }];
}

- (void)showComments:(NSArray *)tasks
{
    [self.comments removeAllObjects];
  
    [self.comments addObjectsFromArray:tasks];
    [self.tableView reloadData];
}

- (void)postComment:(NSString *)content
{
    NSMutableString *sendStr;
    if (_commentToUser) {
        sendStr = [NSMutableString stringWithFormat:@"@%@ %@", _commentToUser.name, self.inputTextView.text];
    } else {
        sendStr = [NSMutableString stringWithString:self.inputTextView.text];
    }
    if (_mediaList.count > 0) {
        [_mediaList enumerateObjectsUsingBlock:^(UIMessageInputView_Media *obj, NSUInteger idx, BOOL *stop) {
            [sendStr appendFormat:@"\n![图片](%@)", obj.urlStr];
        }];
    }
    if (sendStr && ![sendStr isEmpty]) {
        COTaskCommentRequest *request = [COTaskCommentRequest request];
        request.taskId = @(_task.taskId);
        request.content = [sendStr aliasedString];
        
        __weak typeof(self) weakself = self;
        [request postWithSuccess:^(CODataResponse *responseObject) {
            if ([weakself checkDataResponse:responseObject]) {
                [weakself.mediaList removeAllObjects];
                [weakself.mediaView reloadData];
                weakself.inputTextView.text = @"";
                [weakself.inputTextView resignFirstResponder];
                weakself.inputHLayout.constant = kInputTextHeightMin;
                [weakself changeHeight];
                
                weakself.commentToUser = nil;
                [weakself.inputTextView setPlaceholder:@"撰写评论"];
                
                //TODO: 重新取评论加载评论？还是直接插入一条算了
                [weakself loadComments];
                //TODO: 刷新左边的列表
                [[NSNotificationCenter defaultCenter] postNotificationName:COTaskReloadNotification object:nil];
            }
        } failure:^(NSError *error) {
            [weakself showErrorInHudWithError:error];
        }];
    }
}

#pragma mark - action
- (IBAction)deleteBtnAction:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    __weak typeof(self) weakself = self;
    UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"删除此任务" buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
        if (index == 0) {
            [weakself deleteTask:_task];
        }
    }];
    [actionSheet showInView:self.view];
}

- (void)deleteTask:(COTask *)toDelete
{
    if (toDelete.isRequesting) {
        return;
    }
    toDelete.isRequesting = YES;
    
    COTaskDetailRequest *request = [COTaskDetailRequest request];
    request.backendProjectPath = toDelete.project.backendProjectPath;
    request.taskId = @(toDelete.taskId);
    
    __weak typeof(self) weakself = self;
    [request deleteWithSuccess:^(CODataResponse *responseObject) {
        toDelete.isRequesting = NO;
        if ([weakself checkDataResponse:responseObject]) {
            if (self.navigationController.viewControllers.count > 1) {
                [self.navigationController popViewControllerAnimated:YES];
            }
            //TODO: 刷新左边的列表
            [[NSNotificationCenter defaultCenter] postNotificationName:COTaskReloadNotification object:nil];
        }
    } failure:^(NSError *error) {
        toDelete.isRequesting = NO;
        [weakself showErrorInHudWithError:error];
    }];
}

- (IBAction)describeBtnAction:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    COAddTaskDescribeController *popoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"COTaskDescribeVC"];
    popoverVC.task = _task;
    popoverVC.type = 1;
    [self.navigationController pushViewController:popoverVC animated:YES];
}

- (IBAction)backBtnAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)okBtnAction:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    // 保存修改
    [self showProgressHudWithMessage:@"正在修改任务"];
    COTaskUpdateRequest *reqeust = [COTaskUpdateRequest request];
    reqeust.taskId = @(_myCopyTask.taskId);
    reqeust.content = _myCopyTask.content;
    reqeust.priority = @(_myCopyTask.priority);
    reqeust.status = @(_myCopyTask.status);
    reqeust.deadline = _myCopyTask.deadline ? _myCopyTask.deadline : @"";
    reqeust.ownerId = @(_myCopyTask.ownerId);
    __weak typeof(self) weakself = self;
    [reqeust putWithSuccess:^(CODataResponse *responseObject) {
        if ([weakself checkDataResponse:responseObject]) {
            [weakself showSuccess:@"修改任务成功"];
            weakself.task.content = weakself.myCopyTask.content;
            weakself.task.owner = weakself.myCopyTask.owner;
            weakself.task.ownerId = weakself.myCopyTask.ownerId;
            if (weakself.task.status != weakself.myCopyTask.status) {
                [[NSNotificationCenter defaultCenter] postNotificationName:COTaskFinishedNotification object:weakself.myCopyTask];
            }
            weakself.task.status = weakself.myCopyTask.status;
            weakself.task.priority = weakself.myCopyTask.priority;
            weakself.task.deadline = weakself.myCopyTask.deadline;
            weakself.okBtn.enabled = FALSE;
            //TODO: 刷新左边的列表
            [[NSNotificationCenter defaultCenter] postNotificationName:COTaskReloadNotification object:nil];
            sender.enabled = NO;
        }
    } failure:^(NSError *error) {
        [weakself showErrorInHudWithError:error];
    }];
}

- (IBAction)photoBtnAction:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    ZLPhotoPickerViewController *pickerVc = [[ZLPhotoPickerViewController alloc] init];
    pickerVc.topShowPhotoPicker = NO;
    pickerVc.minCount = 6;
    pickerVc.status = PickerViewShowStatusCameraRoll;
    pickerVc.delegate = self;
    [pickerVc show];
}

#pragma mark - ZLPhotoPickerViewControllerDelegate
- (void)pickerViewControllerDoneAsstes:(NSArray *)assets
{
    _uploadMediaList = [[NSMutableArray alloc] initWithCapacity:assets.count];
    for (ZLPhotoAssets *asset in assets) {
        [_uploadMediaList addObject:[UIMessageInputView_Media mediaWithAsset:asset.asset urlStr:nil]];
    }
    [self doUploadMediaList];
}

- (void)pickerCollectionViewSelectCamera:(ZLPhotoPickerViewController *)pickerVc
{
}

#pragma uploadMedia
- (void)doUploadMediaList
{
    __block UIMessageInputView_Media *media = nil;
    __block NSInteger index = 0;
    [_uploadMediaList enumerateObjectsUsingBlock:^(UIMessageInputView_Media *obj, NSUInteger idx, BOOL *stop) {
        if (obj.state == UIMessageInputView_MediaStateInit) {
            media = obj;
            index = idx;
            *stop = YES;
        }
    }];
    if (media && media.curAsset) {
        [self doUploadMedia:media withIndex:index];
    } else {
        [self showSuccess:@"上传完毕"];
    }
}

- (void)doUploadMedia:(UIMessageInputView_Media *)media withIndex:(NSInteger)index
{
    //保存到app内
    NSString* originalFileName = [[media.curAsset defaultRepresentation] filename];
    NSString *fileName = [NSString stringWithFormat:@"%ld|||%@|||%@", (long)self.task.projectId, @"0", originalFileName];
    
    if ([Coding_FileManager writeUploadDataWithName:fileName andAsset:media.curAsset]) {
        [SVProgressHUD showProgress:0 status:[NSString stringWithFormat:@"正在上传第 %ld 张图片...", (long)index +1]];
        media.state = UIMessageInputView_MediaStateUploading;
        self.uploadingPhotoName = originalFileName;
        Coding_UploadTask *uploadTask =[[Coding_FileManager sharedManager] addUploadTaskWithFileName:fileName projectIsPublic:_task.project.isPublic];
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
    NSString *diskFileName = [NSString stringWithFormat:@"%ld|||%@|||%@", (long)self.task.projectId, @"0", self.uploadingPhotoName];
    [Coding_FileManager deleteUploadDataWithName:diskFileName];
    
    __block UIMessageInputView_Media *media = nil;
    [_uploadMediaList enumerateObjectsUsingBlock:^(UIMessageInputView_Media *obj, NSUInteger idx, BOOL *stop) {
        if (obj.state == UIMessageInputView_MediaStateUploading) {
            media = obj;
            *stop = YES;
        }
    }];
    if (!media) {
        return;
    } else {
        if (responseObject) {
            NSString *fileName = nil, *fileUrlStr = @"";
            if ([responseObject isKindOfClass:[NSString class]]) {
                fileUrlStr = responseObject;
            } else if ([responseObject isKindOfClass:[COFile class]]){
                COFile *curFile = responseObject;
                fileName = curFile.name;
                fileUrlStr = curFile.ownerPreview;
            }
            
            if (!fileName || [fileName isEqualToString:self.uploadingPhotoName]) {
                media.urlStr = fileUrlStr;
                media.state = UIMessageInputView_MediaStateUploadSucess;
                [self.mediaList addObject:media];
                [self.mediaView reloadData];
                [self changeHeight];
            }
        }
        if (media.state != UIMessageInputView_MediaStateUploadSucess) {
            media.state = UIMessageInputView_MediaStateUploadFailed;
        }
        [self doUploadMediaList];
    }
}

#pragma mark TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components
{
    HtmlMediaItem *clickedItem = [components objectForKey:@"value"];
    [self analyseLinkStr:clickedItem.href];
}

- (void)analyseLinkStr:(NSString *)linkStr
{
    if (linkStr.length <= 0) {
        return;
    }
    
    [self analyseVCFromLinkStr:linkStr showBlock:^(UIViewController *controller, COLinkShowType showType, NSString *link) {
        if (showType == COLinkShowTypeWeb) {
            [self rootPushViewController:controller animated:YES];
        }
        else if (showType == COLinkShowTypeRight) {
            [self.navigationController pushViewController:controller animated:YES];
        }
        else if (showType == COLinkShowTypePush) {
            [self rootPushViewController:controller animated:YES];
        }
        else if (showType == COLinkShowTypeUnSupport) {
            
        }
    }];
}

#pragma mark Collection M
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _mediaList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIMessageInputView_CCell *ccell = [collectionView dequeueReusableCellWithReuseIdentifier:kCCellIdentifier_UIMessageInputView_CCell forIndexPath:indexPath];
    [ccell setCurMedia:[_mediaList objectAtIndex:indexPath.row] andTotalCount:_mediaList.count];
    @weakify(self);
    ccell.deleteBlock = ^(UIMessageInputView_Media *toDelete){
        @strongify(self);
        [self.mediaList removeObject:toDelete];
        [self.mediaView reloadData];
        [self changeHeight];
    };
    return ccell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize ccellSize;
    CGFloat contentWidth = CGRectGetWidth(_inputTextView.frame);
    if (_mediaList.count <= 0) {
        ccellSize = CGSizeZero;
    } else if (_mediaList.count == 1) {
        ccellSize = CGSizeMake(contentWidth, 0.6*contentWidth);
    } else if (_mediaList.count == 2) {
        ccellSize = CGSizeMake((contentWidth - kMessageInputView_MediaPadding)/2, (contentWidth - kMessageInputView_MediaPadding)/3);
    } else {
        ccellSize = CGSizeMake((contentWidth - 2* kMessageInputView_MediaPadding)/3, (contentWidth - 2* kMessageInputView_MediaPadding)/3);
    }
    return ccellSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return kMessageInputView_MediaPadding;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return kMessageInputView_MediaPadding;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    // 显示大图
    [self setupPhotoBrowser:indexPath.row];
}

- (void)setupPhotoBrowser:(NSInteger)curIndex
{
    ZLPhotoPickerBrowserViewController *pickerBrowser = [[ZLPhotoPickerBrowserViewController alloc] init];
    pickerBrowser.status = UIViewAnimationAnimationStatusFade;
    pickerBrowser.delegate = self;
    pickerBrowser.dataSource = self;
    pickerBrowser.editing = NO;
    pickerBrowser.currentIndexPath = [NSIndexPath indexPathForRow:curIndex inSection:0];
    [pickerBrowser show];
}

#pragma mark - ZLPhotoPickerBrowserViewControllerDataSource
- (NSInteger)numberOfSectionInPhotosInPickerBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser
{
    return 1;
}

- (NSInteger)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser numberOfItemsInSection:(NSUInteger)section
{
    return _mediaList.count;
}

- (ZLPhotoPickerBrowserPhoto *)photoBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser photoAtIndexPath:(NSIndexPath *)indexPath
{
    UIMessageInputView_CCell *cell = (UIMessageInputView_CCell *)[self.mediaView cellForItemAtIndexPath:indexPath];
    UIMessageInputView_Media *mediaItem = _mediaList[indexPath.row];

    ZLPhotoPickerBrowserPhoto *photo = [ZLPhotoPickerBrowserPhoto photoAnyImageObjWith:cell.imgView];
    
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_queue_t queue = dispatch_queue_create("PhotoBrowserForAsset", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        [assetsLibrary assetForURL:mediaItem.assetURL resultBlock:^(ALAsset *asset) {
            mediaItem.curAsset = asset;
            photo.photoImage = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
            dispatch_semaphore_signal(semaphore);
        } failureBlock:^(NSError *error) {
            mediaItem.curAsset = nil;
            photo.photoURL = [NSURL URLWithString:mediaItem.urlStr]; // 图片路径
            dispatch_semaphore_signal(semaphore);
        }];
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    photo.toView = (UIImageView *)cell.imgView;
    return photo;
}

@end
