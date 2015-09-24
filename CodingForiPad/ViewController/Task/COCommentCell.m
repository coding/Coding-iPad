//
//  COCommentCell.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/10.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COCommentCell.h"
#import "COTask.h"
#import "COUtility.h"
#import "UIImageView+WebCache.h"
#import "COAttributedLabel.h"
#import "COUser.h"

@implementation COCommentCell

- (void)awakeFromNib {
    // Initialization code
    _avatar.layer.cornerRadius = 15;
    _avatar.layer.masksToBounds = TRUE;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)assignWithComment:(COTaskComment *)comment
{
    [self.contentLabel configForTweetComment];
    
    [self.avatar sd_setImageWithURL:[COUtility urlForImage:comment.owner.avatar] placeholderImage:[COUtility placeHolder]];
    self.htmlMedia = [HtmlMedia htmlMediaWithString:comment.content showType:MediaShowTypeNone];
    self.contentLabel.text = self.htmlMedia.contentDisplay;
    
    for (HtmlMediaItem *item in _htmlMedia.mediaItems) {
        if (item.displayStr.length > 0
            && !(item.type == HtmlMediaItemType_Code ||item.type == HtmlMediaItemType_EmotionEmoji)) {
            [_contentLabel addLinkToTransitInformation:[NSDictionary dictionaryWithObject:item forKey:@"value"] withRange:item.range];
        }
    }
    NSString *time = [COUtility timestampToBefore:comment.createdAt * 1000];
    self.whoWhenLabel.text = [NSString stringWithFormat:@"%@发布于%@", comment.owner.name, time];
}

+ (CGFloat)cellHeight
{
    return 85;
}

@end
