//
//  COProjectBtn.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/22.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COProjectBtn.h"

@implementation COProjectBtn

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initUI];
    }
    return self;
}

- (void)awakeFromNib
{
    [self initUI];
}

- (void)initUI
{
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return CGRectMake((self.frame.size.width - 50) * 0.5f, (self.frame.size.height - 74) * 0.5f, 50, 50);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat y = (self.frame.size.height - 74) * 0.5f + 60;
    return CGRectMake(0, y, self.frame.size.width, 17);
}

@end
