//
//  COUtility.m
//  CodingModels
//
//  Created by sunguanglei on 15/6/1.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COUtility.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSString+Common.h"
#import "NSDate+Common.h"

@implementation COUtility

+ (NSString*)sha1:(NSString *)instr
{
    const char *cstr = [instr cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:instr.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

+ (NSURL *)urlForImage:(NSString *)imageUrl
{
    return [imageUrl urlImageWithCodePathResize:100.0 crop:NO];
}

+ (NSURL *)urlForImage:(NSString *)imageUrl withWidth:(CGFloat)width
{
    return [imageUrl urlImageWithCodePathResize:width crop:NO];
}

+ (NSURL *)urlForImage:(NSString *)imageUrl resizeToView:(UIView *)view
{
    return [imageUrl urlImageWithCodePathResize:2*CGRectGetWidth(view.frame)];
}

+ (NSString *)YYYYMMDDToMMDD:(NSString *)deadline
{
    if (deadline && deadline.length > 0) {
        NSArray *date = [deadline componentsSeparatedByString:@"-"];
        return [NSString stringWithFormat:@"%@月%@日", date[1], date[2]];
    }
    return @"未指定";
}

+ (NSString *)YYYYMMDDToMD:(NSString *)deadline
{
    if (deadline && deadline.length > 0) {
        NSArray *date = [deadline componentsSeparatedByString:@"-"];
        return [NSString stringWithFormat:@"%@/%@", date[1], date[2]];
    }
    return @"未指定";
}

+ (NSString *)timestampToDay:(NSTimeInterval)timestamp
{
    NSDate *formattedDate = [NSDate dateWithTimeIntervalSince1970:timestamp / 1000];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy-MM-dd"];
    
    return [outputFormatter stringFromDate:formattedDate];
}

+ (NSString *)timestampToDayWithWeek:(NSTimeInterval)timestamp
{
    NSDate *formattedDate = [NSDate dateWithTimeIntervalSince1970:timestamp / 1000];
    return [formattedDate string_yyyy_MM_dd_EEE];
}

+ (NSString *)timestampToBefore:(NSTimeInterval)timestamp
{
    if (timestamp == 0.0) {
        return @"--";
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp / 1000];
    return [date stringTimesAgo];
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    
//    NSDate *currentDate = [NSDate date];
//    NSDateComponents* today = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:currentDate];
//    
//    NSDate *targetDate = [NSDate dateWithTimeIntervalSince1970:timestamp / 1000];
//    NSDateComponents* target = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:targetDate];
//    
//    [today day];
//    [today year];
//    
//    NSInteger year = [today year] - [target year];
//    NSInteger month = [today month] - [target month];
//    NSInteger day = [today day] - [target day];
//    
//    if (year > 0) {
//        return [NSString stringWithFormat:@"%ld年前", (long)year];
//    }
//    
//    if (month > 0) {
//        return [NSString stringWithFormat:@"%ld月前", (long)month];
//    }
//    
//    if (day > 0) {
//        return [NSString stringWithFormat:@"%ld天前", (long)day];
//    }
//    
//    return @"今天";
}

+ (NSString *)timestampToA_HH_MM:(NSTimeInterval)timestamp
{
    NSDate *formattedDate = [NSDate dateWithTimeIntervalSince1970:timestamp / 1000];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"HH:mm"];
    
    NSString *dateString = [outputFormatter stringFromDate:formattedDate];
    NSInteger hour = [[dateString substringToIndex:2] integerValue];
    NSString *aStr = nil;
    if (hour < 3) {
        aStr = @"凌晨";
    }else if (hour >= 3 && hour < 12){
        aStr = @"上午";
    }else if (hour >= 12 && hour < 13){
        aStr = @"中午";
    }else if (hour >= 13 && hour < 18){
        aStr = @"下午";
    }else{
        aStr = @"晚上";
    }
    return [NSString stringWithFormat:@"%@ %@", aStr, dateString];
}

+ (NSDate *)dateFromYY_MM_DD:(NSString *)dateString
{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy-MM-dd"];
    
    return [outputFormatter dateFromString:dateString];
}

+ (NSString *)timestampToDay_A_HH_MM:(NSTimeInterval)timestamp
{
    NSDate *formattedDate = [NSDate dateWithTimeIntervalSince1970:timestamp / 1000];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"HH:mm"];
    
    NSString *dateString = [outputFormatter stringFromDate:formattedDate];
    NSInteger hour = [[dateString substringToIndex:2] integerValue];
    NSString *aStr = nil;
    if (hour < 3) {
        aStr = @"凌晨";
    }else if (hour >= 3 && hour < 12){
        aStr = @"上午";
    }else if (hour >= 12 && hour < 13){
        aStr = @"中午";
    }else if (hour >= 13 && hour < 18){
        aStr = @"下午";
    }else{
        aStr = @"晚上";
    }
    
    NSDate *currentDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *today = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:currentDate];
    NSDateComponents *target = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:formattedDate];
    
    NSInteger year = [today year] - [target year];
    NSInteger month = [today month] - [target month];
    NSInteger day = [today day] - [target day];
    
    if (year==0 && month==0 && day==0) {
        return [NSString stringWithFormat:@"今天 %@ %@", aStr, dateString];
    } else if (year==0 && month==0 && day==1) {
        return [NSString stringWithFormat:@"昨天 %@ %@", aStr, dateString];
    }
    
    return [NSString stringWithFormat:@"%02ld-%02ld %@ %@", (long)[target month], (long)[target day], aStr, dateString];
}


+ (UIImage *)placeHolder
{
    // TODO: 适配不同大小
    return [UIImage imageNamed:@"placeholder_monkey_round_50"];
}

+ (CGFloat)getKeyboardHeight:(NSNotification *)paramNotification
                    andCurve:(void *)curve
                 andDuration:(void *)duration
{
    NSDictionary *userInfo = [paramNotification userInfo];
    NSValue *animationCurveObject = [userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey];
    NSValue *animationDurationObject = [userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSValue *keyboardEndRectObject = [userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardEndRect = CGRectMake(0, 0, 0, 0);
    [animationCurveObject getValue:curve];
    [animationDurationObject getValue:duration];
    [keyboardEndRectObject getValue:&keyboardEndRect];
    return isIOS8_or_Later ? keyboardEndRect.size.height : isLandscape ? keyboardEndRect.size.width : keyboardEndRect.size.height;
}

+ (void)hideKeyboardInfo:(NSNotification *)paramNotification
                andCurve:(void *)curve
             andDuration:(void *)duration
{
    NSDictionary *userInfo = [paramNotification userInfo];
    NSValue *animationCurveObject = [userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey];
    NSValue *animationDurationObject = [userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    [animationCurveObject getValue:curve];
    [animationDurationObject getValue:duration];
}

@end
