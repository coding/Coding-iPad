//
//  COMessageViewController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/10.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COMessageViewController.h"
#import "COMessageRequest.h"
#import "COMessageViewCell.h"
#import "UIViewController+Utility.h"
#import "COSession.h"
#import "CODataRequest+Image.h"

#import "COHtmlMedia.h"
#import "NSString+Common.h"
#import "COPlaceHolderTextView.h"

#import "AGEmojiKeyBoardView.h"
#import "UIMessageInputView_Add.h"
#import "ZLPhoto.h"
#import "COTweetRequest.h"
#import "MessageCell.h"
#import "COUserController.h"
#import "CORootViewController.h"
#import "COEmptyView.h"
#import "NSTimer+Common.h"
#import "UIViewController+Link.h"

#ifndef kKeyboardView_Height
#define kKeyboardView_Height 216.0
#endif

@interface COMessageViewController () <UITextViewDelegate, AGEmojiKeyboardViewDelegate, ZLPhotoPickerViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, TTTAttributedLabelDelegate, AGEmojiKeyboardViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet COAttributedLabel *getHLabel;

@property (weak, nonatomic) IBOutlet UIView *toolbarView;
@property (weak, nonatomic) IBOutlet COPlaceHolderTextView *inputTextView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputHLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayout;
@property (weak, nonatomic) IBOutlet UIButton *emojiBtn;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;

@property (nonatomic, strong) NSMutableArray *conversations;
@property (nonatomic, assign) NSInteger convPage;
@property (atomic, assign) BOOL loading;

@property (strong, nonatomic) AGEmojiKeyboardView *emojiKeyboardView;
@property (strong, nonatomic) UIMessageInputView_Add *addKeyboardView;

@property (nonatomic, strong) COConversation *messageToResendOrDelete;
@property (nonatomic, strong) NSNumber *lastId;
@property (strong, nonatomic) NSTimer *pollTimer;

@end

@implementation COMessageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.conversations = [NSMutableArray array];
    self.convPage = 1;
    
    _getHLabel.numberOfLines = 0;
    _getHLabel.font = [UIFont systemFontOfSize:14];
    _getHLabel.backgroundColor = [UIColor clearColor];
    _getHLabel.textInsets = UIEdgeInsetsZero;

    _scrollView.layer.borderWidth = 0.5;
    _scrollView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _scrollView.layer.cornerRadius = 20;
    _scrollView.layer.masksToBounds = YES;
    _scrollView.alwaysBounceVertical = YES;
    
    _inputTextView.delegate = self;
    [_inputTextView setPlaceholder:@"请输入私信内容"];
    _inputTextView.type = 1;
    
    [_tableView registerClass:[MessageCell class] forCellReuseIdentifier:kCellIdentifier_Message];
    [_tableView registerClass:[MessageCell class] forCellReuseIdentifier:kCellIdentifier_MessageMedia];
    
    [self setUpRefresh:self.tableView];
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
    [self hideKeyboard];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopPolling];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    [self startPolling];
}

