//
//  COEmptyView.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/8/4.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^COEmptyActionBlock)(void);
@interface COEmptyView : UIView

- (void)showInView:(UIView *)view;
- (void)showInView:(UIView *)view padding:(UIEdgeInsets)padding;

+ (BOOL)viewHasEmptyView:(UIView *)view;

+ (void)removeFormView:(UIView *)view;

+ (COEmptyView *)reloadView:(COEmptyActionBlock)action;
+ (COEmptyView *)emptyViewWithImage:(UIImage *)image andTips:(NSString *)tips;

+ (COEmptyView *)commonEmptyView;
+ (COEmptyView *)emptyViewForProject;
+ (COEmptyView *)emptyViewForTask;

+ (COEmptyView *)emptyViewForJoinedProject;

+ (COEmptyView *)emptyViewForCreateProject:(COEmptyActionBlock)action;

@end
