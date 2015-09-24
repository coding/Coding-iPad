//
//  COMessageCell.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/10.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COConversation.h"
#import "COAttributedLabel.h"
#import "SWTableViewCell.h"
#import "CORedDotView.h"

@interface COMessageCell : SWTableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet COAttributedLabel *msgLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet CORedDotView *countView;

- (void)assignWithConversation:(COConversation *)conversation;

@end
