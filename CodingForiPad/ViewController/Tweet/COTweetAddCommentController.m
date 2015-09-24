//
//  COTweetAddCommentController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/7/12.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COTweetAddCommentController.h"
#import "CORootViewController.h"
#import "COPlaceHolderTextView.h"
#import "COTweetRequest.h"
#import "COTweet.h"
#import "COSession.h"
#import "UIViewController+Utility.h"
#import "COTweetViewController.h"

#import "AGEmojiKeyBoardView.h"
#import "NSString+Common.h"

@interface COTweetAddCommentController () <AGEmojiKeyboardViewDelegate>

@property (weak, nonatomic) IBOutlet COPlaceHolderTextView *inputTextView;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;
@property (weak, nonatomic) IBOutlet UIButton *emojiBtn;

@property (strong, nonatomic) AGEmojiKeyboardView *emojiKeyboardView;

@end

@implementation COTweetAddCommentController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_inputTextView setPlaceholder:@"说的太好啦！"];
    _inputTextView.type = 1;
    
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
        CGRect frame = CGRectMake((kScreen_Width - kPopWidthS) / 2, (kScreen_Height - kPopHeightS) / 2, kPopWidthS, kPopHeightS);
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
    
    CGRect frame = CGRectMake((kScreen_Width - kPopWidthS) / 2, 64, kPopWidthS, kScreen_Height - height - 64 + 20);
    [[CORootViewController currentRoot] popoverChangeRect:frame withDuration:animationDuration withCurve:animationCurve];
}

- (void)handleKeyboardWillHide:(NSNotification *)paramNotification
{
    NSUInteger animationCurve = 0;
    double animationDuration = 0.0f;
    [COUtility hideKeyboardInfo:paramNotification andCurve:&animationCurve andDuration:&animationDuration];
    
    CGRect frame = CGRectMake((kScreen_Width - kPopWidthS) / 2, (kScreen_Height - kPopHeightS) / 2, kPopWidthS, kPopHeightS);
    [[CORootViewController currentRoot] popoverChangeRect:frame withDuration:animationDuration withCurve:animationCurve];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // 按下return键
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [self sendComment];
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
    [[CORootViewController currentRoot] dismissPopover];
}

- (IBAction)emojiBtnAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        [_inputTextView resignFirstResponder];
        if (!_emojiKeyboardView) {
            self.emojiKeyboardView = [[CORootViewController currentRoot] getEmoji:NO];
            self.emojiKeyboardView.delegate = self;
        }
        CGRect emojiFrame = _emojiKeyboardView.frame;
        emojiFrame.origin.y = kScreen_Height - kKeyboardView_Height;
        CGRect frame = CGRectMake((kScreen_Width - kPopWidthS) / 2, 64, kPopWidthS, kScreen_Height - kKeyboardView_Height - 64 + 20);
        [UIView animateWithDuration:0.25 delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            _emojiKeyboardView.frame = emojiFrame;
        } completion:^(BOOL finished) {
        }];
        [[CORootViewController currentRoot] popoverChangeRect:frame withDuration:0.25 withCurve:UIViewAnimationCurveEaseInOut];
    } else {
        [_inputTextView becomeFirstResponder];
    }
}

- (IBAction)okBtnClick:(UIButton *)sender
{
    [self hideKeyboard];
    [self sendComment];
}

- (void)sendComment
{
    __weak typeof(self) weakself = self;
    if (_inputTextView.text.length > 0) {
        COTweetCommentRequest *request = [COTweetCommentRequest request];
        request.tweetId = @(_tweet.tweetId);
        request.content = _inputTextView.text;
        [request postWithSuccess:^(CODataResponse *responseObject) {
            if ([weakself checkDataResponse:responseObject]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself showSuccess:@"评论发送成功"];
                    COTweetComment *comment = responseObject.data;
                    if (comment && [comment isKindOfClass:[COTweetComment class]]) {
                        comment.owner = [COSession session].user;
                        comment.ownerId = [COSession session].user.userId;
                        if (weakself.tweet.commentList) {
                            [weakself.tweet.commentList insertObject:comment atIndex:0];
                        } else {
                            weakself.tweet.commentList = [NSMutableArray arrayWithObject:comment];
                        }
                        weakself.tweet.comments = weakself.tweet.commentList.count;
                        [weakself.tweet cleanHeight];
                    }
                    [[CORootViewController currentRoot] dismissPopover];
                    [[NSNotificationCenter defaultCenter] postNotificationName:COTweetCommentNotification object:nil];
                });
            }
        } failure:^(NSError *error) {
            [weakself showErrorInHudWithError:error];
        }];
    }
}

+ (COTweetAddCommentController *)show:(COTweet *)tweet
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    COTweetAddCommentController *popoverVC = [storyboard instantiateViewControllerWithIdentifier:@"COTweetAddCommentController"];
    popoverVC.tweet = tweet;
    [[CORootViewController currentRoot] popoverController:popoverVC withSize:CGSizeMake(kPopWidthS, kPopHeightS)];
    return popoverVC;
}

- (void)AtUser:(NSString *)name
{
    NSString *appendingStr = [NSString stringWithFormat:@"@%@ ", name];
    _inputTextView.text = [_inputTextView.text stringByAppendingString:appendingStr];
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