- (void)hideKeyboard
{
    if ([_inputTextView isFirstResponder]) {
        [_inputTextView resignFirstResponder];
    } else if (_addBtn.selected || _emojiBtn.selected) {
        _addBtn.selected = FALSE;
        _emojiBtn.selected = FALSE;
        CGRect emojiFrame = self.emojiKeyboardView.frame;
        emojiFrame.origin.y = self.view.frame.size.height;
        CGRect addFrame = self.addKeyboardView.frame;
        addFrame.origin.y = self.view.frame.size.height;
        _bottomLayout.constant = 0;
        [UIView animateWithDuration:0.25 delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            self.emojiKeyboardView.frame = emojiFrame;
            self.addKeyboardView.frame = addFrame;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];
    }
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
    
    _bottomLayout.constant = height - 10;
    CGRect emojiFrame = self.emojiKeyboardView.frame;
    emojiFrame.origin.y = self.view.frame.size.height;
    CGRect addFrame = self.addKeyboardView.frame;
    addFrame.origin.y = self.view.frame.size.height;
    _emojiBtn.selected = FALSE;
    _addBtn.selected = FALSE;
    
    [UIView beginAnimations:@"changeViewFrame" context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    self.emojiKeyboardView.frame = emojiFrame;
    self.addKeyboardView.frame = addFrame;
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

- (void)showMessage:(COConversation *)conversation
{
    if (self.navigationController.viewControllers.count == 1) {
        self.backBtn.hidden = YES;
    }
    else {
        self.backBtn.hidden = NO;
    }
    self.conversation = conversation;
    //[self.conversations removeAllObjects];
    //self.convPage = 1;
    self.lastId = @(99999999);
    [self.conversations removeAllObjects];
    [self loadConversation];
}

- (void)chatToGlobalKey:(NSString *)globalKey
{
    if (self.navigationController.viewControllers.count == 1) {
        self.backBtn.hidden = YES;
    }
    else {
        self.backBtn.hidden = NO;
    }
    self.globalKey = globalKey;
    self.lastId = @(99999999);
    [self.conversations removeAllObjects];
    [self loadConversation];
}

#pragma mark -
- (void)startPolling{
    [self stopPolling];
    __weak typeof(self) weakSelf = self;
    _pollTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 block:^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf doPoll];
    } repeats:YES];
}

- (void)stopPolling{
    [_pollTimer invalidate];
    _pollTimer = nil;
}

- (void)doPoll{
    if (self.conversations.count == 0) {
        return;
    }
    
    [self loadLastConversation];
//    if (!_myPriMsgs ||  _myPriMsgs.isLoading) {
//        return;
//    }
//    if (_myPriMsgs.list.count <= 0) {
//        [self refreshLoadMore:NO];
//        return;
//    }
//    __weak typeof(self) weakSelf = self;
//    [[Coding_NetAPIManager sharedManager] request_Fresh_PrivateMessages:_myPriMsgs andBlock:^(id data, NSError *error) {
//        if (data && [(NSArray *)data count] > 0) {
//            [weakSelf.myPriMsgs configWithPollArray:data];
//            [weakSelf dataChangedWithError:NO scrollToBottom:YES animated:YES];
//        }
//    }];
}

#pragma mark -
- (void)refresh
{
    COConversation *c = self.conversations.firstObject;
    if (c) {
        self.lastId = @(c.conversationId);
        [self loadConversation];
    }
}

- (void)loadLastConversation
{
    if (self.loading) {
        return;
    }
    COConversationRequest *reqeust = [COConversationRequest request];
    
    if (self.globalKey) {
        reqeust.globalKey = self.globalKey;
    }
    else {
        if (_conversation.sender.userId != [COSession session].user.userId) {
            reqeust.globalKey = _conversation.sender.globalKey;
        } else {
            reqeust.globalKey = _conversation.friendUser.globalKey;
        }
    }
    
    reqeust.type = @"last";
    COConversation *c = self.conversations.lastObject;
    if (c){
        reqeust.lastId = @(c.conversationId);
    }
    
    __weak typeof(self) weakself = self;
    self.loading = YES;
    [reqeust getWithSuccess:^(CODataResponse *responseObject) {
        if (responseObject.error == nil
            && responseObject.code == 0) {
            // TODO:  show data
            [weakself insertConversations:responseObject.data];
        }
    } failure:^(NSError *error) {
        weakself.loading = NO;
        [weakself showError:error];
    }];
}

- (void)insertConversations:(NSArray *)data
{
    @synchronized(self) {
        NSMutableArray *result = [NSMutableArray array];
        NSEnumerator *enumerator = [data reverseObjectEnumerator];
        for (id one in enumerator) {
            [result addObject:one];
        }
        [self.conversations addObjectsFromArray:result];
    }
    
    [_tableView reloadData];
    if (self.conversations.count > 0 && data.count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.conversations.count - 1 inSection:0];
        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
    self.loading = NO;
}

