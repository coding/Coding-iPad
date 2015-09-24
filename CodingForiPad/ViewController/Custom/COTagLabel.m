//
//  WMDelLabel.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/22.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COTagLabel.h"
#import "COTopic.h"
#import "UIColor+Hex.h"

@implementation COTagLabel

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    self.font = [UIFont boldSystemFontOfSize:12];
    self.textAlignment = NSTextAlignmentCenter;
    self.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    
    self.textColor = [UIColor whiteColor];
    self.layer.backgroundColor = [UIColor greenColor].CGColor;
    self.layer.cornerRadius = self.frame.size.height * 0.5f;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.layer.cornerRadius = self.frame.size.height * 0.5f;
}

- (void)setBackgroundColor:(UIColor *)color
{
    // do nothing - background color never changes
}

- (void)setLabels:(COTopicLabel *)labels
{
    if (labels) {
        self.text = labels.name;
        UIColor *color = [UIColor colorWithHex:labels.color];
        self.layer.backgroundColor = color.CGColor;
        self.textColor = [UIColor whiteColor];
        CGFloat redValue, greenValue, blueValue, alphaValue;
        if ([color getRed:&redValue green:&greenValue blue:&blueValue alpha:&alphaValue]) {
            if (redValue > 0.6 && greenValue > 0.6 && blueValue > 0.6) {
                self.textColor = [UIColor blackColor];
                if (redValue == 1.0 && greenValue == 1.0 && blueValue == 1.0) {
                    self.layer.backgroundColor = [UIColor clearColor].CGColor;
                }
            }
        }
        self.hidden = FALSE;
        [self sizeToFit];
        for (NSLayoutConstraint *con in self.constraints) {
            if (con.firstAttribute == NSLayoutAttributeWidth) {
                con.constant = self.frame.size.width + 5 + 5;
            }
        }
    } else {
        self.text = @"";
        
        self.hidden = TRUE;
        for (NSLayoutConstraint *con in self.constraints) {
            if (con.firstAttribute == NSLayoutAttributeWidth) {
                con.constant = 0;
            }
        }
    }
}

@end
