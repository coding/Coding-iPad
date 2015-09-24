//
//  COSession.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/10.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "COUser.h"

typedef enum : NSUInteger {
    COSessionUserStatusDefault,
    COSessionUserStatusLogined,
    COSessionUserStatusLogout,
} COSessionUserStatus;

@interface COSession : NSObject

@property (nonatomic, readonly, strong) COUser *user;
@property (nonatomic, readonly, assign) COSessionUserStatus userStatus;
@property (nonatomic, assign) BOOL userNeedActive;

+ (instancetype)session;
- (void)updateUserInfo;

@end


@interface COSession (Login)

+ (BOOL)isLogin;

- (void)userLogin:(NSString *)username pwd:(NSString *)pwd jCaptcha:(NSString *)jCaptcha result:(void(^)(NSError *error))result;
- (void)userRegister:(COUser *)user jCaptcha:(NSString *)jCaptcha result:(void(^)(NSError *error))result;
- (void)userLoginWithAuthCode:(NSString *)authCode result:(void(^)(NSError *error))result;
- (void)userLogout;

@end