- (void)loadConversation
{
    if (self.loading) {
        return;
    }
    COConversationRequest *reqeust = [COConversationRequest request];
    
    if (self.globalKey) {
        reqeust.globalKey = self.globalKey;
    }
    else {
        if (_conversation.sender.userId != [COSession session].user.userId) {
            reqeust.globalKey = _conversation.sender.globalKey;
        } else {
            reqeust.globalKey = _conversation.friendUser.globalKey;
        }
    }
    
    reqeust.type = @"prev";
    reqeust.pageSize = @(20);
    reqeust.lastId = self.lastId;
    
    self.loading = YES;
    __weak typeof(self) weakself = self;
    [reqeust getWithSuccess:^(CODataResponse *responseObject) {
        [weakself.refreshCtrl endRefreshing];
        if (responseObject.error == nil
            && responseObject.code == 0) {
            // TODO:  show data
            [weakself reloadConversation:responseObject.data];
        }
    } failure:^(NSError *error) {
        [weakself.tableView.pullToRefreshView stopAnimating];
        weakself.loading = NO;
        [weakself showError:error];
    }];
}

- (void)reloadConversation:(NSArray *)data
{
    BOOL needScrool = NO;
    if (self.conversations.count == 0) {
        needScrool = YES;
    }
    @synchronized(self) {
        NSMutableArray *result = [NSMutableArray array];
        NSEnumerator *enumerator = [data reverseObjectEnumerator];
        for (id one in enumerator) {
            [result addObject:one];
        }
        NSMutableArray *all = [NSMutableArray arrayWithArray:result];
        [all addObjectsFromArray:self.conversations];
        self.conversations = all;
    }
    
    [_tableView reloadData];
    if (self.conversations.count > 0 && needScrool) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.conversations.count - 1 inSection:0];
        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
    
    if (self.conversations.count < 20) {
        _tableView.showsPullToRefresh = NO;
    }
    else {
        _tableView.showsPullToRefresh = YES;
    }
    
    if (self.conversations.count == 0) {
        [COEmptyView removeFormView:self.view];
        COEmptyView *empty = [COEmptyView emptyViewWithImage:[UIImage imageNamed:@"blankpage_image_Hi"] andTips:
                              @"打个招呼吧~"];
        [empty showInView:self.view padding:UIEdgeInsetsMake(44.0, 0.0, 0.0, 0.0)];
        [self.view bringSubviewToFront:_toolbarView];
    }
    else {
        [COEmptyView removeFormView:self.view];
    }
    self.loading = NO;
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.conversations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageCell *cell;
    COConversation *curMsg = _conversations[indexPath.row];
    if (curMsg.hasMedia) {
        cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_MessageMedia forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_Message forIndexPath:indexPath];
    }
    cell.contentLabel.delegate = self;
    COConversation *preMsg = nil;
    if (indexPath.row > 0) {
        preMsg = _conversations[indexPath.row - 1];
    }
    [cell setCurPriMsg:curMsg andPrePriMsg:preMsg];
    cell.tapUserIconBlock = ^(COUser *sender) {
        // 去个人主页
        COUserController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COUserController"];
        [self rootPushViewController:controller animated:YES];
        [controller showUserWithGlobalKey:sender.globalKey];
    };
    __weak typeof(self) weakself = self;
    cell.resendMessageBlock = ^(COConversation *curMessage){
        weakself.messageToResendOrDelete = curMessage;
        [weakself hideKeyboard];
        // 重新发送
//        UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"重新发送" buttonTitles:@[@"发送"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
//            if (index == 0 && _self.messageToResendOrDelete) {
//                [_self sendPrivateMessageWithMsg:_messageToResendOrDelete];
//                
//            }
//        }];
//        [actionSheet showInView:self.view];
    };
    
    cell.refreshMessageMediaCCellBlock = ^(CGFloat diff){
        if (ABS(diff) > 1) {
            [weakself.tableView reloadData];
        }
    };
