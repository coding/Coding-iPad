//
//  COLoginViewController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/20.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COBaseViewController.h"

typedef enum : NSUInteger {
    COLoginStateLogin = 0,      // 登录
    COLoginStateRegister,   // 注册
    COLoginStateAuth,       // 二次认证
    COLoginStateFindPass,   // 找回密码
    COLoginStateActive,     // 激活
} COLoginState;


@interface COLoginViewController : COBaseViewController

@property (nonatomic, assign) COLoginState state;
@property (nonatomic, assign) COLoginState preState;
// 登录
@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (nonatomic, weak) IBOutlet UITextField *nameField;
@property (nonatomic, weak) IBOutlet UITextField *passwdField;
@property (nonatomic, weak) IBOutlet UITextField *captchaField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginViewOffset;
@property (weak, nonatomic) IBOutlet UIView *catpchaView;
@property (weak, nonatomic) IBOutlet UIImageView *codeImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *catpchaHeight;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loginActivity;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

// 注册
@property (weak, nonatomic) IBOutlet UIView *registerView;
@property (weak, nonatomic) IBOutlet UITextField *mailField;
@property (weak, nonatomic) IBOutlet UITextField *globalKeyField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *registerViewOffset;
@property (weak, nonatomic) IBOutlet UIView *regCatpchaView;
@property (weak, nonatomic) IBOutlet UITextField *regCatpchaField;
@property (weak, nonatomic) IBOutlet UIImageView *regCodeImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *regCatpchaHeight;

// 二次验证
@property (weak, nonatomic) IBOutlet UIView *authView;
@property (weak, nonatomic) IBOutlet UITextField *authCodeField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *authViewOffset;

// 找回密码&激活邮件
@property (weak, nonatomic) IBOutlet UIView *findView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *findViewOffset;
@property (weak, nonatomic) IBOutlet UITextField *findMailField;
@property (weak, nonatomic) IBOutlet UITextField *findCatpchaField;
@property (weak, nonatomic) IBOutlet UIImageView *findCodeImageView;
@property (weak, nonatomic) IBOutlet UIButton *findSendBtn;

@end
