//
//  COLoginViewController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/20.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COLoginViewController.h"
#import "COSession.h"
#import "COAccountRequest.h"
#import "COUtility.h"
#import "UIImageView+WebCache.h"
#import "CORegServiceViewController.h"
#import "CORegMailTipsView.h"
#import "UIActionSheet+Common.h"

#define kCOCaptchaHeight 50.0

#define kCOLoginViewHeight CGRectGetHeight(self.view.frame)
#define kCOLoginPopHeight CGRectGetHeight(self.loginView.frame)
#define kCOLoginShowOffset ((kCOLoginViewHeight - kCOLoginPopHeight)/2)

@interface COLoginViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL needCaptcha;
@property (nonatomic, assign) BOOL regNeedCaptcha;
@property (nonatomic, strong) CORegMailTipsView *mailView;

@end

@implementation COLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.loginView.layer.cornerRadius = 4.0;
    self.loginView.layer.masksToBounds = YES;
    self.registerView.layer.cornerRadius = 4.0;
    self.registerView.layer.masksToBounds = YES;
    self.registerView.hidden = YES;
    self.findView.layer.cornerRadius = 4.0;
    self.findView.layer.masksToBounds = YES;
    self.authView.layer.cornerRadius = 4.0;
    self.authView.layer.masksToBounds = YES;
    
    self.catpchaHeight.constant = 0.0;
    
    self.mailView = [[CORegMailTipsView alloc] initForTextField:_mailField height:30.0];
    
    [self tapToHideKeyboard];
    [self setupKeyboardNotification];
    
    [self requestCaptcha];
    self.regCatpchaView.hidden = YES;
    
    [self updateState:COLoginStateLogin];
    
    {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reloadLoginCaptach)];
        [self.codeImageView addGestureRecognizer:tap];
        self.codeImageView.userInteractionEnabled = YES;
    }
    
    {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reloadRegCaptach)];
        [self.regCodeImageView addGestureRecognizer:tap];
        self.regCodeImageView.userInteractionEnabled = YES;
    }
    
    {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reloadfindCaptach)];
        [self.findCodeImageView addGestureRecognizer:tap];
        self.findCodeImageView.userInteractionEnabled = YES;
    }
    
    self.loginViewOffset.constant =
    self.registerViewOffset.constant =
    self.authViewOffset.constant =
    self.findViewOffset.constant = kCOLoginShowOffset;
    [self.view layoutIfNeeded];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)reloadLoginCaptach
{
    [self showCaptcha];
}

- (void)reloadRegCaptach
{
    [self showRegCaptcha];
}

- (void)reloadfindCaptach
{
    [self loadFindCatpcha];
}

- (void)tapToHideKeyboard
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}

- (void)handleTap:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateEnded) {
        [self.view endEditing:YES];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view.superview isKindOfClass:[UITableViewCell class]]) {
        // we touched a button, slider, or other UIControl
        return NO; // ignore the touch
    }
    return YES; // handle the touch
}

#pragma mark - Update State
- (void)updateState:(COLoginState)state
{
    self.preState = self.state;
    self.state = state;
    
    _loginView.hidden = (self.state == COLoginStateLogin ? NO : YES);
    _registerView.hidden = (self.state == COLoginStateRegister ? NO : YES);
    _authView.hidden = (self.state == COLoginStateAuth ? NO : YES);
    _findView.hidden = ((self.state == COLoginStateFindPass || self.state == COLoginStateActive) ? NO : YES);
    
    if (self.state == COLoginStateFindPass) {
        [self.findSendBtn setTitle:@"发送重置密码邮件" forState:UIControlStateNormal];
    }
    else if (self.state == COLoginStateActive) {
        [self.findSendBtn setTitle:@"重发激活邮件" forState:UIControlStateNormal];
    }
    else {
        [self.findSendBtn setTitle:@"" forState:UIControlStateNormal];
    }
}

#pragma mark - Login
- (void)requestCaptcha
{
    COAccountCaptchaRequest *request = [COAccountCaptchaRequest request];
    request.action = @"login";
    
    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        // TODO: 显示验证码
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([responseObject.data boolValue]) {
                // 需要验证码
                weakself.needCaptcha = YES;
                [weakself showCaptcha];
            }
            else {
                // 不需要验证码
                weakself.needCaptcha = NO;
                [weakself hideCaptcha];
            }
        });
    } failure:^(NSError *error) {
        //
    }];
}

