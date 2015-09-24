//
//  COTaskCell.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/10.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COProjectTaskCell.h"
#import "COUtility.h"
#import "UIImageView+WebCache.h"
#import "UIColor+Hex.h"
#import "NSDate+Common.h"

@implementation COProjectTaskCell

- (void)awakeFromNib {
    // Initialization code
    _avatarView.layer.cornerRadius = _avatarView.frame.size.width / 2;
    _avatarView.clipsToBounds = TRUE;
    _borderView.clipsToBounds = YES;
    _borderView.layer.cornerRadius = 2.0;
    _borderView.layer.borderWidth = 1.0;
    _borderView.layer.borderColor = [UIColor colorWithRed:255.0/255.0 green:69/255.0 blue:98/255.0 alpha:1].CGColor;
    
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = selectedColor;
}

- (void)assignWithTask:(COTask *)task withLeft:(BOOL)isLeft
{
    self.task = task;
    _doneBtn.selected = (task.status == 2) ? TRUE : FALSE;
        
    [self.avatarView sd_setImageWithURL:[COUtility urlForImage:task.owner.avatar] placeholderImage:[COUtility placeHolder]];
    
    UILabel *tempLbl = (UILabel *)[self viewWithTag:101];
    tempLbl.textColor = task.priority > 0 ? [UIColor colorWithRed:1.0 green:69/255.0 blue:98/255.0 alpha:1.0] : [UIColor colorWithRed:155/255.0 green:155/255.0 blue:155/255.0 alpha:1.0];
    
    tempLbl = (UILabel *)[self viewWithTag:102];
    tempLbl.textColor = task.priority > 1 ? [UIColor colorWithRed:1.0 green:69/255.0 blue:98/255.0 alpha:1.0] : [UIColor colorWithRed:155/255.0 green:155/255.0 blue:155/255.0 alpha:1.0];
    
    tempLbl = (UILabel *)[self viewWithTag:103];
    tempLbl.textColor = task.priority > 2 ? [UIColor colorWithRed:1.0 green:69/255.0 blue:98/255.0 alpha:1.0] : [UIColor colorWithRed:155/255.0 green:155/255.0 blue:155/255.0 alpha:1.0];
    
    _commentLabel.text = [NSString stringWithFormat:@"%ld条讨论", (long)task.comments];
    _createDateLabel.text = [COUtility timestampToBefore:task.createdAt];
    _createrLabel.text = task.creator.name;
    
    if (isLeft) {
        _taskLabel.text = [NSString stringWithFormat:@"      %@", task.content];
    } else {
        _taskLabel.text = task.content;
    }
    
    if (task.status == 1) {
        // 未完成
        if ([task.deadline length] > 0) {
            NSInteger dat = 0;
            NSDate *dealine = [COUtility dateFromYY_MM_DD:task.deadline];
            NSInteger leftDayCount = [dealine leftDayCount];
            UIColor *deadlineBGColor;
            NSString *deadlineStr;
            NSString *icon = nil;
            switch (leftDayCount) {
                case 0:
                    deadlineBGColor = [UIColor colorWithHexString:@"0xFFA400"];
                    deadlineStr = @"今天";
                    icon = @"icon_deadline_yellow";
                    dat = -8;
                    break;
                case 1:
                    deadlineBGColor = [UIColor colorWithHexString:@"0x95B763"];
                    deadlineStr = @"明天";
                    icon = @"icon_deadline_green";
                    dat = -8;
                    break;
                default:
                    deadlineBGColor = leftDayCount > 0 ? [UIColor colorWithHexString:@"0xb2c6d0"]: [UIColor colorWithHexString:@"0xFF4562"];
                    icon = leftDayCount > 0 ? @"icon_deadline_cyan" : @"icon_deadline_red";
                    deadlineStr = [COUtility YYYYMMDDToMD:task.deadline];
                    break;
            }
            _deadlineLabel.textColor = deadlineBGColor;
            _borderView.layer.borderColor = deadlineBGColor.CGColor;
            _deadlineView.image = [UIImage imageNamed:icon];
            _deadlineLabel.text = deadlineStr;
            _borderView.hidden = FALSE;
            _leftLayout.constant = 96 + dat;
            _topLayout.constant = 36;
        } else {
            _borderView.hidden = TRUE;
            _leftLayout.constant = 15;
            _topLayout.constant = 18;
        }
    } else {
        if ([task.deadline length] > 0) {
            _borderView.hidden = FALSE;
            if ([task.deadline length] > 0) {
                _leftLayout.constant = 96;
            } else {
                _leftLayout.constant = 96 - 8;
            }
            _topLayout.constant = 36;
            _deadlineLabel.textColor = [UIColor colorWithHexString:@"0xc8c8c8"];
            _deadlineLabel.textColor = [UIColor colorWithHexString:@"0xc8c8c8"];
            _borderView.layer.borderColor = [UIColor colorWithHexString:@"0xc8c8c8"].CGColor;
            _deadlineView.image = [UIImage imageNamed:@"icon_deadline_gray"];
        } else {
            _borderView.hidden = TRUE;
            _leftLayout.constant = 15;
            _topLayout.constant = 18;
        }
    }
}

- (IBAction)checkAcion:(UIButton *)sender
{
    if (self.clickedBlock) {
        self.clickedBlock(self.task);
    }
}

@end
