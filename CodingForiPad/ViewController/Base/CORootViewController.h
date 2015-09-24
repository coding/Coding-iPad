//
//  CORootViewController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/8.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kKeyboardView_Height 216.0

@class AGEmojiKeyboardView;
@class UIMessageInputView_Add;
@class COMesageController;
@class CORedDotView;


@interface CORootViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIButton *userBtn;
@property (weak, nonatomic) IBOutlet UIView *container;
@property (weak, nonatomic) IBOutlet UIButton *projectBtn;
@property (weak, nonatomic) IBOutlet UIButton *taskBtn;
@property (weak, nonatomic) IBOutlet UIButton *msgBtn;
@property (weak, nonatomic) IBOutlet UIButton *settingBtn;
@property (weak, nonatomic) IBOutlet UIButton *tweetBtn;
@property (weak, nonatomic) IBOutlet UIView *projectDotView;
@property (weak, nonatomic) IBOutlet CORedDotView *messageDotView;

@property (nonatomic, strong) UIViewController *selectedController;
@property (nonatomic, strong) COMesageController *msgController;

+ (instancetype)currentRoot;

- (void)popoverController:(UIViewController *)controller withSize:(CGSize)size;
- (void)dismissPopover;
- (void)popoverChangeSize:(CGSize)size;
- (void)popoverChangeRect:(CGRect)rect withDuration:(NSTimeInterval)duration withCurve:(UIViewAnimationCurve)curve;
- (void)chatToGlobalKey:(NSString *)globalKey;

- (void)changeBackground:(UIImage *)image full:(BOOL)full;

- (AGEmojiKeyboardView *)getEmoji:(BOOL)emojiBig;
- (void)removeEmoji;
- (UIMessageInputView_Add *)getAddKeyboard;
- (void)removeAddKeyboard;

@end

@protocol CORootBackgroudProtocol <NSObject>

- (UIImage *)imageForBackgroud;

@end
