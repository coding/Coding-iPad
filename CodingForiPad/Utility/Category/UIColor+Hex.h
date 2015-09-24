//
//  UIColor+Hex.h
//
//  Created by sunguanglei on 15/5/19.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)

/**
 *  Create color withe hex format
 *
 *  @param hex   hex format color eg.#333333
 *  @param alpha color alpha 0.0~1.0
 *
 *  @return UIColor
 */
+ (UIColor *)colorWithHex:(NSString *)hex alpha:(CGFloat)alpha;


/**
 *  Create color withe hex format
 *
 *  @param hex   hex format color eg.#333333
 *  @param alpha color alpha 0.0~1.0
 *
 *  @return UIColor
 */
+ (UIColor *)colorWithHex:(NSString *)hex;

/**
 *  Create color with RGB format
 *
 *  @param RGB   hex format color eg. 255,255,255
 *  @param alpha color alpha 0.0~1.0
 *
 *  @return UIColor
 */
+ (UIColor *)colorWithRGB:(NSString *)rgb alpha:(CGFloat)alpha;

/**
 *  Create color with RGB format
 *
 *  @param RGB   hex format color eg. 255,255,255
 *
 *  @return UIColor
 */
+ (UIColor *)colorWithRGB:(NSString *)rgb;

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert andAlpha:(CGFloat)alpha;

@end
