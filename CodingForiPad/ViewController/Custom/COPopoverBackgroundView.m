//
//  COPopoverBackgroundView.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/22.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COPopoverBackgroundView.h"

@implementation COPopoverBackgroundView

@synthesize arrowDirection  = _arrowDirection;
@synthesize arrowOffset     = _arrowOffset;

#pragma mark - UIPopoverBackgroundView Overrides
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

+ (CGFloat)arrowBase
{
    return 0;
}

+ (CGFloat)arrowHeight
{
    return 0;
}

+ (UIEdgeInsets)contentViewInsets
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

+ (BOOL)wantsDefaultContentAppearance
{
    return NO;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    // 控制阴影
    self.layer.shadowOpacity = 0.5f;
    self.layer.shadowRadius = 4;
    self.layer.cornerRadius = 4;
    self.layer.shadowOffset = CGSizeMake(1, 3);
    self.layer.shadowColor = [UIColor blackColor].CGColor;
}

@end
