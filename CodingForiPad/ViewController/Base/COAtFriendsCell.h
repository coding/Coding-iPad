//
//  COAtFriendsCell.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/8.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@class COUser;
@class COProjectMember;
@interface COAtFriendsCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *icon;

- (void)assignWithUser:(COUser *)user;

- (void)assignWithMember:(COProjectMember *)member;

@end
