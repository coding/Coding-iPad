//
// COUser.m
//

#import "COUser.h"

#define NSUINT_BIT (CHAR_BIT * sizeof(NSUInteger))
#define NSUINTROTATE(val, howmuch) ((((NSUInteger)val) << howmuch) | (((NSUInteger)val) >> (NSUINT_BIT - howmuch)))

@implementation COUser

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"followed" : @"followed",
             @"isMember" : @"is_member",
             @"updatedAt" : @"updated_at",
             @"sex" : @"sex",
             @"path" : @"path",
             @"follow" : @"follow",
             @"userId" : @"id",
             @"fansCount" : @"fans_count",
             @"introduction" : @"introduction",
             @"namePinyin" : @"name_pinyin",
             @"location" : @"location",
             @"globalKey" : @"global_key",
             @"email" : @"email",
             @"status" : @"status",
             @"tags" : @"tags",
             @"lavatar" : @"lavatar",
             @"company" : @"company",
             @"lastLoginedAt" : @"last_logined_at",
             @"tweetsCount" : @"tweets_count",
             @"phone" : @"phone",
             @"job" : @"job",
             @"jobStr" : @"job_str",
             @"birthday" : @"birthday",
             @"lastActivityAt" : @"last_activity_at",
             @"tagsStr" : @"tags_str",
             @"followsCount" : @"follows_count",
             @"slogan" : @"slogan",
             @"name" : @"name",
             @"createdAt" : @"created_at",
             @"gravatar" : @"gravatar",
             @"avatar" : @"avatar",
             };
}

- (NSString *)namePinyin
{
    if (!_namePinyin || _namePinyin.length <= 0) {
        if (_name) {
            _namePinyin = [self transformToPinyin:_name];
        }
    }
    if (!_namePinyin) {
        return @"";
    }
    return _namePinyin;
}

- (NSString *)transformToPinyin:(NSString *)txt {
    if (txt.length <= 0) {
        return txt;
    }
    NSMutableString *tempString = [NSMutableString stringWithString:txt];
    CFStringTransform((CFMutableStringRef)tempString, NULL, kCFStringTransformToLatin, false);
    tempString = (NSMutableString *)[tempString stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
    return [tempString uppercaseString];
}

- (BOOL)isEqualToCOUser:(COUser *)user
{
    if (!user) {
        return NO;
    }
    return (self.userId == user.userId) &&
    ((!self.email && !user.email) || [self.email isEqualToString:user.email]) &&
    ((!self.avatar && !user.avatar) || [self.avatar isEqualToString:user.avatar]) &&
    ((self.lastActivityAt - user.lastActivityAt) < 0.000001) &&
    ((self.updatedAt - user.updatedAt) < 0.000001);
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[COUser class]]) {
        return NO;
    }
    return [self isEqualToCOUser:(COUser *)object];
}

- (NSUInteger)hash
{
    return NSUINTROTATE([[NSNumber numberWithInteger:_userId] hash], NSUINT_BIT / 2) ^
    NSUINTROTATE([_email hash], NSUINT_BIT / 4) ^
    NSUINTROTATE([_avatar hash], NSUINT_BIT / 8) ^
    NSUINTROTATE([[NSNumber numberWithDouble:_lastActivityAt] hash], NSUINT_BIT / 16) ^
    NSUINTROTATE([[NSNumber numberWithDouble:_updatedAt] hash], NSUINT_BIT / 32);
}

@end
