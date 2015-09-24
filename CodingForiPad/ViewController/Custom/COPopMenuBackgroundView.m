//
//  COPopoverBackgroundView.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/22.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COPopMenuBackgroundView.h"

@interface COPopMenuBackgroundView()

@property (nonatomic, strong) UIImageView *arrowImageView;

- (UIImage *)drawArrowImage:(CGSize)size;

@end

@implementation COPopMenuBackgroundView

@synthesize arrowDirection  = _arrowDirection;
@synthesize arrowOffset     = _arrowOffset;

#pragma mark - Graphics Methods
- (UIImage *)drawArrowImage:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor clearColor] setFill];
    CGContextFillRect(ctx, CGRectMake(0.0f, 0.0f, size.width, size.height));
    
    CGMutablePathRef arrowPath = CGPathCreateMutable();
    CGPathMoveToPoint(arrowPath, NULL, (size.width/2.0f), 0.0f);    //Top Center
    CGPathAddLineToPoint(arrowPath, NULL, size.width, size.height); //Bottom Right
    CGPathAddLineToPoint(arrowPath, NULL, 0.0f, size.height);       //Bottom Right
    CGPathCloseSubpath(arrowPath);
    CGContextAddPath(ctx, arrowPath);
    CGPathRelease(arrowPath);
    
    UIColor *fillColor = [UIColor whiteColor];// [UIColor colorWithRed:38/255.0 green:48/255.0 blue:59/255.0 alpha:1.0];
    CGContextSetFillColorWithColor(ctx, fillColor.CGColor);
    CGContextDrawPath(ctx, kCGPathFill);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - UIPopoverBackgroundView Overrides
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.arrowImageView = arrowImageView;
        [self addSubview:self.arrowImageView];
    }
    return self;
}

+ (CGFloat)arrowBase
{
    return 28;
}

+ (CGFloat)arrowHeight
{
    return 8;
}

+ (UIEdgeInsets)contentViewInsets
{
    return UIEdgeInsetsMake(16, 0, 0, 0);
}

+ (BOOL)wantsDefaultContentAppearance
{
    return NO;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    // 控制阴影
    self.layer.shadowOpacity = 0.3f;
    self.layer.shadowRadius = 6;
    self.layer.cornerRadius = 4;
    self.layer.shadowOffset = CGSizeMake(0, 4);
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    CGRect bounds = self.bounds;
    bounds.size.height -= 16.0;
    bounds.origin.y = 16.0;
    [self.layer setShadowPath:[UIBezierPath bezierPathWithRect:bounds].CGPath];
    CGSize arrowSize = CGSizeMake([[self class] arrowBase], [[self class] arrowHeight]);
    self.arrowImageView.image = [self drawArrowImage:arrowSize];
    
    self.arrowImageView.frame = CGRectMake((self.bounds.size.width - arrowSize.width) - 8.0f, 16.0f, arrowSize.width, arrowSize.height);
}

@end
