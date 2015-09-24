//
//  COAddMsgController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/8.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COAddMsgController.h"
#import "CORootViewController.h"
#import "COUser.h"
#import "COPlaceHolderTextView.h"
#import "COMessageRequest.h"
#import "COTweetRequest.h"
#import "ZLPhoto.h"
#import "UIViewController+Utility.h"
#import "CODataRequest+Image.h"

#import "AGEmojiKeyBoardView.h"
#import "NSString+Common.h"

@interface COAddMsgController () <AGEmojiKeyboardViewDelegate, ZLPhotoPickerViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet COPlaceHolderTextView *inputTextView;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;
@property (weak, nonatomic) IBOutlet UIButton *emojiBtn;
@property (weak, nonatomic) IBOutlet UIButton *cameraBtn;
@property (weak, nonatomic) IBOutlet UIButton *photoBtn;
@property (weak, nonatomic) IBOutlet UIButton *returnBtn;

@property (strong, nonatomic) AGEmojiKeyboardView *emojiKeyboardView;

@end

@implementation COAddMsgController

+ (UINavigationController *)popSelf
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *popoverVC = [storyboard instantiateViewControllerWithIdentifier:@"addMessageNav"];
    [[CORootViewController currentRoot] popoverController:popoverVC withSize:CGSizeMake(kPopWidth, kPopHeight)];
    return popoverVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_inputTextView setPlaceholder:@"打个招呼吧～"];
    _nameLabel.text = _user.name;
    _okBtn.enabled = FALSE;
    [_returnBtn setTitle:_type == 0 ? @"返回" : @"取消" forState:UIControlStateNormal];
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[CORootViewController currentRoot] removeEmoji];
    self.emojiKeyboardView = nil;
}

- (void)hideKeyboard
{
    if ([_inputTextView isFirstResponder]) {
        [_inputTextView resignFirstResponder];
    } else if (_emojiBtn.selected) {
        _emojiBtn.selected = FALSE;
        CGRect emojiFrame = _emojiKeyboardView.frame;
        emojiFrame.origin.y = kScreen_Height;
        [UIView animateWithDuration:0.25 delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            _emojiKeyboardView.frame = emojiFrame;
        } completion:^(BOOL finished) {
        }];
        CGRect frame = CGRectMake((kScreen_Width - kPopWidth) / 2, (kScreen_Height - kPopHeight) / 2, kPopWidth, kPopHeight);
        [[CORootViewController currentRoot] popoverChangeRect:frame withDuration:0.25 withCurve:UIViewAnimationCurveEaseInOut];
    }
}

- (void)handleKeyboardWillShow:(NSNotification *)paramNotification
{
    NSUInteger animationCurve = 0;
    double animationDuration = 0.0f;
    CGFloat height = [COUtility getKeyboardHeight:paramNotification andCurve:&animationCurve andDuration:&animationDuration];
    
    CGRect emojiFrame = _emojiKeyboardView.frame;
    emojiFrame.origin.y = kScreen_Height;
    _emojiBtn.selected = FALSE;
    
    [UIView beginAnimations:@"changeViewFrame" context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    _emojiKeyboardView.frame = emojiFrame;
    [self.view layoutIfNeeded];
    
    [UIView commitAnimations];
    
    CGRect frame = CGRectMake((kScreen_Width - kPopWidth) / 2, 64, kPopWidth, kScreen_Height - height - 64 + 20);
    [[CORootViewController currentRoot] popoverChangeRect:frame withDuration:animationDuration withCurve:animationCurve];
}

- (void)handleKeyboardWillHide:(NSNotification *)paramNotification
{
    NSUInteger animationCurve = 0;
    double animationDuration = 0.0f;
    [COUtility hideKeyboardInfo:paramNotification andCurve:&animationCurve andDuration:&animationDuration];
    
    CGRect frame = CGRectMake((kScreen_Width - kPopWidth) / 2, (kScreen_Height - kPopHeight) / 2, kPopWidth, kPopHeight);
    [[CORootViewController currentRoot] popoverChangeRect:frame withDuration:animationDuration withCurve:animationCurve];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // 按下return键
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    _okBtn.enabled = textView.text.length > 0 ? TRUE : FALSE;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self hideKeyboard];
}

