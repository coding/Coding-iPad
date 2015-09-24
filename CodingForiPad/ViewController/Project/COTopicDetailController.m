//
//  COTopidDetailController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/24.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COTopicDetailController.h"
#import "COTopic+Ext.h"
#import "TopicContentCell.h"
#import "COTopicRequest.h"
#import "TopicCommentCell.h"
#import "COTopicLabelController.h"
#import "COPlaceHolderTextView.h"
#import "NSString+Emojize.h"
#import "COTopicEditController.h"
#import "ZLPhoto.h"
#import "UICustomCollectionView.h"
#import "Coding_FileManager.h"
#import "UIMessageInputView_Media.h"
#import "UIMessageInputView_CCell.h"
#import <SVProgressHUD.h>
#import "NSString+Common.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import "UIViewController+Link.h"
#import "COSession.h"
#import "UIActionSheet+Common.h"

#define kMessageInputView_MediaPadding 1.0

@interface COTopicDetailController () <ZLPhotoPickerViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ZLPhotoPickerBrowserViewControllerDataSource, ZLPhotoPickerBrowserViewControllerDelegate,TTTAttributedLabelDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet COPlaceHolderTextView *inputTextView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputHLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayout;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mediaHLayout;
@property (weak, nonatomic) IBOutlet UICustomCollectionView *mediaView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollHLayout;

@property (strong, nonatomic) NSMutableArray *mediaList, *uploadMediaList;
@property (strong, nonatomic) NSString *uploadingPhotoName;

@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, assign) NSInteger page;

@property (nonatomic, strong) UIViewController *popController;
@property (nonatomic, strong) UIButton *maskView;
@property (nonatomic, strong) UIView *popShadowView;

@property (nonatomic, strong) COUser *commentToUser;

@end

@implementation COTopicDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _titleLabel.text = _topic.project.name ? [NSString stringWithFormat:@"%@：讨论详情", _topic.project.name] : @"讨论详情";
    
    _scrollView.layer.borderWidth = 0.5;
    _scrollView.layer.borderColor = [UIColor colorWithRed:155/255.0 green:155/255.0 blue:155/255.0 alpha:1.0].CGColor;
    _scrollView.layer.cornerRadius = 20;
    _scrollView.layer.masksToBounds = YES;
    _scrollView.alwaysBounceVertical = YES;
    
    [_inputTextView setPlaceholder:@"撰写评论"];
    _inputTextView.type = 1;
    
    _mediaView.scrollEnabled = NO;
    [_mediaView setBackgroundView:nil];
    [_mediaView setBackgroundColor:[UIColor clearColor]];
    [_mediaView registerClass:[UIMessageInputView_CCell class] forCellWithReuseIdentifier:kCCellIdentifier_UIMessageInputView_CCell];
    
    self.page = 1;
    self.comments = @[].mutableCopy;
    self.mediaList = @[].mutableCopy;
    self.uploadMediaList = @[].mutableCopy;
    
    [_tableView registerClass:[TopicContentCell class] forCellReuseIdentifier:kCellIdentifier_TopicContent];
    [_tableView registerClass:[TopicCommentCell class] forCellReuseIdentifier:kCellIdentifier_TopicComment];
    [_tableView registerClass:[TopicCommentCell class] forCellReuseIdentifier:kCellIdentifier_TopicComment_Media];

    _editBtn.hidden = TRUE;
    [self refreshTopic];
    
    [self setUpRefresh:self.tableView];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationUploadCompled object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification *aNotification) {
        //{NSURLResponse: response, NSError: error, ProjectFile: data}
        NSDictionary *userInfo = [aNotification userInfo];
        [self completionUploadWithResult:[userInfo objectForKey:@"data"] error:[userInfo objectForKey:@"error"]];
    }];
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
    [_inputTextView resignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleKeyboardWillShow:(NSNotification *)paramNotification
{
    NSUInteger animationCurve = 0;
    double animationDuration = 0.0f;
    CGFloat height = [COUtility getKeyboardHeight:paramNotification andCurve:&animationCurve andDuration:&animationDuration];
    
    _bottomLayout.constant = height;
    
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

- (void)refresh
{
    [self refreshTopic];
}

- (void)refreshTopic
{
    COTopicDetailRequest *request = [COTopicDetailRequest request];
    request.topicId = @(_topic.topicId);
    request.type = @0;
    
    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.refreshCtrl endRefreshing];
            if ([weakself checkDataResponse:responseObject]) {
                [weakself reloadTopic:responseObject.data];
            }
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.refreshCtrl endRefreshing];
            [weakself showError:error];
        });
    }];
}

