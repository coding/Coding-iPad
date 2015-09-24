//
//  COUtility.h
//  CodingModels
//
//  Created by sunguanglei on 15/6/1.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface COUtility : NSObject

/**
 *  sha1 hash 算法
 *
 *  @param instr 输入字符串
 *
 *  @return sha1
 */
+ (NSString*)sha1:(NSString *)instr;

+ (NSURL *)urlForImage:(NSString *)imageUrl;
+ (NSURL *)urlForImage:(NSString *)imageUrl withWidth:(CGFloat)width;
+ (NSURL *)urlForImage:(NSString *)imageUrl resizeToView:(UIView *)view;

+ (NSString *)timestampToDay:(NSTimeInterval)timestamp;

+ (NSString *)timestampToDayWithWeek:(NSTimeInterval)timestamp;

+ (NSString *)timestampToBefore:(NSTimeInterval)timestamp;

+ (NSString *)timestampToA_HH_MM:(NSTimeInterval)timestamp;

+ (NSString *)timestampToDay_A_HH_MM:(NSTimeInterval)timestamp;

+ (NSString *)YYYYMMDDToMMDD:(NSString *)deadline;
+ (NSString *)YYYYMMDDToMD:(NSString *)deadline;

+ (NSDate *)dateFromYY_MM_DD:(NSString *)dateString;

+ (UIImage *)placeHolder;

+ (CGFloat)getKeyboardHeight:(NSNotification *)paramNotification
                    andCurve:(void *)curve
                 andDuration:(void *)duration;
+ (void)hideKeyboardInfo:(NSNotification *)paramNotification
                andCurve:(void *)curve
             andDuration:(void *)duration;
@end
