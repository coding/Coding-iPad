//
//  UIViewController+Utility.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/10.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "UIViewController+Utility.h"
#import <objc/message.h>
#import <SVProgressHUD.h>
#import "CORootViewController.h"
#import "COSession.h"
#import <Masonry.h>

static void *HudVisibleKey = &HudVisibleKey;

@interface EaseLoadingView : UIView
@property (nonatomic, assign) CGFloat loopAngle, monkeyAlpha, angleStep, alphaStep;
@property (strong, nonatomic) UIImageView *loopView, *monkeyView;
@property (assign, nonatomic, readonly) BOOL isLoading;
- (void)startAnimating;
- (void)stopAnimating;
@end

@implementation EaseLoadingView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _loopView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading_loop"]];
        _monkeyView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading_monkey"]];
        [_loopView setCenter:self.center];
        [_monkeyView setCenter:self.center];
        [self addSubview:_loopView];
        [self addSubview:_monkeyView];
        [_loopView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
        [_monkeyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
        
        _loopAngle = 0.0;
        _monkeyAlpha = 1.0;
        _angleStep = 360/3;
        _alphaStep = 1.0/3.0;
    }
    return self;
}

- (void)startAnimating{
    self.hidden = NO;
    if (_isLoading) {
        return;
    }
    _isLoading = YES;
    [self loadingAnimation];
}

- (void)stopAnimating{
    self.hidden = YES;
    _isLoading = NO;
}

- (void)loadingAnimation{
    static CGFloat duration = 0.25f;
    _loopAngle += _angleStep;
    if (_monkeyAlpha >= 1.0 || _monkeyAlpha <= 0.0) {
        _alphaStep = -_alphaStep;
    }
    _monkeyAlpha += _alphaStep;
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        CGAffineTransform loopAngleTransform = CGAffineTransformMakeRotation(_loopAngle * (M_PI / 180.0f));
        _loopView.transform = loopAngleTransform;
        _monkeyView.alpha = _monkeyAlpha;
    } completion:^(BOOL finished) {
        if (_isLoading && [self superview] != nil) {
            [self loadingAnimation];
        }else{
            [self removeFromSuperview];
            
            _loopAngle = 0.0;
            _monkeyAlpha = 1,0;
            _alphaStep = ABS(_alphaStep);
            CGAffineTransform loopAngleTransform = CGAffineTransformMakeRotation(_loopAngle * (M_PI / 180.0f));
            _loopView.transform = loopAngleTransform;
            _monkeyView.alpha = _monkeyAlpha;
        }
    }];
}

@end

@implementation UIViewController (Utility)

- (BOOL)hudVisible
{
    id hudVisible = objc_getAssociatedObject(self, HudVisibleKey);
    if (hudVisible) {
        return [hudVisible boolValue];
    }
    return NO;
}

- (void)setHudVisible:(BOOL)hudVisible
{
    objc_setAssociatedObject(self, HudVisibleKey, @(hudVisible), OBJC_ASSOCIATION_RETAIN);
}

- (UIViewController *)controllerFromClass:(Class)aClass
{
    NSString *identifier = NSStringFromClass(aClass);
    return [self.storyboard instantiateViewControllerWithIdentifier:identifier];
}

- (void)showAlert:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)showError:(NSError *)error
{
    [self showAlert:@"错误" message:error.localizedDescription];
}

- (void)showErrorInHudWithError:(NSError *)error {
    [SVProgressHUD showErrorWithStatus:error.localizedDescription maskType:SVProgressHUDMaskTypeBlack];
}

- (void)showErrorMessageInHud:(NSString *)error {
    [SVProgressHUD showErrorWithStatus:error maskType:SVProgressHUDMaskTypeBlack];
}

- (void)showLoadingView
{
    [self removeLodingView];
    EaseLoadingView *view = [[EaseLoadingView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:view];
    [view startAnimating];
}

- (void)removeLodingView
{
    NSMutableArray *views = [NSMutableArray array];
    for (id subview in self.view.subviews) {
        if ([subview isKindOfClass:[EaseLoadingView class]]) {
            [views addObject:subview];
        }
    }
    
    for (EaseLoadingView *view in views) {
        [view stopAnimating];
        [view removeFromSuperview];
    }
}

- (void)showProgressHud
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeNone];
//    [self showLoadingView];
    self.hudVisible = YES;
}

- (void)showProgressHudWithMessage:(NSString *)message {
    [SVProgressHUD showWithStatus:message maskType:SVProgressHUDMaskTypeBlack];
    self.hudVisible = YES;
}

- (void)showSuccess:(NSString *)success
{
    [SVProgressHUD showSuccessWithStatus:success];
}

- (void)showErrorWithStatus:(NSString *)status
{
    [SVProgressHUD showErrorWithStatus:status];
}

- (void)showInfoWithStatus:(NSString *)status
{
    [SVProgressHUD showInfoWithStatus:status];
}

- (void)showErrorReloadView:(COEmptyActionBlock)action
{
    [self showErrorReloadView:action padding:UIEdgeInsetsZero];
}

- (void)showErrorReloadView:(COEmptyActionBlock)action padding:(UIEdgeInsets)padding
{
    [self dismissProgressHud];
    COEmptyView *view = [COEmptyView reloadView:action];
    [view showInView:self.view padding:padding];
}

- (void)dismissProgressHud
{
    [SVProgressHUD dismiss];
//    [self removeLodingView];
    self.hudVisible = NO;
}

- (void)tapToResignFirstResponse
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
}

- (void)handleTap:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateEnded) {
        [self.view endEditing:YES];
    }
}

- (BOOL)isFieldEmpty:(UITextField *)field message:(NSString *)message
{
    if (field.text.length == 0) {
        [self showAlert:nil message:message];
        return YES;
    }
    return NO;
}

- (void)changeBackItem
{
    if (self.navigationController
        && [self.navigationController.viewControllers count] > 1) {
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
        self.navigationItem.leftBarButtonItem = backItem;
    }
    
}

- (IBAction)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)checkDataResponse:(CODataResponse *)response
{
    if (0 == response.code
        && nil == response.error) {
        return YES;
    }
    else {
        if (response.code == 1000) {
            // 用户未登录
            [[COSession session] userLogout];
        }
        if ([response.msg isKindOfClass:[NSDictionary class]]) {
            // 需要二次认证, 直接登出
            if (response.msg[@"two_factor_auth_required_login"]) {
                [[COSession session] userLogout];
                // 避免弹框
                return YES;
            }
        }
        if (response.error) {
            [self showError:response.error];
        }
        else {
            if ([response.msg isKindOfClass:[NSDictionary class]]) {
                NSDictionary *msg = (NSDictionary *)response.msg;
                [self showErrorMessageInHud:[msg allValues].firstObject];
            }
            else if ([response.msg isKindOfClass:[NSString class]]) {
                [self showErrorMessageInHud:response.msg];
            }
            else {
                [self showErrorMessageInHud:@"请求错误"];
            }
        }
        return NO;
    }
}

- (void)rootPushViewController:(UIViewController *)controller animated:(BOOL)animated
{
    [[CORootViewController currentRoot].navigationController pushViewController:controller animated:animated];
}

@end
