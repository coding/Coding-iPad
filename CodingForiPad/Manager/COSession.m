//
//  COSession.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/10.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COSession.h"
#import "COAccountRequest.h"

@interface COSession()

@end

@implementation COSession

- (instancetype)init
{
    self = [super init];
    if (self) {
        _user = [self loadUser];
        if (_user) {
            _userStatus = COSessionUserStatusLogined;
        }
    }
    return self;
}

+ (instancetype)session
{
    static id session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        session = [[COSession alloc] init];
    });
    return session;
}

- (void)updateUserInfo
{
    COAccountUserInfoRequest *request = [COAccountUserInfoRequest request];
    request.globalKey = self.user.globalKey;
    [request getWithSuccess:^(CODataResponse *responseObject) {
        if (responseObject.code == 0
            && responseObject.error == nil) {
            [self willChangeValueForKey:@"user"];
            _user = responseObject.data;
            [self didChangeValueForKey:@"user"];
            [self saveUser:_user];
        }
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

#pragma mark - Login

+ (BOOL)isLogin
{
    return [[COSession session] user] != nil;
}

- (NSError *)checkLoginSuccess:(CODataResponse *)response
{
    NSError *error = nil;
    if (response.code == 0) {
        return nil;
    }
    else {
        if ([response.msg isKindOfClass:[NSDictionary class]]) {
            if (response.msg[@"two_factor_auth_code_not_empty"]) {
                // 二次认证
                NSString *msg = [response displayMsg];
                error = [NSError errorWithDomain:@"net.coding.ipad" code:OPErrorCodeNeedAuthCode userInfo:@{NSLocalizedDescriptionKey: msg, NSLocalizedFailureReasonErrorKey : msg}];
            } else if (response.msg[@"email"] || response.msg[@"j_captcha_error"]) {
                // 用户名密码、验证码
                NSString *msg = [response displayMsg];
                error = [NSError errorWithDomain:@"net.coding.ipad" code:response.code userInfo:@{NSLocalizedDescriptionKey: msg, NSLocalizedFailureReasonErrorKey : msg}];
            }
        }
        else {
            NSString *msg = [response displayMsg];
            error = [NSError errorWithDomain:@"net.coding.ipad" code:response.code userInfo:@{NSLocalizedDescriptionKey: msg, NSLocalizedFailureReasonErrorKey : msg}];
        }
    }
    
    return error;
}

- (void)userLogin:(NSString *)username pwd:(NSString *)pwd jCaptcha:(NSString *)jCaptcha result:(void(^)(NSError *error))result
{
    COAccountLoginRequest *request = [COAccountLoginRequest request];
    request.email = username;
    request.password = pwd;
    request.jCaptcha = jCaptcha;
    request.rememberMe = @"true";
    
    __weak typeof(self) weakself = self;
    [request postWithSuccess:^(CODataResponse *responseObject) {
        if (result) {
            [weakself loginSuccess:responseObject];
            result([self checkLoginSuccess:responseObject]);
        }
    } failure:^(NSError *error) {
        if (result) {
            result(error);
        }
    }];
}

- (void)userRegister:(COUser *)user jCaptcha:(NSString *)jCaptcha result:(void(^)(NSError *error))result
{
    COAccountRegisterRequest *request = [COAccountRegisterRequest request];
    request.email = user.email;
    request.globalKey = user.globalKey;
    request.jCaptcha = jCaptcha;
    
    [request postWithSuccess:^(CODataResponse *responseObject) {
        if (result) {
            [self loginSuccess:responseObject];
            if (self.user) {
                self.userNeedActive = YES;
            }
            result([self checkLoginSuccess:responseObject]);
        }
    } failure:^(NSError *error) {
        if (result) {
            result(error);
        }
    }];
}


- (void)userLoginWithAuthCode:(NSString *)authCode result:(void(^)(NSError *error))result
{
    COAccountAuthCodeRequest *request = [COAccountAuthCodeRequest request];
    request.authCode = authCode;
    __weak typeof(self) weakself = self;
    [request postWithSuccess:^(CODataResponse *responseObject) {
        if (result) {
            [weakself loginSuccess:responseObject];
            result([self checkLoginSuccess:responseObject]);
        }
    } failure:^(NSError *error) {
        if (result) {
            result(error);
        }
    }];
}

- (void)userLogout
{
    [self saveUser:nil];
    [self willChangeValueForKey:@"user"];
    _user = nil;
    [self didChangeValueForKey:@"user"];
    
    [self updateUserStatus:COSessionUserStatusLogout];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    [cookies enumerateObjectsUsingBlock:^(NSHTTPCookie *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.domain hasSuffix:@".coding.net"]) {
             [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:obj];
        }
   }];
}

- (void)loginSuccess:(CODataResponse *)response
{
    if (response.error == nil
        && 0 == response.code) {
        // 登录成功
        [self willChangeValueForKey:@"user"];
        _user = response.data;
        [self didChangeValueForKey:@"user"];
        [self saveUser:_user];
        
        [self updateUserStatus:COSessionUserStatusLogined];
    }
}

- (void)updateUserStatus:(COSessionUserStatus)status
{
    [self willChangeValueForKey:@"userStatus"];
    _userStatus = status;
    [self didChangeValueForKey:@"userStatus"];
}


#define kCOCodingUserKey @"COCodingUserKey"

- (void)saveUser:(COUser *)user
{
    if (nil == user) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCOCodingUserKey];
    }
    else {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:user];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:kCOCodingUserKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (COUser *)loadUser
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kCOCodingUserKey];
    if (nil == data) {
        return nil;
    }
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

@end
