//
//  UIColor+Hex.m
//
//  Created by sunguanglei on 15/5/19.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

+ (UIColor *)colorWithHex:(NSString *)hex alpha:(CGFloat)alpha
{
    NSAssert(7 == hex.length, @"Hex color format error!");
    
    unsigned color = 0;
    NSScanner *hexValueScanner = [NSScanner scannerWithString:[hex substringFromIndex:1]];
    [hexValueScanner scanHexInt:&color];

    int blue = color & 0xFF;
    int green = (color >> 8) & 0xFF;
    int red = (color >> 16) & 0xFF;
        
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
}

+ (UIColor *)colorWithHex:(NSString *)hex
{
    return [[self class] colorWithHex:hex alpha:1.0];
}

+ (UIColor *)colorWithRGB:(NSString *)rgb alpha:(CGFloat)alpha
{
    NSArray *components = [rgb componentsSeparatedByString:@","];
    NSAssert(3 == components.count, @"RGB(255,255,255) formamt error.");
    CGFloat red = [components[0] floatValue];
    CGFloat green = [components[1] floatValue];
    CGFloat blue = [components[2] floatValue];
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
}

+ (UIColor *)colorWithRGB:(NSString *)rgb
{
    return [UIColor colorWithRGB:rgb alpha:1.0];
}

+ (UIColor *)colorWithRGBHex:(UInt32)hex  alpha:(CGFloat)alpha{
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:alpha];
}

// Returns a UIColor by scanning the string for a hex number and passing that to +[UIColor colorWithRGBHex:]
// Skips any leading whitespace and ignores any trailing characters
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert {
    return [UIColor colorWithHexString:stringToConvert andAlpha:1.0];
}

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert andAlpha:(CGFloat)alpha{
    NSScanner *scanner = [NSScanner scannerWithString:stringToConvert];
    unsigned hexNum;
    if (![scanner scanHexInt:&hexNum]) return nil;
    return [UIColor colorWithRGBHex:hexNum alpha:1.0];
}

@end
