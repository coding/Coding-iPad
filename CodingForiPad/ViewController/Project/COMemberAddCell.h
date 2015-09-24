//
//  COMemberAddCell.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/24.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@class COUser;
@interface COMemberAddCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@property (strong, nonatomic) COUser *curUser;
@property (nonatomic, copy) void(^btnBlock)(COUser *curUser);

- (void)setUser:(COUser *)user isInProject:(BOOL)isInProject isQuerying:(BOOL)isQuerying;

@end
