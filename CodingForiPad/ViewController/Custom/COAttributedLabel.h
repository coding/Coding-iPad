//
//  UITTTAttributedLabel.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-8.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <TTTAttributedLabel.h>
#import "UIColor+Hex.h"

#define kLinkAttributes     @{(__bridge NSString *)kCTUnderlineStyleAttributeName : [NSNumber numberWithBool:NO],(NSString *)kCTForegroundColorAttributeName : (__bridge id)[UIColor colorWithHex:@"#3bbd79"].CGColor}
#define kLinkAttributesActive       @{(NSString *)kCTUnderlineStyleAttributeName : [NSNumber numberWithBool:NO],(NSString *)kCTForegroundColorAttributeName : (__bridge id)[[UIColor colorWithHex:@"#1b9d59"] CGColor]}

typedef void(^COAttributedLabelTapBlock)(id aObj);

@interface COAttributedLabel : TTTAttributedLabel
-(void)addLongPressForCopy;
-(void)addLongPressForCopyWithBGColor:(UIColor *)color;
-(void)addTapBlock:(COAttributedLabelTapBlock)block;
-(void)addDeleteBlock:(COAttributedLabelTapBlock)block;

+ (COAttributedLabel *)defalutLabel;
+ (COAttributedLabel *)labelForTweetComment;
+ (COAttributedLabel *)labelForTweetContent;

- (void)configForTweetContent;
- (void)configForTweetComment;

@end