- (void)login
{
    NSString *username = _nameField.text;
    NSString *passwd = _passwdField.text;
    NSString *captcha = nil;
    if (_needCaptcha) {
        captcha = _captchaField.text;
    }
    
    self.loginBtn.enabled = NO;
    [self.loginActivity startAnimating];
    __weak typeof(self) weakself = self;
    [[COSession session] userLogin:username pwd:[COUtility sha1:passwd] jCaptcha:captcha result:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakself.loginBtn.enabled = YES;
            [weakself.loginActivity stopAnimating];
            if (error) {
                [weakself requestCaptcha];
                if (OPErrorCodeNeedAuthCode == error.code) {
                    [weakself showAuthCode];
                }
                else {
                    [weakself showError:error];
                }
            }
        });
    }];
}

- (void)showCaptcha
{
    if (self.catpchaHeight.constant != kCOCaptchaHeight) {
        self.catpchaHeight.constant = kCOCaptchaHeight;
        [UIView animateWithDuration:0.3 animations:^{
            [self.loginView layoutIfNeeded];
        }];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/getCaptcha", COAPIDomain];
    __weak typeof(self) weakself = self;
    [self.codeImageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil options:SDWebImageRetryFailed | SDWebImageHandleCookies | SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakself.codeImageView.image = [UIImage imageNamed:@"captcha_loadfail"];
            });
        }
    }];
}

- (void)hideCaptcha
{
    if (self.catpchaHeight.constant == 0.0) {
        return;
    }
    
    self.catpchaHeight.constant = 0.0;
    [UIView animateWithDuration:0.3 animations:^{
        [self.loginView layoutIfNeeded];
    }];
}

- (BOOL)checkField
{
    if (_nameField.text.length == 0) {
        [self showErrorWithStatus:@"用户名不能为空"];
        return NO;
    }
    
    if (_passwdField.text.length == 0) {
        [self showErrorWithStatus:@"密码不能为空"];
        return NO;
    }
    
    if (_needCaptcha) {
        if (_captchaField.text.length == 0) {
            [self showErrorWithStatus:@"验证码不能为空"];
            return NO;
        }
    }
    
    return YES;
}

- (IBAction)cantLoginAction:(id)sender
{
    [self.view endEditing:YES];
    UIActionSheet *sheet = [UIActionSheet bk_actionSheetCustomWithTitle:nil buttonTitles:@[@"找回密码", @"重发激活邮件"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
        switch (index) {
            case 0:
                // 找回密码
                [self findPassword];
                break;
            case 1:
                // 重发激活邮件
                [self resendMail];
            default:
                break;
        }
    }];
    
    [sheet showInView:self.view];
}

- (IBAction)loginAction:(id)sender
{
    if ([self checkField]) {
        [self login];
    }
}

#pragma mark - 注册
- (void)requestRegCaptcha
{
    COAccountCaptchaRequest *request = [COAccountCaptchaRequest request];
    request.action = @"register";
    
    __weak typeof(self) weakself = self;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        // TODO: 显示验证码
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([responseObject.data boolValue]) {
                // 需要验证码
                weakself.regNeedCaptcha = YES;
                [weakself showRegCaptcha];
            }
            else {
                // 不需要验证码
                weakself.regNeedCaptcha = NO;
                [weakself hideRegCaptcha];
            }
        });
    } failure:^(NSError *error) {
        //
    }];
}

- (void)showRegCaptcha
{
    self.regCatpchaView.hidden = NO;
    if (self.regCatpchaHeight.constant != kCOCaptchaHeight) {
        self.regCatpchaHeight.constant = kCOCaptchaHeight;
        [UIView animateWithDuration:0.3 animations:^{
            [self.registerView layoutIfNeeded];
        }];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/getCaptcha", COAPIDomain];
    __weak typeof(self) weakself = self;
    [self.regCodeImageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil options:SDWebImageRetryFailed | SDWebImageHandleCookies | SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakself.regCodeImageView.image = [UIImage imageNamed:@"captcha_loadfail"];
            });
        }
    }];
}

- (void)hideRegCaptcha
{
    if (self.regCatpchaHeight.constant == 0.0) {
        return;
    }
    
    self.regCatpchaHeight.constant = 0.0;
    [UIView animateWithDuration:0.3 animations:^{
        [self.regCatpchaView layoutIfNeeded];
    }];
}

- (void)regist
{
    COUser *user = [[COUser alloc] init];
    user.email = _mailField.text;
    user.globalKey = _globalKeyField.text;
    
    [[COSession session] userRegister:user jCaptcha:_regCatpchaField.text result:^(NSError *error) {
        if (error) {
            [self requestRegCaptcha];
            [self showError:error];
        }
    }];
}