#pragma mark - action
- (IBAction)returnBtnAction:(UIButton *)sender
{
    [self hideKeyboard];
    
    if (_type == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [[CORootViewController currentRoot] dismissPopover];
    }
}

- (IBAction)okBtnClick:(UIButton *)sender
{
    [self hideKeyboard];
    
    // 发送私信
    [self sendText];
}

- (IBAction)photoBtnAction:(UIButton *)sender
{
    [self hideKeyboard];
    
    ZLPhotoPickerViewController *pickerVc = [[ZLPhotoPickerViewController alloc] init];
    pickerVc.topShowPhotoPicker = NO;
    pickerVc.minCount = 1;
    pickerVc.status = PickerViewShowStatusCameraRoll;
    pickerVc.delegate = self;
    [pickerVc show];
}

- (IBAction)cameraBtnAction:(UIButton *)sender
{
    [self hideKeyboard];
    
    UIImagePickerController *ctrl = [[UIImagePickerController alloc] init];
    ctrl.delegate = self;
    ctrl.sourceType = UIImagePickerControllerSourceTypeCamera;
    [[CORootViewController currentRoot] presentViewController:ctrl animated:YES completion:nil];
}

- (IBAction)emotionBtnAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        [_inputTextView resignFirstResponder];
        if (!_emojiKeyboardView) {
            self.emojiKeyboardView = [[CORootViewController currentRoot] getEmoji:YES];
            self.emojiKeyboardView.delegate = self;
        }
        CGRect emojiFrame = _emojiKeyboardView.frame;
        emojiFrame.origin.y = kScreen_Height - kKeyboardView_Height;
        CGRect frame = CGRectMake((kScreen_Width - kPopWidth) / 2, 64, kPopWidth, kScreen_Height - kKeyboardView_Height - 64 + 20);
        [UIView animateWithDuration:0.25 delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            _emojiKeyboardView.frame = emojiFrame;
        } completion:^(BOOL finished) {
        }];
        [[CORootViewController currentRoot] popoverChangeRect:frame withDuration:0.25 withCurve:UIViewAnimationCurveEaseInOut];
    } else {
        [_inputTextView becomeFirstResponder];
    }
}

#pragma mark AGEmojiKeyboardView
- (void)emojiKeyBoardView:(AGEmojiKeyboardView *)emojiKeyBoardView didUseEmoji:(NSString *)emoji
{
    NSString *emotion_monkey = [emoji emotionMonkeyName];
    if (emotion_monkey) {
        emotion_monkey = [NSString stringWithFormat:@" :%@: ", emotion_monkey];
        [self.inputTextView insertText:emotion_monkey];
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
    if (_okBtn.enabled) {
        [self okBtnClick:_okBtn];
    }
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
            UIImageWriteToSavedPhotosAlbum(originalImage, self, nil, NULL);
        }
        [picker dismissViewControllerAnimated:YES completion:nil];
    } else {
        NSLog(@"请在真机使用!");
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
    request.receiverGlobalKey = self.user.globalKey;
    
    [self showProgressHudWithMessage:@"正在发送私信"];
    __weak typeof(self) weakself = self;
    [request postWithSuccess:^(CODataResponse *responseObject) {
        if ([weakself checkDataResponse:responseObject]) {
            [weakself showSuccess:@"发送私信成功"];
            [weakself.inputTextView setText:@""];
            // TODO:如果正在此人的私信对话页面，刷新之
            //[weakself loadConversation];
            [[CORootViewController currentRoot] dismissPopover];
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
    
    [self showProgressHudWithMessage:@"正在上传私信图片"];
    __weak typeof(self) weakself = self;
    COTweetSendImageRequest *uploadRequest = [COTweetSendImageRequest request];
    [uploadRequest uploadImage:uplaodImg
                  successBlock:^(CODataResponse *responseObject) {
                      if ([weakself checkDataResponse:responseObject]) {
                          // 上传成功后，发送私信
                          [weakself showSuccess:@"上传成功"];
                          [self postMessage:@"" withExtra:responseObject.data];
                      }
                  } failureBlock:^(NSError *error) {
                      [weakself showErrorInHudWithError:error];
                  } progerssBlock:^(CGFloat progressValue) {
                      
                  }];
}

@end
