//
//  CORootViewController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/8.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "CORootViewController.h"
#import "UIButton+WebCache.h"
#import "COSession.h"
#import "COContainerSegue.h"
#import "COMenuController.h"
#import "COUtility.h"
#import <KVOController/FBKVOController.h>
#import "AGEmojiKeyBoardView.h"
#import "UIMessageInputView_Add.h"
#import "COAddTweetController.h"
#import "COTweetAddCommentController.h"
#import "COMesageController.h"
#import "COTweetViewController.h"
#import "COUserController.h"
#import "COUnReadCountManager.h"
#import "CORedDotView.h"
#import "COActiveTipsViewController.h"

static dispatch_once_t onceToken;

static CORootViewController *rootController = nil;

@interface CORootViewController () <AGEmojiKeyboardViewDataSource>

@property (nonatomic, strong) NSMutableDictionary *controller;

@property (nonatomic, strong) UIViewController *popController;
@property (nonatomic, strong) UIButton *maskView;
@property (nonatomic, strong) UIView *popShadowView;

@property (strong, nonatomic) AGEmojiKeyboardView *emojiKeyboardView;
@property (strong, nonatomic) UIMessageInputView_Add *addKeyboardView;
@property (assign, nonatomic) BOOL emojiBig;

@end

@implementation CORootViewController

+ (instancetype)currentRoot
{
    return rootController;
}

+ (void)clear
{
    onceToken = 0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    rootController = self;
    self.container.layer.cornerRadius = 4.0;
    self.container.layer.masksToBounds = YES;
    self.container.backgroundColor = [UIColor clearColor];
    
    self.projectDotView.layer.cornerRadius = 4.0;
    self.projectDotView.layer.masksToBounds = YES;
    
    self.bgImageView.contentMode = UIViewContentModeLeft;
    
    self.controller = [NSMutableDictionary dictionary];
    
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_logo"]];
    self.navigationItem.titleView = logo;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_topbar_add"] style:UIBarButtonItemStylePlain target:self action:@selector(rightBtnAction:)];
    
    self.userBtn.layer.masksToBounds = YES;
    self.userBtn.layer.cornerRadius = 25.0;
    
    [[COSession session] updateUserInfo];
    
    [self.KVOController observe:[COSession session] keyPath:@"user" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        NSString *url = [COSession session].user.avatar;
        [self.userBtn sd_setImageWithURL:[COUtility urlForImage:url] forState:UIControlStateNormal];
    }];
    
    [self.KVOController observe:[COSession session] keyPath:@"userStatus" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        if ([[COSession session] userStatus] == COSessionUserStatusLogout) {
            onceToken = 0;
        }
    }];
    
    [self.KVOController observe:[COUnReadCountManager manager] keyPath:@"messageCount" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        [self updateMessageCount];
    }];
    
    [self.KVOController observe:[COUnReadCountManager manager] keyPath:@"notificationCount" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        [self updateMessageCount];
    }];
    
    [self.KVOController observe:[COUnReadCountManager manager] keyPath:@"projectCount" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        [self updateProjectCount];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoNotification:) name:COTweetUserInfoNotification object:nil];
    
    [[COUnReadCountManager manager] updateCount];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)updateProjectCount
{
    _projectDotView.hidden = ([COUnReadCountManager manager].projectCount == 0) ? YES : NO;
}

- (void)updateMessageCount
{
    [_messageDotView updateCount:[COUnReadCountManager manager].messageCount + [COUnReadCountManager manager].notificationCount];
}

- (void)userInfoNotification:(NSNotification *)n
{
    COUser *user = n.object;
    COUserController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COUserController"];
    controller.user = user;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    dispatch_once(&onceToken, ^{
        [self performSegueWithIdentifier:@"project" sender:self.projectBtn];
    });
    
    if ([COSession session].userNeedActive) {
        [[COSession session] setUserNeedActive:NO];
        COActiveTipsViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COActiveTipsViewController"];
        [self popoverController:controller withSize:CGSizeMake(400.0, 200.0)];
    }
}

