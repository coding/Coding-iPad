//
//  UIViewController+Utility.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/10.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CODataRequest.h"
#import "COEmptyView.h"

@interface UIViewController (Utility)

@property (atomic, assign) BOOL hudVisible;

- (UIViewController *)controllerFromClass:(Class)aClass;

- (void)showAlert:(NSString *)title message:(NSString *)message;
- (IBAction)backAction:(id)sender;
- (void)showError:(NSError *)error;
- (void)showErrorInHudWithError:(NSError *)error;
- (void)showErrorMessageInHud:(NSString *)error;
- (void)showProgressHud;
- (void)showProgressHudWithMessage:(NSString *)message;
- (void)showSuccess:(NSString *)success;
- (void)showErrorWithStatus:(NSString *)status;
- (void)showInfoWithStatus:(NSString *)status;
- (void)showErrorReloadView:(COEmptyActionBlock)action;
- (void)showErrorReloadView:(COEmptyActionBlock)action padding:(UIEdgeInsets)padding;
- (void)dismissProgressHud;

- (void)tapToResignFirstResponse;
- (BOOL)isFieldEmpty:(UITextField *)field message:(NSString *)message;
- (void)changeBackItem;

- (BOOL)checkDataResponse:(CODataResponse *)response;

- (void)rootPushViewController:(UIViewController *)controller animated:(BOOL)animated;


@end
