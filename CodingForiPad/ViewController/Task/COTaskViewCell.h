//
//  COTaskViewHeadCell.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/10.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COPlaceHolderTextView.h"

@class COTask;
@interface COTaskViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UIImageView *managerAvatar;
@property (weak, nonatomic) IBOutlet UIImageView *priorityImageView;
@property (weak, nonatomic) IBOutlet UIImageView *deadlineImageView;
@property (weak, nonatomic) IBOutlet UIImageView *progressImageView;
@property (weak, nonatomic) IBOutlet UILabel *managerLabel;
@property (weak, nonatomic) IBOutlet UILabel *priorityLabel;
@property (weak, nonatomic) IBOutlet UILabel *deadlineLabel;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UILabel *whoCreateDateLabel;

@property (weak, nonatomic) IBOutlet COPlaceHolderTextView *taskContentView;

@property (weak, nonatomic) IBOutlet UILabel *commentsLabel;

@property (weak, nonatomic) IBOutlet UIButton *managerBtn;
@property (weak, nonatomic) IBOutlet UIButton *priorityBtn;
@property (weak, nonatomic) IBOutlet UIButton *deadlineBtn;
@property (weak, nonatomic) IBOutlet UIButton *progressBtn;
@property (weak, nonatomic) IBOutlet UIButton *describeBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

+ (CGFloat)cellHeight;

- (void)assignWithTask:(COTask *)task withDescribe:(BOOL)hasDescribe;

@end
