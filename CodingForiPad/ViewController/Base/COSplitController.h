//
//  COSplitController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/28.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface COSplitController : UIViewController

@property (nonatomic, weak) IBOutlet UIView *leftView;
@property (nonatomic, weak) IBOutlet UIView *rightView;

- (void)showInRightView:(UIViewController *)vc sender:(id)sender;

@end