- (void)refreshTopicMD
{
    COTopicDetailRequest *request = [COTopicDetailRequest request];
    request.topicId = @(_topic.topicId);
    request.type = @1;
    
    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakself checkDataResponse:responseObject]) {
                [weakself reloadTopicMD:responseObject.data];
            }
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself showError:error];
        });
    }];
}

- (void)reloadTopic:(COTopic *)data
{
    if (_topic.contentHeight > 1) {
        data.contentHeight = _topic.contentHeight;
    }
    _topic = data;
    _editBtn.hidden = [self.topic canEdit] ? NO : YES;

    [self.tableView reloadData];
    [self refreshTopicMD];
}

- (void)reloadTopicMD:(COTopic *)data
{
    _topic.mdTitle = data.title;
    _topic.mdContent = data.content;
    _topic.mdLabels = data.labels.mutableCopy;
    
    _editBtn.hidden = ![_topic canEdit];
    [self loadComments];
}

- (void)loadComments
{
    COTopicCommentsRequest *request = [COTopicCommentsRequest request];
    request.topicId = @(_topic.topicId);
    request.page = self.page;
    request.pageSize = 1000;

    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakself checkDataResponse:responseObject]) {
                [weakself reloadData:responseObject.data];
            }
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself showError:error];
        });
    }];
}

- (void)reloadData:(NSArray *)data
{
    @synchronized(self) {
        if (1 == self.page) {
            [self.comments removeAllObjects];
        }
    }
    
    [self.comments addObjectsFromArray:data];
    
    [self.tableView reloadData];
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1 + self.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        TopicContentCell *contentCell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TopicContent forIndexPath:indexPath];
        [contentCell setCurTopic:self.topic md:NO];
        __weak typeof(self) weakself = self;
        contentCell.cellHeightChangedBlock = ^(){
            [weakself.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        };
        contentCell.addLabelBlock = ^() {
            [weakself addtitleBtnClick];
        };
        contentCell.delLabelBlock = ^(NSInteger index) {
            [weakself deltitleBtnClick:index];
        };
        contentCell.loadRequestBlock = ^(NSURLRequest *curRequest) {
            [weakself loadRequest:curRequest];
        };
        contentCell.deleteTopicBlock = ^(COTopic *curTopic) {
            UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"删除此讨论" buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
                if (index == 0) {
                    [weakself deleteTopic:curTopic];
                }
            }];
            [actionSheet showInView:self.view];
        };
        cell = contentCell;
    } else {
        COTopic *comment = _comments[indexPath.row - 1];

        TopicCommentCell *commentCell = [tableView dequeueReusableCellWithIdentifier:comment.htmlMedia.imageItems.count > 0 ? kCellIdentifier_TopicComment_Media: kCellIdentifier_TopicComment forIndexPath:indexPath];
        commentCell.toComment = comment;
        commentCell.contentLabel.delegate = self;
        cell = commentCell;
    }
    return cell;
}

