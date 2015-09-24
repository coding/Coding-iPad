//
//  COMemberCell.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/26.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COProject.h"

@interface COMemberCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *ownerIcon;
@property (weak, nonatomic) IBOutlet UIButton *actioBtn;

- (void)assignWithMember:(COProjectMember *)member;

@end
