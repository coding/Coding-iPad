//
//  NSObject+Utility.m
//  CodingForiPad
//
//  Created by zwm on 15/7/25.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SVProgressHUD.h>
#import <objc/message.h>
#import "NSObject+Utility.h"
#import "COSession.h"
#import "CODataResponse.h"

#define kNetPath_Code_Base        @"https://coding.net/"

static void *HudVisibleKey = &HudVisibleKey;

@implementation NSObject (Utility)

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

- (void)showAlert:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)showError:(NSError *)error
{
    [self showAlert:@"错误" message:error.localizedDescription];
}

- (void)showErrorInHudWithError:(NSError *)error
{
    [SVProgressHUD showErrorWithStatus:error.localizedDescription maskType:SVProgressHUDMaskTypeBlack];
}

- (void)showErrorMessageInHud:(NSString *)error
{
    [SVProgressHUD showErrorWithStatus:error maskType:SVProgressHUDMaskTypeBlack];
}

- (void)showProgressHud
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    self.hudVisible = YES;
}

- (void)showProgressHudWithMessage:(NSString *)message
{
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

- (void)dismissProgressHud
{
    [SVProgressHUD dismiss];
    self.hudVisible = NO;
}

- (id)handleResponse:(id)responseJSON
{
    return [self handleResponse:responseJSON autoShowError:YES];
}

- (id)handleResponse:(id)responseJSON autoShowError:(BOOL)autoShowError
{
    NSError *error = nil;
    //code为非0值时，表示有错
    NSNumber *resultCode = [responseJSON valueForKeyPath:@"code"];
    
    if (resultCode.intValue != 0) {
        error = [NSError errorWithDomain:kNetPath_Code_Base code:resultCode.intValue userInfo:responseJSON];
        if (autoShowError) {
            [self showError:error];
        }
        if (resultCode.intValue == 1000) {
            //用户未登录
            [[COSession session] userLogout];
        }
    }
    return error;
}

@end