- (void)deleteTopic:(COTopic *)topic
{
    COTopicDeleteRequest *request = [COTopicDeleteRequest request];
    request.topicId = @(topic.topicId);
    
    __weak typeof(self) weakself = self;
    [request deleteWithSuccess:^(CODataResponse *responseObject) {
        if ([weakself checkDataResponse:responseObject]) {
            [weakself.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(NSError *error) {
        [weakself showErrorInHudWithError:error];
    }];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.view endEditing:YES];
    
    if (indexPath.row == 0) {
        return;
    } else {
        COTopic *comment = _comments[indexPath.row - 1];
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

- (void)deleteComment:(COTopic *)comment
{
    COTopicDeleteRequest *request = [COTopicDeleteRequest request];
    request.topicId = @(comment.topicId);
    
    __weak typeof(self) weakself = self;
    [request deleteWithSuccess:^(CODataResponse *responseObject) {
        if ([weakself checkDataResponse:responseObject]) {
            [weakself.comments removeObject:comment];
            weakself.topic.childCount--;
            [weakself.tableView reloadData];
        }
    } failure:^(NSError *error) {
        [weakself showErrorInHudWithError:error];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = 0;
    if (indexPath.row == 0) {
        cellHeight = [TopicContentCell cellHeightWithObj:self.topic md:NO];
    } else {
        cellHeight = [TopicCommentCell cellHeightWithObj:_comments[indexPath.row - 1]];
    }
    return cellHeight;
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
        COTopicCommentAddRequest *request = [COTopicCommentAddRequest request];
        request.projectId = @(_topic.projectId);
        request.topicId = @(_topic.topicId);
        
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

                //TODO : 重新取评论加载评论？还是直接插入一条算了
                weakself.topic.childCount += 1;
                [weakself loadComments];
            }
        } failure:^(NSError *error) {
            [weakself showErrorInHudWithError:error];
        }];
    }
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
    [_inputTextView resignFirstResponder];
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
- (IBAction)backBtnAction:(id)sender
{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)editBtnClick:(UIButton *)sender
{
    // 编辑讨论
    COTopicEditController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COTopicEditController"];
    controller.type = 1;
    controller.topic = _topic;
    __weak typeof(self) weakSelf = self;
    controller.topicChangedBlock = ^(){
        [weakSelf refreshTopic];
    };
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)addtitleBtnClick
{
    [self.view endEditing:YES];
    
    COTopicLabelController *popoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"COTopicLabelController"];
    popoverVC.topic = _topic;
    popoverVC.isSaveChange = TRUE;
    __weak typeof(self) weakSelf = self;
    popoverVC.topicChangedBlock = ^(){
        [weakSelf refreshTopic];
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:popoverVC];
    nav.navigationBarHidden = YES;
    [self popoverController:nav withSize:CGSizeMake(kPopWidthS, kPopHeightS)];
}

- (void)deltitleBtnClick:(NSInteger )index;
{
    [_topic.mdLabels removeObjectAtIndex:index];
    
    __weak typeof(self) weakself = self;
    COProjectTopicLabelChangesRequest *request = [COProjectTopicLabelChangesRequest request];
    request.projectName = _topic.project.name;
    request.topicId = @(_topic.topicId);
    request.projectOwnerName = _topic.project.ownerUserName;
    
    NSMutableArray *tempAry = [NSMutableArray arrayWithCapacity:_topic.mdLabels.count];
    for (COTopicLabel *lbl in _topic.mdLabels) {
        [tempAry addObject:@(lbl.topicLabelId)];
    }
    request.labelIds = [tempAry componentsJoinedByString:@","];
    
    [request postWithSuccess:^(CODataResponse *responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakself checkDataResponse:responseObject]) {
                weakself.topic.labels = [NSMutableArray arrayWithArray:_topic.mdLabels];
                [weakself.tableView reloadData];
            }
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself showError:error];
        });
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
    NSString *fileName = [NSString stringWithFormat:@"%ld|||%@|||%@", (long)self.topic.projectId, @"0", originalFileName];
    
    if ([Coding_FileManager writeUploadDataWithName:fileName andAsset:media.curAsset]) {
        [SVProgressHUD showProgress:0 status:[NSString stringWithFormat:@"正在上传第 %ld 张图片...", (long)index +1]];
        media.state = UIMessageInputView_MediaStateUploading;
        self.uploadingPhotoName = originalFileName;
        Coding_UploadTask *uploadTask =[[Coding_FileManager sharedManager] addUploadTaskWithFileName:fileName projectIsPublic:_topic.project.isPublic];
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
    NSString *diskFileName = [NSString stringWithFormat:@"%ld|||%@|||%@", (long)self.topic.projectId, @"0", self.uploadingPhotoName];
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

#pragma mark loadCellRequest
- (void)loadRequest:(NSURLRequest *)curRequest
{
    NSString *linkStr = curRequest.URL.absoluteString;
    NSLog(@"\n linkStr : %@", linkStr);
    [self analyseLinkStr:linkStr];
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

#pragma mark - pop
- (void)popoverController:(UIViewController *)controller withSize:(CGSize)size
{
    BOOL reset = FALSE;
    if (self.popController) {
        reset = TRUE;
        _popShadowView.backgroundColor = [UIColor clearColor];
        [_popController.view removeFromSuperview];
        [_popController removeFromParentViewController];
        self.popController = nil;
    }
    
    if (self.maskView == nil) {
        self.maskView = [[UIButton alloc] initWithFrame:self.view.bounds];
        _maskView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
        [_maskView addTarget:self action:@selector(dismissBtnAction) forControlEvents:UIControlEventTouchUpInside];
        
        _popShadowView = [[UIView alloc] initWithFrame:CGRectZero];
        _popShadowView.layer.shadowOpacity = 0.5;
        _popShadowView.layer.shadowRadius = 4;
        _popShadowView.layer.cornerRadius = 4;
        _popShadowView.layer.shadowOffset = CGSizeMake(1, 3);
        _popShadowView.layer.shadowColor = [UIColor blackColor].CGColor;
        [_maskView addSubview:_popShadowView];
    }
    
    CGRect frame = CGRectMake((_maskView.frame.size.width - size.width) / 2, (_maskView.frame.size.height - size.height) / 2, size.width, size.height);
    controller.view.frame = frame;
    _popShadowView.frame = frame;
    
    controller.view.layer.cornerRadius = 4;
    controller.view.layer.masksToBounds = TRUE;
    
    if (!reset) {
        _maskView.alpha = 0;
        controller.view.alpha = 0;
    }
    
    [self.view addSubview:_maskView];
    
    self.popController = controller;
    [self addChildViewController:controller];
    [_maskView addSubview:controller.view];
    
    _popShadowView.backgroundColor = [UIColor clearColor];
    
    if (reset) {
        [UIView animateWithDuration:0.2 animations:^{
            controller.view.alpha = 1;
        } completion:^(BOOL finished) {
            _popShadowView.backgroundColor = [UIColor whiteColor];
        }];
    } else {
        [UIView animateWithDuration:0.1 animations:^{
            _maskView.alpha = 1;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                controller.view.alpha = 1;
            } completion:^(BOOL finished) {
                _popShadowView.backgroundColor = [UIColor whiteColor];
            }];
        }];
    }
}

- (void)dismissPopover
{
    [_popController viewWillDisappear:YES];
    _popShadowView.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:0.1 animations:^{
        _popController.view.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            _maskView.alpha = 0;
        } completion:^(BOOL finished) {
            [_popController.view removeFromSuperview];
            [_popController removeFromParentViewController];
            [_maskView removeFromSuperview];
            self.popController = nil;
        }];
    }];
}

- (void)dismissBtnAction
{
    [_popController.view endEditing:YES];
}

#pragma mark TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components
{
    HtmlMediaItem *clickedItem = [components objectForKey:@"value"];
    [self analyseLinkStr:clickedItem.href];
}

@end
