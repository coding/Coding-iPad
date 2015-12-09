//
//  COAccountRequest.h
//  CodingModels
//
//  Created by sunguanglei on 15/5/19.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "CODataRequest.h"
#import "COUser.h"
#import "COTag.h"

@interface COAccountCheckRequest : CODataRequest

@property (nonatomic, copy) COQueryParameters NSString *key;

@end

@interface COAccountRegisterRequest : CODataRequest

@property (nonatomic, copy) COFormParameters NSString *email;
@property (nonatomic, copy) COFormParameters NSString *globalKey;
@property (nonatomic, copy) COFormParameters NSString *jCaptcha;
@property (nonatomic, copy, readonly) COFormParameters NSString *channel;

@end

COPostRequest
@interface COAccountLoginRequest : CODataRequest

@property (nonatomic, copy) COFormParameters NSString *email;
@property (nonatomic, copy) COFormParameters NSString *password;
@property (nonatomic, copy) COFormParameters NSString *jCaptcha;
@property (nonatomic, copy) COFormParameters NSString *rememberMe;

@end

@interface COAccountLogoutRequest : CODataRequest


@end

@interface COAccountCaptchaRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSString *action;

@end

@interface COAccountActivateRequest : CODataRequest

@property (nonatomic, copy) COQueryParameters NSString *email;
@property (nonatomic, copy) COQueryParameters NSString *jCaptcha;
@property (nonatomic, copy) COQueryParameters NSString *key;
@property (nonatomic, copy) COQueryParameters NSString *password;
@property (nonatomic, copy) COQueryParameters NSString *comfirmPassword;

@end

@interface COAccountResetPasswordRequest : CODataRequest

@property (nonatomic, copy) COQueryParameters NSString *jCaptcha;
@property (nonatomic, copy) COQueryParameters NSString *email;
@property (nonatomic, copy) COQueryParameters NSString *key;
@property (nonatomic, copy) COQueryParameters NSString *password;
@property (nonatomic, copy) COQueryParameters NSString *comfirmPassword;

@end

@interface COAccountInviteRequest : CODataRequest

@property (nonatomic, copy) COQueryParameters NSString *key;
@property (nonatomic, copy) COQueryParameters NSString *email;
@property (nonatomic, copy) COQueryParameters NSString *content;

@end

@interface COAccountInviteRegisterRequest : CODataRequest

@property (nonatomic, copy) COQueryParameters NSString *key;
@property (nonatomic, copy) COQueryParameters NSString *email;
@property (nonatomic, copy) COQueryParameters NSString *userName;
@property (nonatomic, copy) COQueryParameters NSString *jCaptcha;

@end

@interface COAccountNameRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSString *username;

@end

@interface COAccountNameNoCacheRequest : CODataRequest


@end

@interface COAccountCurrentUserRequest : CODataRequest


@end

@interface COAccountAvatarRequest : CODataRequest


@end

@interface COAccountSearchRequest : CODataRequest

@property (nonatomic, copy) COQueryParameters NSString *key;

@end

@interface COAccountUpdateInfoRequest : CODataRequest

@property (nonatomic, copy) COFormParameters NSNumber *userID;
@property (nonatomic, copy) COFormParameters NSString *globalKey;
@property (nonatomic, copy) COFormParameters NSString *location;
@property (nonatomic, copy) COFormParameters NSString *slogan;

@property (nonatomic, copy) COFormParameters NSString *email;

@property (nonatomic, copy) COFormParameters NSString *avatar;

@property (nonatomic, copy) COFormParameters NSString *name;
@property (nonatomic, copy) COFormParameters NSNumber *sex;

@property (nonatomic, copy) COFormParameters NSString *phone;

@property (nonatomic, copy) COFormParameters NSString *birthday;
@property (nonatomic, copy) COFormParameters NSString *company;
@property (nonatomic, assign) COFormParameters NSNumber *job;
@property (nonatomic, copy) COFormParameters NSString *tags;

/**
 *  通过user初始化默认参数
 *
 *  @param user 需要更新的用户
 */
- (void)assignWithUser:(COUser *)user;

@end


@interface COAccountUpdateAvatarRequest : CODataRequest

@end

COGetRequest
@interface COAccountUserInfoRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSString *globalKey;

@end

@interface COAccountGetNoticeSettingsRequest : CODataRequest


@end

@interface COAccountChangeNoticeSettingRequest : CODataRequest

@property (nonatomic, copy) COQueryParameters NSString *settingType;
@property (nonatomic, copy) COQueryParameters NSString *settingContent;

@end

@interface COAccountUpdatePwdRequest : CODataRequest

@property (nonatomic, copy) COFormParameters NSString *currentPassword;
@property (nonatomic, copy) COFormParameters NSString *password;
@property (nonatomic, copy) COFormParameters NSString *confirmPassword;

@end

COPostRequest
CODeleteRequest
@interface COAccountProjectsPinRequest : CODataRequest

@property (nonatomic, copy) COQueryParameters NSString *ids;

@end

@interface COAccountActivitiesLastRequest : CODataRequest

@property (nonatomic, copy) COQueryParameters NSString *lastId;

@end

@interface COAccountActivitiesRequest : CODataRequest


@end


@interface COAccountWallpapers : CODataRequest

@property (nonatomic, copy) NSNumber *type;

@end

// 请求所有职位信息
@interface COUserJobArrayRequest : CODataRequest

@end

// 请求所有标签信息
@interface COUserTagArrayRequest : CODataRequest

@end

// 更新用户个人信息
@interface COUserUpdateInfoRequest : CODataRequest


@end

COGetRequest
@interface COUserSearch : CODataRequest

@property (nonatomic, assign) COQueryParameters NSString *key;

@end

// 关注或取关某人
COPostRequest
@interface COFollowedOrNot : CODataRequest

@property (nonatomic, assign) BOOL isFollowed;
@property (nonatomic, assign) COFormParameters NSString *users;//globalKey或id

@end

COPostRequest
@interface COMarkReadRequest : CODataRequest

@property (nonatomic, copy) COFormParameters NSString *notificationId;

@end

COPostRequest
@interface COConversationReadRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSString *globalKey;

@end

COGetRequest
@interface COUnreadCountRequest : CODataRequest

@end

COPostRequest
@interface COAccountAuthCodeRequest : CODataRequest

@property (nonatomic, copy) COFormParameters NSString *authCode;

@end

COGetRequest
@interface COAccountResetPasswordMailRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSString *email;
@property (nonatomic, copy) COUriParameters NSString *jCaptcha;

@end

COGetRequest
@interface COAccountResendActiveMailRequest : CODataRequest

@property (nonatomic, copy) COQueryParameters NSString *email;
@property (nonatomic, copy) COQueryParameters NSString *jCaptcha;

@end

COPostRequest
@interface COReportIllegalContentRequest : CODataRequest

/**
 * tweet, topic, project, website
 */
@property (nonatomic, copy) COUriParameters NSString *type;
@property (nonatomic, copy) COFormParameters NSString *user;
@property (nonatomic, copy) COFormParameters NSString *content;
@property (nonatomic, copy) COFormParameters NSString *reason;

@end
