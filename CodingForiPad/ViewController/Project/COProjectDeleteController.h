//
//  COProjectDeleteController.h
//  CodingForiPad
//
//  Created by sgl on 15/7/9.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COBaseViewController.h"
#import "COProject.h"

@interface COProjectDeleteController : COBaseViewController<UITextFieldDelegate>

@property (nonatomic, strong) COProject *project;

@end
