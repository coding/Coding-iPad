//
//  COTaskViewHeadCell.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/10.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COTaskViewCell.h"
#import "COTask.h"
#import "COUtility.h"
#import "UIImageView+WebCache.h"
#import "COSession.h"

@interface COTaskViewCell () <UITextViewDelegate>

@property (nonatomic, strong) COTask *task;

@end

@implementation COTaskViewCell

- (void)awakeFromNib {
    // Initialization code
    _avatar.layer.cornerRadius = 25;
    _avatar.layer.masksToBounds = TRUE;
    _managerAvatar.layer.cornerRadius = 15;
    _managerAvatar.layer.masksToBounds = TRUE;
    _taskContentView.delegate = self;
    
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = selectedColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)cellHeight
{
    return 312;
}

- (void)assignWithTask:(COTask *)task withDescribe:(BOOL)hasDescribe
{
    self.task = task;
    self.deleteBtn.hidden = [task.creator.globalKey isEqualToString:[COSession session].user.globalKey] ? FALSE : TRUE;
    
    [self.avatar sd_setImageWithURL:[COUtility urlForImage:task.creator.avatar] placeholderImage:[COUtility placeHolder]];
    [self.managerAvatar sd_setImageWithURL:[COUtility urlForImage:task.owner.avatar] placeholderImage:[COUtility placeHolder]];
    _managerLabel.text = task.owner.name;
    
    _priorityLabel.text = [task priorityDisplay];

    if (task.status == 1) {
        _progressLabel.text = @"未完成";
    } else if (task.status == 2) {
        _progressLabel.text = @"已完成";
    }
    _deadlineLabel.text = [COUtility YYYYMMDDToMMDD:task.deadline];
    _commentsLabel.text = [NSString stringWithFormat:@"%ld条讨论", (long)task.comments];
    _whoCreateDateLabel.text = [NSString stringWithFormat:@"%@创建于%@", task.creator.name, [COUtility timestampToBefore:task.createdAt]];
    _taskContentView.text = task.content;
    
    self.describeBtn.selected = hasDescribe;
    if (self.describeBtn.selected) {
        [self.describeBtn setTitle:@"补充描述" forState:UIControlStateHighlighted];
        [self.describeBtn setTitleColor:[self.describeBtn titleColorForState:UIControlStateSelected] forState:UIControlStateHighlighted];
//        [self.describeBtn setBackgroundImage:[UIImage imageNamed:@"button_hollow_gray"] forState:UIControlStateHighlighted];
    } else {
        [self.describeBtn setTitle:@"查看描述" forState:UIControlStateHighlighted];
        [self.describeBtn setTitleColor:[self.describeBtn titleColorForState:UIControlStateNormal] forState:UIControlStateHighlighted];
//        [self.describeBtn setBackgroundImage:[UIImage imageNamed:@"button_hollow_green"] forState:UIControlStateHighlighted];
    }
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // 按下return键
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    _task.content = textView.text;
}

@end
