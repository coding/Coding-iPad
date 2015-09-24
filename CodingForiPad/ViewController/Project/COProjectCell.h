//
//  COProjectCell.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/10.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COProject.h"
#import "SWTableViewCell.h"
#import "CORedDotView.h"

@interface COProjectCell : SWTableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *icon;
@property (nonatomic, weak) IBOutlet UIImageView *pinIcon;
@property (nonatomic, weak) IBOutlet UIImageView *privateIcon;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *ownerLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftLayout;
@property (weak, nonatomic) IBOutlet CORedDotView *countView;

- (void)assignWithProject:(COProject *)project;
- (void)assignWithProjectSimple:(COProject *)project;

+ (CGFloat)cellHeight;
+ (NSArray *)unPinRightButtons;
+ (NSArray *)pinedRightButtons;

@end
