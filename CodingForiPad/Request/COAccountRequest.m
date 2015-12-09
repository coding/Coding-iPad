//
//  COAccountRequest.m
//  CodingModels
//
//  Created by sunguanglei on 15/5/19.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#define kRegisterChannel @"coding-ipad"

#import "COAccountRequest.h"

@implementation COAccountCheckRequest

- (void)prepareForRequest
{
    self.path = @"/account/check";
}
- (NSDictionary *)parametersMap
{
    return @{
             @"key" : @"key",
             };
}

@end

@implementation COAccountRegisterRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        _channel = kRegisterChannel;
    }
    return self;
}

- (void)prepareForRequest
{
    self.path = @"/account/register";
}
- (NSDictionary *)parametersMap
{
    return @{
             @"email" : @"email",
             @"globalKey" : @"global_key",
             @"jCaptcha" : @"j_captcha",
             @"channel" : @"channel",
             };
}

- (CODataResponse *)postResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COUser class] responseType:CODataResponseTypeDefault];
}

@end

@implementation COAccountLoginRequest

- (void)prepareForRequest
{
    self.path = @"/login";
}
- (NSDictionary *)parametersMap
{
    return @{
             @"email" : @"email",
             @"password" : @"password",
             @"rememberMe" : @"remember_me",
             @"jCaptcha" : @"j_captcha",
             };
}

- (CODataResponse *)postResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COUser class] responseType:CODataResponseTypeDefault];
}

@end

@implementation COAccountLogoutRequest

- (void)prepareForRequest
{
    self.path = @"/account/logout";
}


@end

@implementation COAccountCaptchaRequest

- (void)prepareForRequest
{
    // TODO: uriParameters
    self.path = [NSString stringWithFormat:@"/account/captcha/%@", self.action];
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response];
}

@end

@implementation COAccountActivateRequest

- (void)prepareForRequest
{
    self.path = @"/account/activate";
}
- (NSDictionary *)parametersMap
{
    return @{
             @"email" : @"email",
             @"jCaptcha" : @"j_captcha",
             @"key" : @"key",
             @"password" : @"password",
             @"comfirmPassword" : @"comfirm_password",
             };
}

@end

@implementation COAccountResetPasswordRequest

- (void)prepareForRequest
{
    self.path = @"/account/reset_password";
}
- (NSDictionary *)parametersMap
{
    return @{
             @"jCaptcha" : @"j_captcha",
             @"email" : @"email",
             @"key" : @"key",
             @"password" : @"password",
             @"comfirmPassword" : @"comfirm_password",
             };
}

@end

@implementation COAccountInviteRequest

- (void)prepareForRequest
{
    self.path = @"/account/invite";
}
- (NSDictionary *)parametersMap
{
    return @{
             @"key" : @"key",
             @"email" : @"email",
             @"content" : @"content",
             };
}

@end

@implementation COAccountInviteRegisterRequest

- (void)prepareForRequest
{
    self.path = @"/account/invite/register";
}
- (NSDictionary *)parametersMap
{
    return @{
             @"key" : @"key",
             @"email" : @"email",
             @"userName" : @"user_name",
             @"jCaptcha" : @"j_captcha",
             };
}

@end

@implementation COAccountNameRequest

- (void)prepareForRequest
{
    // TODO: uriParameters
    self.path = @"/account/name/{username}";
}


@end

@implementation COAccountNameNoCacheRequest

- (void)prepareForRequest
{
    self.path = @"/account/name/{username}/no_cache";
}


@end

@implementation COAccountCurrentUserRequest

- (void)prepareForRequest
{
    self.path = @"/account/current_user";
}


@end

@implementation COAccountAvatarRequest

- (void)prepareForRequest
{
    self.path = @"/account/avatar";
}


@end

@implementation COAccountSearchRequest

- (void)prepareForRequest
{
    self.path = @"/account/search";
}
- (NSDictionary *)parametersMap
{
    return @{
             @"key" : @"key",
             };
}

@end

@implementation COAccountUpdateInfoRequest

- (void)assignWithUser:(COUser *)user
{
    self.email = user.email;
    self.avatar = user.avatar;
    self.name = user.name;
    self.sex = @(user.sex);
    self.phone = user.phone;
    self.birthday = user.birthday;
    self.company = user.company;
    self.job = @(user.job);
    self.tags = user.tags;
    
    self.globalKey = user.globalKey;
    self.userID = @(user.userId);
    self.location = user.location;
    self.slogan = user.slogan;
}

- (void)prepareForRequest
{
    self.path = @"/user/updateInfo";
}

- (NSDictionary *)parametersMap
{
    return @{@"userID" : @"id",
             @"globalKey" : @"global_key",
             @"avatar" : @"lavatar",////
             @"location" : @"location",
             @"slogan" : @"slogan",

             @"email" : @"email",
             //@"avatar" : @"avatar",
             @"name" : @"name",
             @"sex" : @"sex",
             @"phone" : @"phone",
             @"birthday" : @"birthday",
             @"company" : @"company",
             @"job" : @"job",
             @"tags" : @"tags",
             };
}