//    NSMutableArray *menuItemArray = [[NSMutableArray alloc] init];
//    BOOL hasTaxtToCopy = (curMsg.content && ![curMsg.content isEmpty]);
//    BOOL canDelete = (curMsg.sendStatus != PrivateMessageStatusSending);
//    if (curMsg.hasMedia) {// 有图片
//        if (hasTaxtToCopy) {
//            [menuItemArray addObject:@"拷贝文字"];
//        }
//    } else {
//        [menuItemArray addObject:@"拷贝"];
//    }
//    if (canDelete) {
//        [menuItemArray addObject:@"删除"];
//    }
//    if (curMsg.sendStatus == PrivateMessageStatusSendSucess) {
//        [menuItemArray addObject:@"转发"];
//    }
//    
//    [cell.bgImgView addLongPressMenu:menuItemArray clickBlock:^(NSInteger index, NSString *title) {
//        if ([title hasPrefix:@"拷贝"]) {
//            [[UIPasteboard generalPasteboard] setString:curMsg.content];
//        } else if ([title isEqualToString:@"删除"]) {
//            [weakself showAlertToDeleteMessage:curMsg];
//        } else if ([title isEqualToString:@"转发"]) {
//            [weakself willTranspondMessage:curMsg];
//        }
//    }];
    
//    if (conversation.sender.userId == [COSession session].user.userId) {
//        cell = [tableView dequeueReusableCellWithIdentifier:@"COMessageViewCellRight"];
//    } else {
//        cell = [tableView dequeueReusableCellWithIdentifier:@"COMessageViewCellLeft"];
//    }
//    [cell assignWithConversation:conversation];

    return cell;
}

- (void)showAlertToDeleteMessage:(COConversation *)toDeleteMsg
{
    self.messageToResendOrDelete = toDeleteMsg;
    [self hideKeyboard];
    // 删除信息
//    UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetCustomWithTitle:@"删除后将不会出现在你的私信记录中" buttonTitles:nil destructiveTitle:@"确认删除" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
//        ESStrongSelf
//        if (index == 0 && _self.messageToResendOrDelete) {
//            [_self deletePrivateMessageWithMsg:_messageToResendOrDelete];
//        }
//    }];
//    [actionSheet showInView:self.view];
}

- (void)willTranspondMessage:(COConversation *)message
{
    // 转发信息
//    __weak typeof(self) weakSelf = self;
//    [UsersViewController showTranspondMessage:message withBlock:^(PrivateMessage *curMessage) {
//        NSLog(@"%@, %@", curMessage.friend.name, curMessage.content);
//        [weakSelf doTranspondMessage:curMessage];
//    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    COConversation *conversation = _conversations[indexPath.row];
    COConversation *preMessage = nil;
    if (indexPath.row > 0) {
        preMessage = _conversations[indexPath.row - 1];
    }
    return [MessageCell cellHeightWithObj:conversation preObj:preMessage];
    
//    COConversation *conversation = _conversations[indexPath.row];
//    _getHLabel.text = conversation.content;
//    
//    CGFloat add = 0;
//    for (HtmlMediaItem *item in conversation.htmlMedia.mediaItems) {
//        if (item.displayStr.length > 0
//            && !(item.type == HtmlMediaItemType_Code || item.type == HtmlMediaItemType_EmotionEmoji)) {
//            [_getHLabel addLinkToTransitInformation:[NSDictionary dictionaryWithObject:item forKey:@"value"] withRange:item.range];
//                add += 5;
//        }
//    }
//    
//    [_getHLabel setNeedsLayout];
//    [_getHLabel layoutIfNeeded];
//    CGFloat h = _getHLabel.frame.size.height + 20 + 18 + 15 + 15 + add;
//    if (h > 250) {
//        h += 20;
//    }
//    return h;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self hideKeyboard];
}

#pragma mark TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components{
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

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // 按下return键
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        // 发送私信
        [self sendText];
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
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self hideKeyboard];
}

#pragma mark - action
- (IBAction)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)emotionBtnAction:(UIButton *)sender
{
    _addBtn.selected = FALSE;
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        [_inputTextView resignFirstResponder];

        CGRect emojiFrame = self.emojiKeyboardView.frame;
        emojiFrame.origin.y = self.view.frame.size.height - kKeyboardView_Height;
        CGRect addFrame = self.addKeyboardView.frame;
        addFrame.origin.y = self.view.frame.size.height;
        _bottomLayout.constant = kKeyboardView_Height;
        [UIView animateWithDuration:0.25 delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            self.emojiKeyboardView.frame = emojiFrame;
            self.addKeyboardView.frame = addFrame;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];
    } else {
        [_inputTextView becomeFirstResponder];
    }
}

