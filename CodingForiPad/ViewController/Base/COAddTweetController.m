//
//  COAddTweetController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/8.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COAddTweetController.h"
#import "CORootViewController.h"
#import "COPlaceHolderTextView.h"
#import "COPhotoScrollView.h"
#import "ZLPhoto.h"
#import "COAtFriendsController.h"
#import "COAddLocationController.h"
#import "COTweetRequest.h"
#import "UIViewController+Utility.h"
#import "COUser.h"
#import "COTweetViewController.h"
#import "TweetSendLocation.h"
#import "CODataRequest+Image.h"

#import "AGEmojiKeyBoardView.h"
#import "NSString+Common.h"

@interface COAddTweetController () <AGEmojiKeyboardViewDelegate, COPhotoScrollViewDelegate>

@property (weak, nonatomic) IBOutlet COPlaceHolderTextView *inputTextView;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;
@property (weak, nonatomic) IBOutlet COPhotoScrollView *photoScrollView;
@property (weak, nonatomic) IBOutlet UIButton *locationBtn;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photoHeightLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentHeightLayout;
@property (weak, nonatomic) IBOutlet UIButton *emojiBtn;

@property (strong, nonatomic) NSMutableString *contentStr;
@property (assign, nonatomic) NSInteger sendOK;

@property (nonatomic, strong) TweetSendLocationResponse *locationData;

@property (strong, nonatomic) AGEmojiKeyboardView *emojiKeyboardView;

@end

@implementation COAddTweetController

+ (UINavigationController *)popSelf
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *popoverVC = [storyboard instantiateViewControllerWithIdentifier:@"addTweetNav"];
    [[CORootViewController currentRoot] popoverController:popoverVC withSize:CGSizeMake(kPopWidth, kPopHeight)];
    return popoverVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_inputTextView setPlaceholder:@"来，冒个泡吧"];
    
    _photoScrollView.photoDelegate = self;
    
    _locationBtn.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    _locationBtn.layer.cornerRadius = 10;
    _locationBtn.layer.masksToBounds = TRUE;
    
    _okBtn.enabled = FALSE;
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
 
    _contentHeightLayout.constant = 48;

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
    
    _contentHeightLayout.constant = 248;
    
    [UIView beginAnimations:@"changeViewFrame" context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    [self.view layoutIfNeeded];
    
    [UIView commitAnimations];
    
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
    _okBtn.enabled = (textView.text.length > 0 || _photoScrollView.imageAry.count > 0) ? TRUE : FALSE;
}

- (void)photoChanged:(NSArray *)imageAry
{
    _okBtn.enabled = (_photoScrollView.imageAry.count > 0 || _inputTextView.text.length > 0) ? TRUE : FALSE;
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
    [[CORootViewController currentRoot] dismissPopover];
}

- (IBAction)okBtnClick:(UIButton *)sender
{
    [self hideKeyboard];
    
    [self showProgressHudWithMessage:@"正在发送冒泡"];
    if (_photoScrollView.imageAry.count > 0) {
        _contentStr = [[NSMutableString alloc] initWithString: _inputTextView.text.length > 0 ? _inputTextView.text : @""];
        self.sendOK = 0;
        for (NSInteger i=0; i < _photoScrollView.imageAry.count; i++) {
            ZLPhotoAssets *imageInfo = _photoScrollView.imageAry[i];
            UIImage *uplaodImg;
            if ([imageInfo isKindOfClass:[ZLPhotoAssets class]]) {
                uplaodImg = imageInfo.originImage;
            } else if([imageInfo isKindOfClass:[UIImage class]]){
                uplaodImg = (UIImage *)imageInfo;
            }
            __weak typeof(self) weakself = self;
            COTweetSendImageRequest *uploadRequest = [COTweetSendImageRequest request];
            [uploadRequest uploadImage:uplaodImg
                          successBlock:^(CODataResponse *responseObject) {
                              if ([weakself checkDataResponse:responseObject]) {
                                  [weakself.contentStr appendString:[NSString stringWithFormat:@" ![图片](%@) ", responseObject.data]];
                                  weakself.sendOK++;
                                  if (weakself.sendOK >= weakself.photoScrollView.imageAry.count) {
                                      [weakself sendTweet:weakself.contentStr];
                                  }
                              }
                          } failureBlock:^(NSError *error) {
                              [weakself showErrorInHudWithError:error];
                          } progerssBlock:^(CGFloat progressValue) {
                              
                          }];
         }
    } else {
        [self sendTweet:_inputTextView.text];
    }
}

- (void)sendTweet:(NSString *)content
{
    __weak typeof(self) weakself = self;
    COTweetSendRequest *request = [COTweetSendRequest request];
    request.content = content;
    if (_locationData) {
        request.location = _locationData.displayLocaiton;
        request.coord = [NSString stringWithFormat:@"%@,%@,%i", _locationData.lat, _locationData.lng, _locationData.isCustomLocaiton];
        request.address = _locationData.address ? _locationData.address : @"";
    }
    [request postWithSuccess:^(CODataResponse *responseObject) {
        if ([weakself checkDataResponse:responseObject]) {
            [weakself showSuccess:@"冒泡发送成功"];
            [[NSNotificationCenter defaultCenter] postNotificationName:COTweetReloadNotification object:nil];
            [[CORootViewController currentRoot] dismissPopover];
        }
    } failure:^(NSError *error) {
        [weakself showErrorInHudWithError:error];
        
    }];
}

- (IBAction)locationBtnAction:(UIButton *)sender
{
    __weak typeof(self) weakSelf = self;
   COAddLocationController *popoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"COAddLocationController"];
    popoverVC.selectedBlock = ^(TweetSendLocationResponse *obj) {
        weakSelf.locationData = obj;
        if (obj) {
            [weakSelf.locationLabel setText:weakSelf.locationData.displayLocaiton];
        } else {
            [weakSelf.locationLabel setText:@"所在位置"];
        }
    };
    [self.navigationController pushViewController:popoverVC animated:YES];
}

- (IBAction)photoBtnAction:(UIButton *)sender
{
    [self hideKeyboard];
    [_photoScrollView setupPhotoPicker];
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

- (IBAction)atBtnAction:(UIButton *)sender
{
    [self hideKeyboard];
    
    __weak typeof(self) weakSelf = self;
    COAtFriendsController *popoverVC = [self.storyboard instantiateViewControllerWithIdentifier:@"COAtFriendsController"];
    popoverVC.type = 1;
    popoverVC.selectUserBlock = ^(COUser *curUser) {
        if (curUser) {
            NSString *appendingStr = [NSString stringWithFormat:@"@%@ ", curUser.name];
            weakSelf.inputTextView.text = [weakSelf.inputTextView.text stringByAppendingString:appendingStr];
            weakSelf.okBtn.enabled = (weakSelf.inputTextView.text.length > 0 || weakSelf.photoScrollView.imageAry.count > 0) ? TRUE : FALSE;

            [weakSelf.inputTextView becomeFirstResponder];
        }
    };
    [self.navigationController pushViewController:popoverVC animated:YES];
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

@end
