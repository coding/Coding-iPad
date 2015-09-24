//
//  COTaskCell.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/10.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COTask.h"
#import "SWTableViewCell.h"

@interface COProjectTaskCell : SWTableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *avatarView;
@property (nonatomic, weak) IBOutlet UILabel *deadlineLabel;
@property (nonatomic, weak) IBOutlet UILabel *commentLabel;
@property (nonatomic, weak) IBOutlet UILabel *createDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *taskLabel;
@property (weak, nonatomic) IBOutlet UILabel *createrLabel;

@property (weak, nonatomic) IBOutlet UIButton *doneBtn;
@property (weak, nonatomic) IBOutlet UIView *borderView;
@property (weak, nonatomic) IBOutlet UIImageView *deadlineView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLayout;

@property (strong, nonatomic) COTask *task;
@property (copy, nonatomic) void(^clickedBlock)(COTask *task);

- (void)assignWithTask:(COTask *)task withLeft:(BOOL)isLeft;

@end
