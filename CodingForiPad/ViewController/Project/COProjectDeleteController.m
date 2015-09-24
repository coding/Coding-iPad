//
//  COProjectDeleteController.m
//  CodingForiPad
//
//  Created by sgl on 15/7/9.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COProjectDeleteController.h"
#import "CORootViewController.h"
#import "COProjectRequest.h"
#import "COSession.h"
#import "COUtility.h"
#import "COProjectController.h"

@interface COProjectDeleteController ()
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation COProjectDeleteController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _textField.secureTextEntry = YES;
    [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    _deleteBtn.enabled = FALSE;
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
    [self.view endEditing:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    
    CGRect frame = CGRectMake((kScreen_Width - 400) / 2, kScreen_Height - 200 - height, 400, 200);
    [[CORootViewController currentRoot] popoverChangeRect:frame withDuration:animationDuration withCurve:animationCurve];
}

- (void)handleKeyboardWillHide:(NSNotification *)paramNotification
{
    NSUInteger animationCurve = 0;
    double animationDuration = 0.0f;
    [COUtility hideKeyboardInfo:paramNotification andCurve:&animationCurve andDuration:&animationDuration];

    CGRect frame = CGRectMake((kScreen_Width - 400) / 2, (kScreen_Height - 200) / 2, 400, 200);
    [[CORootViewController currentRoot] popoverChangeRect:frame withDuration:animationDuration withCurve:animationCurve];
}

#pragma mark - action
- (IBAction)cancelBtnAction:(UIButton *)sender
{
    [[CORootViewController currentRoot] dismissPopover];
}

- (IBAction)delBtnAction:(UIButton *)sender
{
    COProjectDeleteRequest *request = [COProjectDeleteRequest request];
    COUser *user = [[COSession session] user];
    request.globalKey = user.globalKey;
    request.userName = user.name;
    request.password = [COUtility sha1:_textField.text];
    request.projectName = _project.name;
    __weak typeof(self) weakself = self;
    [self showProgressHudWithMessage:@"正在删除项目"];
    [request deleteWithSuccess:^(CODataResponse *responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakself checkDataResponse:responseObject]) {
                [weakself showSuccess:@"删除项目成功"];
                [[NSNotificationCenter defaultCenter] postNotificationName:OPProjectReloadNotification object:nil];
                [[CORootViewController currentRoot] dismissPopover];
            }
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself showErrorInHudWithError:error];
        });
    }];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidChange:(UITextField *)textField
{
    _deleteBtn.enabled = FALSE;
    if (textField.text.length > 0) {
        _deleteBtn.enabled = TRUE;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}


@end
