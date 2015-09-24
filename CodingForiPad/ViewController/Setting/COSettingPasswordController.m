//
//  COSettingPasswordController.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/22.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COSettingPasswordController.h"
#import "CORootViewController.h"
#import "UIViewController+Utility.h"
#import "COAccountRequest.h"
#import "NSString+Common.h"
#import "COSession.h"

@interface COSettingPasswordController ()

@property (strong, nonatomic) IBOutlet UIButton *okBtn;
@property (weak, nonatomic) IBOutlet UITextField *oldPassword;
@property (weak, nonatomic) IBOutlet UITextField *myPassword;
@property (weak, nonatomic) IBOutlet UITextField *myPassword2;

@end

@implementation COSettingPasswordController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _oldPassword.text = @"";
    _myPassword.text = @"";
    _myPassword2.text = @"";
    [_oldPassword addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_myPassword addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_myPassword2 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _okBtn.enabled = FALSE;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _oldPassword.text = @"";
    _myPassword.text = @"";
    _myPassword2.text = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)changePasswordTips
{
    NSString *tipStr = nil;
    if (_oldPassword.text.length <= 0) {
        tipStr = @"请输入当前密码";
    } else if (_myPassword.text.length <= 0) {
        tipStr = @"请输入新密码";
    } else if (_myPassword2.text.length <= 0) {
        tipStr = @"请确认新密码";
    } else if (![_myPassword.text isEqualToString:_myPassword2.text]){
        tipStr = @"两次输入的密码不一致";
    } else if (_myPassword.text.length < 6) {
        tipStr = @"新密码不能少于6位";
    } else if (_myPassword.text.length > 64) {
        tipStr = @"新密码不得长于64位";
    }
    return tipStr;
}

- (BOOL)changePasswordOK
{
    BOOL ret = TRUE;
    if (_oldPassword.text.length <= 0
        || _myPassword.text.length <= 0
        || _myPassword2.text.length <= 0) {
        ret = FALSE;
    }
    return ret;
}

#pragma mark - action
- (IBAction)cancelBtnAction:(UIButton *)sender
{
    [[CORootViewController currentRoot] dismissPopover];
}

- (IBAction)okBtnAction:(UIButton *)sender
{
    // 重新设置密码
    NSString *tips = [self changePasswordTips];
    if (tips) {
        [self showErrorMessageInHud:tips];
    } else {
        sender.enabled = NO;
        COAccountUpdatePwdRequest *reqeust = [COAccountUpdatePwdRequest request];
        reqeust.currentPassword = [_oldPassword.text sha1Str];
        reqeust.password = [_myPassword.text sha1Str];
        reqeust.confirmPassword = [_myPassword2.text sha1Str];
        __weak typeof(self) weakself = self;
        [reqeust postWithSuccess:^(CODataResponse *responseObject) {
            weakself.okBtn.enabled = YES;
            if ([weakself checkDataResponse:responseObject]) {
                [[[UIAlertView alloc] initWithTitle:@"提示" message:@"修改密码成功，您需要重新登陆哦～" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil] show];
            }
        } failure:^(NSError *error) {
            weakself.okBtn.enabled = YES;
            [weakself showErrorInHudWithError:error];
        }];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[COSession session] userLogout];
    [[CORootViewController currentRoot] dismissPopover];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidChange:(UITextField *)textField
{
    _okBtn.enabled = [self changePasswordOK];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _oldPassword) {
        [_myPassword becomeFirstResponder];
    } else if (textField == _myPassword) {
        [_myPassword2 becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

@end
