//
//  COWebViewController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/8/19.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COBaseViewController.h"
#import "SVWebViewController.h"

@interface COWebViewController : SVWebViewController

+ (instancetype)webVCWithUrlStr:(NSString *)curUrlStr;

@end