- (IBAction)addBtnAction:(UIButton *)sender
{
    _emojiBtn.selected = FALSE;
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        [_inputTextView resignFirstResponder];

        CGRect emojiFrame = self.emojiKeyboardView.frame;
        emojiFrame.origin.y = self.view.frame.size.height;
        CGRect addFrame = self.addKeyboardView.frame;
        addFrame.origin.y = self.view.frame.size.height - kKeyboardView_Height;
        _bottomLayout.constant = kKeyboardView_Height;
        [UIView animateWithDuration:0.25 delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            self.emojiKeyboardView.frame = emojiFrame;
            self.addKeyboardView.frame = addFrame;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];
    } else {
        [_inputTextView becomeFirstResponder];
    }
}

- (void)addIndexClicked:(NSInteger)index
{
    switch (index) {
        case 0:
        {// 相册
            ZLPhotoPickerViewController *pickerVc = [[ZLPhotoPickerViewController alloc] init];
            pickerVc.topShowPhotoPicker = NO;
            pickerVc.minCount = 6;
            pickerVc.status = PickerViewShowStatusCameraRoll;
            pickerVc.delegate = self;
            [pickerVc show];
        }
            break;
        case 1:
        {// 拍照
            UIImagePickerController *ctrl = [[UIImagePickerController alloc] init];
            ctrl.delegate = self;
            ctrl.sourceType = UIImagePickerControllerSourceTypeCamera;
            [[CORootViewController currentRoot] presentViewController:ctrl animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

#pragma mark -
- (void)sendText
{
    NSMutableString *sendStr = [NSMutableString stringWithString:self.inputTextView.text];
    if (!sendStr || [sendStr isEmpty]) {
        [self showErrorMessageInHud:@"请输入内容"];
        return;
    }
    
    [self postMessage:sendStr withExtra:@""];
}

- (void)postMessage:(NSString *)message withExtra:(NSString *)extra
{
    COMessageSendRequest *request = [COMessageSendRequest request];
    request.content = [message aliasedString];
    request.extra = extra;
    if (self.globalKey) {
        request.receiverGlobalKey = self.globalKey;
    } else {
        if (_conversation.sender.userId != [COSession session].user.userId) {
            request.receiverGlobalKey = _conversation.sender.globalKey;
        } else {
            request.receiverGlobalKey = _conversation.friendUser.globalKey;
        }
    }
    
    __weak typeof(self) weakself = self;
    [request postWithSuccess:^(CODataResponse *responseObject) {
        if ([weakself checkDataResponse:responseObject]) {
            [weakself.inputTextView setText:@""];
            weakself.inputHLayout.constant = kInputTextHeightMin;
  
            if ([weakself.conversations count] > 0) {
                [weakself loadLastConversation];
            }
            else {
                [weakself loadConversation];
            }
        }
    } failure:^(NSError *error) {
        [weakself showErrorInHudWithError:error];
    }];
}

- (void)sendBigEmotion:(NSString *)emotion_monkey
{
    [self postMessage:emotion_monkey withExtra:@""];
}

- (void)sendImage:(id)image
{
    UIImage *uplaodImg;
    if ([image isKindOfClass:[ZLPhotoAssets class]]) {
        uplaodImg = ((ZLPhotoAssets *)image).originImage;
    } else if([image isKindOfClass:[UIImage class]]){
        uplaodImg = (UIImage *)image;
    }
    __weak typeof(self) weakself = self;
    COTweetSendImageRequest *uploadRequest = [COTweetSendImageRequest request];
    [uploadRequest uploadImage:uplaodImg
                  successBlock:^(CODataResponse *responseObject) {
                      if ([weakself checkDataResponse:responseObject]) {
                          // 上传成功后，发送私信
                          [self postMessage:@"" withExtra:responseObject.data];
                      }
                  } failureBlock:^(NSError *error) {
                      [weakself showErrorInHudWithError:error];
                  } progerssBlock:^(CGFloat progressValue) {
                      
                  }];
}

#pragma mark AGEmojiKeyboardView
- (void)emojiKeyBoardView:(AGEmojiKeyboardView *)emojiKeyBoardView didUseEmoji:(NSString *)emoji
{
    NSString *emotion_monkey = [emoji emotionMonkeyName];
    if (emotion_monkey) {
        emotion_monkey = [NSString stringWithFormat:@" :%@: ", emotion_monkey];
        [self sendBigEmotion:emotion_monkey];
    } else {
        [self.inputTextView insertText:emoji];
    }
}

- (void)emojiKeyBoardViewDidPressBackSpace:(AGEmojiKeyboardView *)emojiKeyBoardView
{
    [self.inputTextView deleteBackward];
}

- (void)emojiKeyBoardViewDidPressSendButton:(AGEmojiKeyboardView *)emojiKeyBoardView
{
    [self sendText];
}

#pragma mark - ZLPhotoPickerViewControllerDelegate
- (void)pickerViewControllerDoneAsstes:(NSArray *)assets
{
    for (id image in assets) {
        [self sendImage:image];
    }
}

- (void)pickerCollectionViewSelectCamera:(ZLPhotoPickerViewController *)pickerVc
{
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // 处理
        UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        [self sendImage:originalImage];
        
        // 保存原图片到相册中
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            SEL selectorToCall = @selector(imageWasSavedSuccessfully:didFinishSavingWithError:contextInfo:);
            UIImageWriteToSavedPhotosAlbum(originalImage, self, selectorToCall, NULL);
        }
        [picker dismissViewControllerAnimated:YES completion:nil];
    } else {
        NSLog(@"请在真机使用!");
    }
}

#pragma mark -addkeyboard
- (UIMessageInputView_Add *)addKeyboardView
{
    if (_addKeyboardView == nil) {
        _addKeyboardView = [[UIMessageInputView_Add alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, kKeyboardView_Height)];
        [self.view addSubview:_addKeyboardView];
        __weak typeof(self) weakself = self;
        _addKeyboardView.addIndexBlock = ^(NSInteger index) {
            [weakself addIndexClicked:index];
        };
    }
    return _addKeyboardView;
}

#pragma mark -emoji
- (AGEmojiKeyboardView *)emojiKeyboardView
{
    if (_emojiKeyboardView == nil) {
        _emojiKeyboardView = [[AGEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, kKeyboardView_Height) dataSource:self showBigEmotion:YES];
        [self.view addSubview:_emojiKeyboardView];
        _emojiKeyboardView.delegate = self;
    }
    return _emojiKeyboardView;
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category
{
    UIImage *img;
    if (category == AGEmojiKeyboardViewCategoryImageEmoji) {
        img = [UIImage imageNamed:@"keyboard_emotion_emoji"];
    }else if (category == AGEmojiKeyboardViewCategoryImageMonkey){
        img = [UIImage imageNamed:@"keyboard_emotion_monkey"];
    }
    return img;
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForNonSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category
{
    UIImage *img;
    if (category == AGEmojiKeyboardViewCategoryImageEmoji) {
        img = [UIImage imageNamed:@"keyboard_emotion_emoji"];
    }else if (category == AGEmojiKeyboardViewCategoryImageMonkey){
        img = [UIImage imageNamed:@"keyboard_emotion_monkey"];
    }
    return img;
}

- (UIImage *)backSpaceButtonImageForEmojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView
{
    UIImage *img = [UIImage imageNamed:@"keyboard_emotion_delete"];
    return img;
}

#pragma mark - save image

- (void) imageWasSavedSuccessfully:(UIImage *)paramImage didFinishSavingWithError:(NSError *)paramError contextInfo:(void *)paramContextInfo{
    if (paramError == nil){
        [self showSuccess:@"成功保存到相册"];
    } else {
        [self showErrorWithStatus:@"保存失败"];
    }
}

@end
