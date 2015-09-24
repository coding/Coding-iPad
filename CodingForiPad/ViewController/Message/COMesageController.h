//
//  COMesageController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/14.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COSplitController.h"

@class COConversation;
@interface COMesageController : COSplitController

- (void)showMessage:(COConversation *)conversation;
- (void)pushDetail:(UIViewController *)controller;
- (void)chatToGlobalKey:(NSString *)globalKey;

- (void)showPushNotification:(NSString *)linkStr;

@end
