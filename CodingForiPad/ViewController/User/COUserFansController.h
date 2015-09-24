//
//  COUserFansController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/28.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COBaseViewController.h"

@interface COUserFansController : COBaseViewController

@property (nonatomic, copy) NSString *globayKey;
/**
 *  0 粉丝
 *  1 关注
 */
@property (nonatomic, assign) NSInteger type;

@end
