//
//  COCommentCell.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/10.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COHtmlMedia.h"

@class COTaskComment;
@class COAttributedLabel;
@interface COCommentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet COAttributedLabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *whoWhenLabel;
@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (nonatomic, strong) HtmlMedia *htmlMedia;

- (void)assignWithComment:(COTaskComment *)comment;

+ (CGFloat)cellHeight;

@end
