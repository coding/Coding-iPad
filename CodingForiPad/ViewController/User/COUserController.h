//
//  COUserController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/28.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COBaseViewController.h"
#import "COUser.h"

@interface COUserController : COBaseViewController

@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIView *rightView;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (nonatomic, strong) COUser *user;

- (void)showUserWithGlobalKey:(NSString *)globalKey;
- (void)chageController:(UIViewController *)destination;
- (void)showDetail;

@end
