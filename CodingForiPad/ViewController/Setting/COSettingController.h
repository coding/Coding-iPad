//
//  COSettingController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/5/19.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface COSettingController : UIViewController

@property (nonatomic, weak) IBOutlet UIView *leftView;
@property (nonatomic, weak) IBOutlet UIView *rightView;
@property (nonatomic, weak) UINavigationController *rightRoot;

- (void)showFeedback;
- (void)showAbout;

@end
