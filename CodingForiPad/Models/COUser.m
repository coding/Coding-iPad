//
// COUser.m
//

#import "COUser.h"

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

@end