- (void)changeBackground:(UIImage *)image full:(BOOL)full
{
    self.bgImageView.image = image;
}

- (void)changeBackground:(id)controller
{
    if ([controller conformsToProtocol:@protocol(CORootBackgroudProtocol)]) {
        self.bgImageView.image = [controller imageForBackgroud];
    }
    else {
        if ([controller isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = controller;
            if ([nav.viewControllers.firstObject conformsToProtocol:@protocol(CORootBackgroudProtocol)]) {
                self.bgImageView.image = [nav.viewControllers.firstObject imageForBackgroud];
            }
        }
    }
}

- (void)chageBgForIdentifier:(NSString *)identifier
{
    if ([identifier isEqualToString:@"project"]) {
        // 项目
        self.bgImageView.image = [UIImage imageNamed:@"background_project"];
    }
    else if ([identifier isEqualToString:@"task"]) {
        self.bgImageView.image = [UIImage imageNamed:@"background_tast"];
    }
    else if ([identifier isEqualToString:@"tweet"]) {
        self.bgImageView.image = [UIImage imageNamed:@"background_bubble"];
    }
    else if ([identifier isEqualToString:@"message"]) {
        self.bgImageView.image = [UIImage imageNamed:@"background_message"];
    }
    else if ([identifier isEqualToString:@"setting"]) {
        self.bgImageView.image = [UIImage imageNamed:@"background_setting"];
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if (_controller[identifier]) {
        UIButton *btn = nil;
        if ([sender isKindOfClass:[UIButton class]]) {
            btn = sender;
        }
        [self unSelectBtn:btn];
        if (btn && !btn.selected) {
            btn.selected = YES;
            if (btn != _userBtn) {
                for (NSLayoutConstraint *con in btn.superview.constraints) {
                    if (con.firstItem == btn && con.firstAttribute == NSLayoutAttributeLeft) {
                        con.constant = 10;
                    }
                }
            }
        }
        if (_controller[identifier] != self.selectedController) {
            [self chageController:_controller[identifier]];
        }
//        [self chageBgForIdentifier:identifier];
        [self changeBackground:_controller[identifier]];

        return NO;
    }
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // FixMe: 处理不同情况的segue
//    [self chageBgForIdentifier:segue.identifier];
    [self changeBackground:segue.destinationViewController];
    
    if ([segue.identifier isEqualToString:@"selfInfo"]) {
        [segue.destinationViewController setValue:[COSession session].user forKey:@"user"];
        return;
    }
    
    if ([segue.identifier isEqualToString:@"message"]) {
        self.msgController = segue.destinationViewController;
    }
    
    if ([segue isKindOfClass:[COContainerSegue class]]) {
        UIButton *btn = nil;
        if ([sender isKindOfClass:[UIButton class]]) {
            btn = sender;
        }
        [self unSelectBtn:btn];
        if (btn && !btn.selected) {
            btn.selected = YES;
            if (btn != _userBtn) {
                for (NSLayoutConstraint *con in btn.superview.constraints) {
                    if (con.firstItem == btn && con.firstAttribute == NSLayoutAttributeLeft) {
                        con.constant = 10;
                    }
                }
            }
        }
        [_controller setObject:segue.destinationViewController forKey:segue.identifier];
        [self chageController:segue.destinationViewController];
    }
}

- (void)chageController:(UIViewController *)destination
{
    if (_selectedController) {
//        [_selectedController viewWillDisappear:NO];
        [_selectedController.view removeFromSuperview];
//        [_selectedController viewDidDisappear:NO];
        _selectedController = nil;
    }

//    [destination viewWillAppear:NO];
    destination.view.frame = _container.bounds;
    [_container addSubview:destination.view];
//    [destination viewDidAppear:NO];
    _selectedController = destination;
}

- (void)chatToGlobalKey:(NSString *)globalKey
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self performSegueWithIdentifier:@"message" sender:nil];
    [self.msgController chatToGlobalKey:globalKey];
}