- (BOOL)checkRegField
{
    if (_mailField.text.length == 0) {
        // TODO: 用户名不能为空
        [self showErrorWithStatus:@"用户名不能为空"];
        return NO;
    }
    
    if (_globalKeyField.text.length == 0) {
        // TODO: 密码不能为空
        [self showErrorWithStatus:@"密码不能为空"];
        return NO;
    }
    
    if (_regNeedCaptcha) {
        if (_regCatpchaField.text.length == 0) {
            // TODO: 验证码不能为空
            [self showErrorWithStatus:@"验证码不能为空"];
            return NO;
        }
    }
    
    return YES;
}
- (IBAction)registerAction:(id)sender
{
    if ([self checkRegField]) {
        [self regist];
    }
}

- (IBAction)showServiceAction:(id)sender
{
    [self.view endEditing:YES];
    
    CGSize viewSize = self.view.bounds.size;
    CGSize serviceSize = CGSizeMake(viewSize.width * 0.5, viewSize.height * 0.7);
    
    CORegServiceViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"CORegServiceViewController"];
    controller.view.frame = CGRectMake((viewSize.width - serviceSize.width) /2, viewSize.height, serviceSize.width, serviceSize.height);
    controller.view.layer.cornerRadius = 4.0;
    controller.view.layer.masksToBounds = YES;
    
    [self.view addSubview:controller.view];
    [self addChildViewController:controller];
    
    [UIView animateWithDuration:0.3 animations:^{
        controller.view.center = self.view.center;
    }];
}

#pragma mark - 二次认证
- (IBAction)authCodeAction:(id)sender
{
    if (_authCodeField.text.length == 0) {
        // TODO: 用户名不能为空
        [self showErrorWithStatus:@"动态验证码不能为空"];
        return;
    }
    
    __weak typeof(self) weakself = self;
    [[COSession session] userLoginWithAuthCode:self.authCodeField.text result:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [weakself showError:error];
            }
        });
    }];
}

#pragma mark -
- (IBAction)findSendAction:(id)sender
{
    if (_findMailField.text.length == 0) {
        [self showErrorWithStatus:@"邮箱不能为空"];
        return;
    }
    
    if (_findCatpchaField.text.length == 0) {
        [self showErrorWithStatus:@"验证码不能为空"];
        return;
    }
    
    if (self.state == COLoginStateFindPass) {
        COAccountResetPasswordMailRequest *request = [COAccountResetPasswordMailRequest request];
        request.email = _findMailField.text;
        request.jCaptcha = _findCatpchaField.text;
        [self showProgressHudWithMessage:@"请求中..."];
        __weak typeof(self) weakself = self;
        [request getWithSuccess:^(CODataResponse *responseObject) {
            if ([self checkDataResponse:responseObject]) {
                [weakself showSuccess:@"已发送邮件"];
                [weakself findCloseAction:nil];
            }
        } failure:^(NSError *error) {
            [weakself showErrorInHudWithError:error];
        }];
    }
    else if (self.state == COLoginStateActive) {
        COAccountResendActiveMailRequest *request = [COAccountResendActiveMailRequest request];
        request.email = _findMailField.text;
        request.jCaptcha = _findCatpchaField.text;
        [self showProgressHudWithMessage:@"请求中..."];
        __weak typeof(self) weakself = self;
        [request getWithSuccess:^(CODataResponse *responseObject) {
            if ([self checkDataResponse:responseObject]) {
                [weakself showSuccess:@"已发送邮件"];
                [weakself findCloseAction:nil];
            }
        } failure:^(NSError *error) {
            [weakself showErrorInHudWithError:error];
        }];
    }
}



#pragma mark - 状态转换
// 注册
- (IBAction)changeToRegist:(id)sender
{
    [self.view endEditing:YES];
    self.registerViewOffset.constant = kCOLoginViewHeight;
    [self.view layoutIfNeeded];
    
    self.registerView.hidden = NO;
    
    if (self.state == COLoginStateAuth) {
        self.authViewOffset.constant = -kCOLoginPopHeight;
    }
    else if (self.state == COLoginStateLogin) {
        self.loginViewOffset.constant = -kCOLoginPopHeight;
    }
    
    self.registerViewOffset.constant = kCOLoginShowOffset;
    
    [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.loginView.hidden = YES;
        self.loginViewOffset.constant = kCOLoginShowOffset;
        self.authView.hidden = YES;
        self.authViewOffset.constant = kCOLoginShowOffset;
        [self requestRegCaptcha];
        [self updateState:COLoginStateRegister];
    }];
}

// 登录
- (IBAction)changeToLogin:(id)sender
{

    
    [self.view endEditing:YES];
    self.loginViewOffset.constant = -kCOLoginPopHeight;
    [self.view layoutIfNeeded];
    self.loginView.hidden = NO;
    self.loginViewOffset.constant = kCOLoginShowOffset;
    self.registerViewOffset.constant = kCOLoginViewHeight;
    
    [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.registerView.hidden = YES;
        self.registerViewOffset.constant = kCOLoginShowOffset;
        [self requestCaptcha];
        [self updateState:COLoginStateLogin];
    }];
}

