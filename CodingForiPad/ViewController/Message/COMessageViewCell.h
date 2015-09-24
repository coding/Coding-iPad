//
//  COMessageViewCell.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/10.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COConversation.h"
#import "COAttributedLabel.h"

@interface COMessageViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;

@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet COAttributedLabel *msgLabel;

- (void)assignWithConversation:(COConversation *)conversation;

+ (CGFloat)cellHeight:(COConversation *)conversation;

@end
