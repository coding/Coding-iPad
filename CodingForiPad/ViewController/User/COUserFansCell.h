//
//  COUserFansCell.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/28.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@class COUser;
@interface COUserFansCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *icon;
// 已关注按钮，点击后取消关注，已关注按钮应该有两种状态，互相关注和已关注
@property (nonatomic, weak) IBOutlet UIButton *watchBtn;
@property (nonatomic, weak) IBOutlet UIButton *unWatchBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@property (strong, nonatomic) COUser *curUser;
@property (nonatomic, copy) void(^btnBlock)(COUser *curUser);
@property (nonatomic, copy) void(^avatarBlock)(COUser *curUser);

- (void)setUser:(COUser *)user isQuerying:(BOOL)isQuerying;

@end
