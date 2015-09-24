//
//  COEmptyView.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/8/4.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COEmptyView.h"
#import <Masonry.h>
#import "UIColor+Hex.h"

@interface COEmptyView ()

@property (nonatomic, copy) COEmptyActionBlock actionBlock;

@end

@implementation COEmptyView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (IBAction)btnAction:(id)sender
{
    if (self.actionBlock) {
        self.actionBlock();
    }
}

- (void)showInView:(UIView *)view
{
    [self showInView:view padding:UIEdgeInsetsZero];
}

- (void)showInView:(UIView *)view padding:(UIEdgeInsets)padding
{
    [view addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view).insets(padding);
    }];
}

+ (BOOL)viewHasEmptyView:(UIView *)view
{
    BOOL result= NO;
    for (UIView *one in view.subviews) {
        if ([one isKindOfClass:[COEmptyView class]]) {
            result = YES;
            break;
        }
    }
    return result;
}

+ (void)removeFormView:(UIView *)view
{
    for (UIView *one in view.subviews) {
        if ([one isKindOfClass:[COEmptyView class]]) {
            [one removeFromSuperview];
            break;
        }
    }
}

+ (COEmptyView *)reloadView:(COEmptyActionBlock)action
{
    COEmptyView *view = [[COEmptyView alloc] init];
    view.actionBlock = action;
    
    UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blankpage_image_loadFail"]];
    [view addSubview:img];
    [img mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view.mas_centerX);
        make.centerY.equalTo(view.mas_centerY).with.offset(-80.0);
    }];
    
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 40.0)];
    tipsLabel.textColor = [UIColor colorWithHex:@"#999999"];
    tipsLabel.text = @"当前环境网络较差\n请重新加载";
    tipsLabel.numberOfLines = 10;
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.font = [UIFont systemFontOfSize:14.0];
    [view addSubview:tipsLabel];
    
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view.mas_centerX);
        make.top.equalTo(img.mas_bottom).with.offset(20.0);
        make.height.equalTo(@(40.0));
    }];
    
    UIButton *reloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [reloadBtn addTarget:view action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [reloadBtn setTitle:@"重新加载" forState:UIControlStateNormal];
    [reloadBtn setBackgroundImage:[UIImage imageNamed:@"background_reload"] forState:UIControlStateNormal];
    [view addSubview:reloadBtn];
    
    [reloadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view.mas_centerX);
        make.top.equalTo(tipsLabel.mas_bottom).with.offset(20.0);
        make.height.equalTo(@(44.0));
        make.width.equalTo(@(120.0));
    }];
    
    return view;
}

/*
 blankpage_image_Hi
 blankpage_image_loadFail
 blankpage_image_Sleep
 */

+ (COEmptyView *)emptyViewWithImage:(UIImage *)image andTips:(NSString *)tips
{
    COEmptyView *view = [[COEmptyView alloc] init];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
    [view addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view.mas_centerX);
        make.centerY.equalTo(view.mas_centerY).with.offset(-80.0);
    }];
    
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 40.0)];
    tipsLabel.text = tips;
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.numberOfLines = 10;
    tipsLabel.textColor = [UIColor colorWithHex:@"#999999"];
    tipsLabel.font = [UIFont systemFontOfSize:14.0];
    [view addSubview:tipsLabel];
    
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view.mas_centerX);
        make.top.equalTo(imgView.mas_bottom).with.offset(20.0);
        make.height.equalTo(@(40.0));
    }];
    
    return view;
}

+ (COEmptyView *)commonEmptyView
{
    return [COEmptyView emptyViewWithImage:[UIImage imageNamed:@"blankpage_image_Sleep"] andTips:@"这里怎么空空的\n发个讨论让它热闹点吧"];
}

+ (COEmptyView *)emptyViewForProject
{
    return [COEmptyView emptyViewWithImage:[UIImage imageNamed:@"blankpage_image_Sleep"] andTips:@"这个人很懒\n一个项目都木有~"];
}

+ (COEmptyView *)emptyViewForTask
{
    return [COEmptyView emptyViewWithImage:[UIImage imageNamed:@"blankpage_image_Sleep"] andTips:@"这里还没有任务\n赶快起来为团队做点贡献吧"];
}

+ (COEmptyView *)emptyViewForJoinedProject
{
    return [COEmptyView emptyViewWithImage:[UIImage imageNamed:@"blankpage_image_Sleep"] andTips:@"还没有参与项目\n赶快去参与一个项目吧~"];
}

+ (COEmptyView *)emptyViewForCreateProject:(COEmptyActionBlock)action
{
    COEmptyView *view = [[COEmptyView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    view.actionBlock = action;
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blankpage_image_Sleep"]];
    [view addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view.mas_centerX);
        make.centerY.equalTo(view.mas_centerY).with.offset(-180.0);
    }];
    
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 40.0)];
    tipsLabel.text = @"这里还没有任务\n赶快起来为团队做点贡献吧";
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.numberOfLines = 10;
    tipsLabel.textColor = [UIColor colorWithHex:@"#999999"];
    tipsLabel.font = [UIFont systemFontOfSize:14.0];
    [view addSubview:tipsLabel];
    
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view.mas_centerX);
        make.top.equalTo(imgView.mas_bottom).with.offset(20.0);
        make.height.equalTo(@(40.0));
    }];
    
    UIButton *createBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [createBtn addTarget:view action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [createBtn setBackgroundImage:[UIImage imageNamed:@"icon_add_project"] forState:UIControlStateNormal];
    [view addSubview:createBtn];
    
    [createBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view.mas_centerX);
        make.centerY.equalTo(view.mas_centerY).with.offset(-30.0);
        make.height.equalTo(@(40.0));
        make.width.equalTo(@(120.0));
    }];
    
    if (action == nil) {
        createBtn.hidden = YES;
    }
    
//    UILabel *btnLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 20.0)];
//    btnLabel.text = @"创建项目";
//    btnLabel.textAlignment = NSTextAlignmentCenter;
//    btnLabel.textColor = [UIColor colorWithHex:@"#999999"];
//    btnLabel.font = [UIFont systemFontOfSize:14.0];
//    [view addSubview:btnLabel];
//    
//    [btnLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(view.mas_centerX);
//        make.top.equalTo(createBtn.mas_bottom).with.offset(20.0);
//    }];
    
    return view;
}

@end
