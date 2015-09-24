//
//  COMessageViewController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/10.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COUser.h"
#import "COBaseViewController.h"

@class COConversation;
@interface COMessageViewController : COBaseViewController

@property (nonatomic, strong) COConversation *conversation;
@property (nonatomic, copy) NSString *globalKey;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

- (void)showMessage:(COConversation *)conversation;
- (void)chatToGlobalKey:(NSString *)globalKey;

@end
