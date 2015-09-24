//
//  COProjectCell.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/10.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COProjectCell.h"
#import "UIImageView+WebCache.h"
#import "UIColor+Hex.h"
#import "COUtility.h"
#import <FBKVOController.h>

@implementation COProjectCell

- (void)awakeFromNib {
    // Initialization code
    _icon.layer.cornerRadius = 2;
    _icon.layer.masksToBounds = TRUE;
    
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = selectedColor;
}

- (void)assignWithProjectSimple:(COProject *)project
{
    self.pinIcon.hidden = project.pin ? NO : YES;
    self.nameLabel.text = project.name;
    
    [self.icon sd_setImageWithURL:[COUtility urlForImage:project.icon] placeholderImage:[COUtility placeHolder]];
    [self observeUnReadCount:project];
}

- (void)assignWithProject:(COProject *)project
{
    self.pinIcon.hidden = project.pin ? FALSE : TRUE;
    self.privateIcon.hidden = project.isPublic ? TRUE : FALSE;
    self.leftLayout.constant = project.isPublic ? 20 : 44;
    self.nameLabel.text = project.name;
    self.ownerLabel.text = project.ownerUserName;
    [self.icon sd_setImageWithURL:[COUtility urlForImage:project.icon] placeholderImage:[COUtility placeHolder]];
    
    [self observeUnReadCount:project];
}

- (void)observeUnReadCount:(COProject *)project
{
    [self.KVOController unobserveAll];
    
    [self.KVOController observe:project keyPath:@"unReadActivitiesCount" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(id observer, COProject *object, NSDictionary *change) {
        [self.countView updateCount:object.unReadActivitiesCount];
    }];
}

+ (CGFloat)cellHeight
{
    return 92;
}

+ (NSArray *)unPinRightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:59/255.0 green:189/255.0 blue:121/255.0 alpha:1] icon:[UIImage imageNamed:@"icon_project_leftview_moreaction_pin"]];
    return rightUtilityButtons;
}

+ (NSArray *)pinedRightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:0xe6/255.0 green:0xe6/255.0 blue:0xe6/255.0 alpha:1] icon:[UIImage imageNamed:@"icon_project_leftview_moreaction_pin"]];
    return rightUtilityButtons;
}

@end