@end

@implementation COAccountUpdateAvatarRequest

- (void)prepareForRequest
{
    self.path = @"/user/avatar?update=1";
}

@end

@implementation COAccountUserInfoRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/user/key/%@", self.globalKey];
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COUser class] responseType:CODataResponseTypeDefault];
}

@end

@implementation COAccountGetNoticeSettingsRequest

- (void)prepareForRequest
{
    self.path = @"/account/get_notice_settings";
}


@end

@implementation COAccountChangeNoticeSettingRequest

- (void)prepareForRequest
{
    self.path = @"/account/change_notice_setting";
}
- (NSDictionary *)parametersMap
{
    return @{
             @"settingType" : @"settingType",
             @"settingContent" : @"settingContent",
             };
}

@end

@implementation COAccountUpdatePwdRequest

- (void)prepareForRequest
{
    self.path = @"/user/updatePassword";
}

- (NSDictionary *)parametersMap
{
    return @{
             @"currentPassword" : @"current_password",
             @"password" : @"password",
             @"confirmPassword" : @"confirm_password",
             };
}

@end

@implementation COAccountProjectsPinRequest

- (void)prepareForRequest
{
    self.path = @"/user/projects/pin";
}
- (NSDictionary *)parametersMap
{
    return @{
             @"ids" : @"ids",
             };
}

@end

@implementation COAccountActivitiesLastRequest

- (void)prepareForRequest
{
    self.path = @"/account/activities/last";
}
- (NSDictionary *)parametersMap
{
    return @{
             @"lastId" : @"last_id",
             };
}

@end

@implementation COAccountActivitiesRequest

- (void)prepareForRequest
{
    self.path = @"/account/activities/{id}";
}

@end

@implementation COAccountWallpapers

- (void)prepareForRequest
{
    self.path = @"/wallpaper/wallpapers";
}

- (NSDictionary *)parametersMap
{
    return @{@"type" : @"type"};
}

@end


@implementation COUserJobArrayRequest

- (void)prepareForRequest
{
    self.path = @"/options/jobs";
}

@end

@implementation COUserTagArrayRequest

- (void)prepareForRequest
{
    self.path = @"/tagging/user_tag_list";
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COTag class] responseType:CODataResponseTypeList];
}

@end

@implementation COUserUpdateInfoRequest

- (void)prepareForRequest
{
    self.path = @"/user/updateInfo";
}

- (NSDictionary *)parametersMap
{
    return @{@"id" : @"id",
             @"email" : @"email",
             @"globalKey" : @"global_key",
             @"lavatar" : @"lavatar",
             @"name" : @"name",
             @"sex" : @"sex",
             @"birthday" : @"birthday",
             @"location" : @"location",
             @"slogan" : @"slogan",
             @"company" : @"company",
             @"job" : @"job",
             @"tags" : @"tags"};
}

- (CODataResponse *)postResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COUser class] responseType:CODataResponseTypeDefault];
}

@end

@implementation COUserSearch

- (void)prepareForRequest
{
    self.path = @"/user/search";
}

- (NSDictionary *)parametersMap
{
    return @{@"key" : @"key"};
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COUser class] responseType:CODataResponseTypeList];
}

@end

@implementation COFollowedOrNot

- (void)prepareForRequest
{
    self.path = _isFollowed ? @"/user/unfollow" : @"/user/follow";
}

- (NSDictionary *)parametersMap
{
    return @{@"users" : @"users"};
}

@end

@implementation COMarkReadRequest

- (void)prepareForRequest
{
    self.path = @"/notification/mark-read";
}

- (NSDictionary *)parametersMap
{
    return @{@"notificationId" : @"id"};
}

@end

@implementation COConversationReadRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/message/conversations/%@/read", self.globalKey];
}

@end

@implementation COUnreadCountRequest

- (void)prepareForRequest
{
    self.path = @"/user/unread-count";
}

@end

@implementation COAccountAuthCodeRequest

- (void)prepareForRequest
{
    self.path = @"/check_two_factor_auth_code";
}

- (NSDictionary *)parametersMap
{
    return @{@"authCode" : @"code"};
}

- (CODataResponse *)postResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COUser class] responseType:CODataResponseTypeDefault];
}

@end

@implementation COAccountResetPasswordMailRequest

- (void)prepareForRequest
{
    self.path = @"/resetPassword";
}

- (NSDictionary *)parametersMap
{
    return @{@"email" : @"email",
             @"jCaptcha" : @"j_captcha"};
}

@end

@implementation COAccountResendActiveMailRequest

- (void)prepareForRequest
{
    self.path = @"/activate";
}

- (NSDictionary *)parametersMap
{
    return @{@"email" : @"email",
             @"jCaptcha" : @"j_captcha"};
}

@end

@implementation COReportIllegalContentRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/inform/%@", self.type];
}

- (NSDictionary *)parametersMap
{
    return @{@"user": @"user",
             @"content" : @"content",
             @"reason" : @"reason"};
}

@end