// 二次认证提示
- (void)showAuthCode
{
    [self.view endEditing:YES];
    self.authView.alpha = 0.0;
    self.authView.hidden = NO;
    
    [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.authView.alpha = 1.0;
        self.loginView.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.loginView.hidden = YES;
        self.loginView.alpha = 1.0;
        [self updateState:COLoginStateAuth];
    }];
}

// 找回密码
- (void)findPassword
{
    [self.view endEditing:YES];
    self.findView.alpha = 0.0;
    self.findView.hidden = NO;
    [self.findSendBtn setTitle:@"发送重置密码邮件" forState:UIControlStateNormal];
    
    [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.findView.alpha = 1.0;
        self.loginView.alpha = 0.0;
        self.authView.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.loginView.hidden = YES;
        self.loginView.alpha = 1.0;
        self.authView.hidden = YES;
        self.authView.alpha = 1.0;
        [self updateState:COLoginStateFindPass];
    }];
    
    [self loadFindCatpcha];
}

- (void)loadFindCatpcha
{
    NSString *url = [NSString stringWithFormat:@"%@/getCaptcha", COAPIDomain];
    __weak typeof(self) weakself = self;
    [self.findCodeImageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil options:SDWebImageRetryFailed | SDWebImageHandleCookies | SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakself.regCodeImageView.image = [UIImage imageNamed:@"captcha_loadfail"];
            });
        }
    }];
}

// 发送激活邮件
- (void)resendMail
{
    [self.view endEditing:YES];
    self.findView.alpha = 0.0;
    self.findView.hidden = NO;
    [self.findSendBtn setTitle:@"重发激活邮件" forState:UIControlStateNormal];
    
    [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.findView.alpha = 1.0;
        self.loginView.alpha = 0.0;
        self.authView.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.loginView.hidden = YES;
        self.loginView.alpha = 1.0;
        self.authView.hidden = YES;
        self.authView.alpha = 1.0;
        [self updateState:COLoginStateActive];
    }];
    
    NSString *url = [NSString stringWithFormat:@"%@/getCaptcha", COAPIDomain];
    __weak typeof(self) weakself = self;
    [self.findCodeImageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil options:SDWebImageRetryFailed | SDWebImageHandleCookies | SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakself.regCodeImageView.image = [UIImage imageNamed:@"captcha_loadfail"];
            });
        }
    }];
}

// 关闭
- (IBAction)findCloseAction:(id)sender
{
    [self.view endEditing:YES];
    if (self.preState == COLoginStateLogin) {
        self.loginView.alpha = 0.0;
        self.loginView.hidden = NO;
    }
    else if (self.preState == COLoginStateAuth) {
        self.authView.alpha = 0.0;
        self.authView.hidden = NO;
    }
    
    [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.findView.alpha = 0.0;
        self.loginView.alpha = 1.0;
        self.authView.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.findView.hidden = YES;
        self.findView.alpha = 1.0;
        self.findCatpchaField.text = @"";
        self.findMailField.text = @"";
        [self updateState:self.preState];
    }];
}

#pragma mark -
- (void)setupKeyboardNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardFrameChanged:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
}

- (void)removeKeyboardNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidChangeFrameNotification
                                                  object:nil];
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    /*
     NSString *const UIKeyboardFrameBeginUserInfoKey;
     NSString *const UIKeyboardFrameEndUserInfoKey;
     NSString *const UIKeyboardAnimationDurationUserInfoKey;
     NSString *const UIKeyboardAnimationCurveUserInfoKey;
     */
    
//    CGRect keyboardFrame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardStartFrame = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    
    if (keyboardStartFrame.origin.y != [UIScreen mainScreen].bounds.size.height) {
        return;
    }
    
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    
    self.loginViewOffset.constant = 44.0;
    self.registerViewOffset.constant = 44.0;
    self.authViewOffset.constant = 44.0;
    self.findViewOffset.constant = 44.0;
    [UIView animateWithDuration:duration delay:0.0 options:curve animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (finished) {
            
        }
    }];
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    self.loginViewOffset.constant =
    self.registerViewOffset.constant =
    self.authViewOffset.constant =
    self.findViewOffset.constant = kCOLoginShowOffset;
    [UIView animateWithDuration:duration delay:0.0 options:curve animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (finished) {
            
        }
    }];
}

- (void)keyboardDidShow:(NSNotification*)notification
{
    
}

- (void)keyboardDidHide:(NSNotification*)notification
{
    
}

- (void)keyboardFrameChanged:(NSNotification*)notification
{
    
}

@end
