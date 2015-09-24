//
//  UIViewController+Link.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/8/21.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    COLinkShowTypePush,
    COLinkShowTypeRight,
    COLinkShowTypeModel,
    COLinkShowTypeWeb,
    COLinkShowTypeUnSupport,
} COLinkShowType;

typedef void(^COLinkShowBlock)(UIViewController *controller, COLinkShowType showType, NSString *link);

@interface UIViewController (Link)

- (BOOL)analyseVCFromLinkStr:(NSString *)linkStr showBlock:(COLinkShowBlock)showBlock;

@end