#pragma mark - action
- (void)unSelectBtn:(UIButton *)selectBtn
{
    for (id view in self.view.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *btn = view;
            if (btn.selected && btn!=selectBtn) {
                btn.selected = NO;
                if (btn != _userBtn) {
                    for (NSLayoutConstraint *con in btn.superview.constraints) {
                        if (con.firstItem == btn && con.firstAttribute == NSLayoutAttributeLeft) {
                            con.constant = 6;
                        }
                    }
                }
            }
        }
    }
}

- (void)rightBtnAction:(UIBarButtonItem *)sender
{
    [self.view endEditing:YES];
    [COMenuController popFromBarButtonItem:sender];
}

#pragma mark -
- (UIMessageInputView_Add *)getAddKeyboard
{
    if (self.addKeyboardView == nil) {
        _addKeyboardView = [[UIMessageInputView_Add alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, kKeyboardView_Height)];
        [self.view addSubview:_addKeyboardView];
    }
    return _addKeyboardView;
}

- (void)removeAddKeyboard
{
    [_addKeyboardView removeFromSuperview];
    self.addKeyboardView = nil;
}

#pragma mark - emoji
- (AGEmojiKeyboardView *)getEmoji:(BOOL)emojiBig
{
     if (_emojiBig != emojiBig) {
         _emojiBig = emojiBig;
         [self removeEmoji];
    }
    if (self.emojiKeyboardView == nil) {
        self.emojiKeyboardView = [[AGEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, kKeyboardView_Height) dataSource:self showBigEmotion:emojiBig];
        [self.navigationController.view addSubview:_emojiKeyboardView];
    }
    return _emojiKeyboardView;
}

- (void)removeEmoji
{
    [_emojiKeyboardView removeFromSuperview];
    self.emojiKeyboardView = nil;
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

#pragma mark - pop
- (void)popoverController:(UIViewController *)controller withSize:(CGSize)size
{
    BOOL reset = FALSE;
    if (self.popController) {
        reset = TRUE;
        _popShadowView.backgroundColor = [UIColor clearColor];
        [_popController.view removeFromSuperview];
        //[_popController removeFromParentViewController];
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
    
    [self.navigationController.view addSubview:_maskView];
    
    self.popController = controller;
    //[self.navigationController addChildViewController:controller];
    [_maskView addSubview:controller.view];
 
    _popShadowView.backgroundColor = [UIColor clearColor];
    
    [_popController viewWillAppear:YES];
  
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

- (void)popoverChangeRect:(CGRect)rect withDuration:(NSTimeInterval)duration withCurve:(UIViewAnimationCurve)curve
{
    if (_popController) {
        [UIView beginAnimations:@"changeViewFrame" context:NULL];
        [UIView setAnimationDuration:duration];
        [UIView setAnimationCurve:curve];
        
        _popController.view.frame = rect;
        _popShadowView.frame = rect;
        
        [UIView commitAnimations];
    }
}

- (void)popoverChangeSize:(CGSize)size
{
    if (_popController) {
        CGRect frame = CGRectMake((_maskView.frame.size.width - size.width) / 2, (_maskView.frame.size.height - size.height) / 2, size.width, size.height);
        [_popController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            _popController.view.frame = frame;
            _popShadowView.frame = frame;
        } completion:nil];
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
            //[_popController removeFromParentViewController];
            [_maskView removeFromSuperview];
            self.popController = nil;
        }];
    }];
}

- (void)dismissBtnAction
{
    [_popController.view endEditing:YES];
    id controller = _popController;
    if ([controller isKindOfClass:[UINavigationController class]]) {
        controller = ((UINavigationController *)controller).topViewController;
    }
    if ([controller isKindOfClass:[COAddTweetController class]]) {
        [((COAddTweetController *)controller) hideKeyboard];
    } else if ([controller isKindOfClass:[COTweetAddCommentController class]]) {
        [((COTweetAddCommentController *)controller) hideKeyboard];
    }
}

@end
