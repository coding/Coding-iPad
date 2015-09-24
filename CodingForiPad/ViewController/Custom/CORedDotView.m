//
//  CORedDotView.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/8/23.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "CORedDotView.h"
#import "UIColor+Hex.h"

@interface CORedDotBGView : UIView

@end

@implementation CORedDotBGView

- (void)drawRect:(CGRect)rect
{
    CGFloat w = CGRectGetWidth(rect);
    CGFloat h = CGRectGetHeight(rect);
    CGFloat margin = 2.0;
    
    // 白底
    CGRect r1 = CGRectMake(0.0, 0.0, w, h);
    UIBezierPath *path1 = [UIBezierPath bezierPathWithRoundedRect:r1 cornerRadius:r1.size.height / 2.0];
    [[UIColor whiteColor] setFill];
    [path1 fill];
    
    // 红底
    CGRect r2 = CGRectInset(rect, margin, margin);
    UIBezierPath *path2 = [UIBezierPath bezierPathWithRoundedRect:r2 cornerRadius:r2.size.height / 2.0];
    [[UIColor colorWithHex:@"#FF4562"] setFill];
    [path2 fill];
}

@end

@interface CORedDotView ()

@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) CORedDotBGView *bgView;

@end

@implementation CORedDotView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
    }
    return self;
}

- (void)awakeFromNib
{
    [self initSubviews];
}

- (void)initSubviews
{
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = NO;
    
    self.bgView = [[CORedDotBGView alloc] initWithFrame:CGRectZero];
    self.bgView.backgroundColor = [UIColor clearColor];
    self.bgView.userInteractionEnabled = NO;
//    self.bgView.layer.borderColor = [UIColor whiteColor].CGColor;
//    self.bgView.layer.borderWidth = 2.0;
//    self.bgView.clipsToBounds = YES;
//    self.bgView.tintColor = [UIColor colorWithHex:@"#FF4562"];
    [self addSubview:_bgView];
    
    self.countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.countLabel.userInteractionEnabled = NO;
    self.countLabel.textAlignment = NSTextAlignmentCenter;
    self.countLabel.textColor = [UIColor whiteColor];
    
    self.countLabel.font = [UIFont systemFontOfSize:12.0];
    [self addSubview:_countLabel];
}

- (void)updateCount:(NSUInteger)count
{
    if (count == 0) {
        self.hidden = YES;
    }
    else {
        self.hidden = NO;
        if (count > 99) {
            self.countLabel.text = @"99+";
        }
        else {
            self.countLabel.text = [NSString stringWithFormat:@"%@", @(count)];
        }
        [self.countLabel sizeToFit];
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat heigth = CGRectGetHeight(self.bounds);
    
    CGRect f = self.countLabel.frame;
    CGFloat lw = CGRectGetWidth(f);
    CGFloat lh = CGRectGetHeight(f);
    f.origin.x = width - 5.0 - lw;
    f.origin.y = (heigth - lh) / 2.0;
    self.countLabel.frame = f;
    
    CGFloat bw = lw + 5.0 * 2;
    CGFloat bh = lh + 4.0 * 2;
    if (bw < bh) {
        bw = bh;
    }
    self.bgView.frame = CGRectMake(f.origin.x - 5.0, f.origin.y - 4.0, bw, bh);
    self.bgView.center = self.countLabel.center;
    [self.bgView setNeedsDisplay];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:[UIColor clearColor]];
}

@end
