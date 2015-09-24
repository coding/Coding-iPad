//
//  COTweetLikeView.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/10.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COTweetLikeView.h"
#import "UIButton+WebCache.h"
#import "COUser.h"
#import "COUtility.h"
#import "UIColor+Hex.h"
#import "COTweetViewController.h"

#define MaxUserCount 10

@interface COTweetLikeView()

@property (nonatomic, strong) NSMutableArray *btns;
@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation COTweetLikeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initBtns];
    }
    return self;
}

- (void)awakeFromNib
{
    [self initBtns];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    self.lineView.frame = CGRectMake(0.0, self.frame.size.height - 1.0, self.frame.size.width, 0.5);
}

- (void)initBtns
{
    CGFloat width = 20.0;
    CGFloat height = 20.0;
    CGFloat margin = 10.0;
    
    self.btns = [NSMutableArray array];
    for (NSInteger i = 0; i < MaxUserCount; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(margin * (i + 1) + i * width, margin, width, height);
        btn.layer.cornerRadius = width / 2.0;
        btn.layer.masksToBounds = YES;
        btn.tag = i;
        btn.hidden = YES;
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        [self.btns addObject:btn];
    }
//    UIView *lineView = [[UIView alloc] initWithFrame:CGRectZero];
//    lineView.backgroundColor = [UIColor colorWithRGB:@"221, 221, 221"];
//    [self addSubview:lineView];
//    self.lineView = lineView;
}

- (void)prepareForReuse
{
    [self hideBtn];
}

- (void)hideBtn
{
    for (UIButton *btn in self.btns) {
        btn.hidden = YES;
    }
}

- (void)assignWithUsers:(NSArray *)users
{
    self.users = users;
    [self hideBtn];
    NSInteger total = [users count] > MaxUserCount ? MaxUserCount : [users count];
    for (NSInteger i = 0; i < total; i ++) {
        UIButton *btn = self.btns[i];
        COUser *user = users[i];
        if ([user.avatar length] > 0) {
            // TODO: 增加placeholder
            [btn sd_setBackgroundImageWithURL:[COUtility urlForImage:user.avatar] forState:UIControlStateNormal placeholderImage:[COUtility placeHolder]];
        }
        else {
            [btn setBackgroundImage:[COUtility placeHolder] forState:UIControlStateNormal];
        }
        btn.hidden = NO;
    }
}

- (IBAction)btnAction:(id)sender
{
    UIButton *btn = sender;
    COUser *user = self.users[btn.tag];
    // TODO: 跳转到用户页
//    NSLog(@"%@", user.globalKey);
    [[NSNotificationCenter defaultCenter] postNotificationName:COTweetUserInfoNotification object:user];
}

@end
