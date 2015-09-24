//
//  NSObject+Utility.h
//  CodingForiPad
//
//  Created by zwm on 15/7/25.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CODataResponse;
@interface NSObject (Utility)

- (BOOL)checkDataResponse:(CODataResponse *)response;

- (void)showAlert:(NSString *)title message:(NSString *)message;
- (void)showError:(NSError *)error;
- (void)showErrorInHudWithError:(NSError *)error;
- (void)showErrorMessageInHud:(NSString *)error;
- (void)showProgressHud;
- (void)showProgressHudWithMessage:(NSString *)message;
- (void)showSuccess:(NSString *)success;
- (void)showErrorWithStatus:(NSString *)status;
- (void)showInfoWithStatus:(NSString *)status;
- (void)dismissProgressHud;

// 老式的
- (id)handleResponse:(id)responseJSON;
- (id)handleResponse:(id)responseJSON autoShowError:(BOOL)autoShowError;

@end
