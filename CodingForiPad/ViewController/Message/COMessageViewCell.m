//
//  COMessageViewCell.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/10.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COMessageViewCell.h"
#import "UIImageView+WebCache.h"
#import "COHtmlMedia.h"
#import "COSession.h"
#import "COUtility.h"
#import "NSString+Common.h"

@implementation COMessageViewCell

- (void)awakeFromNib
{
    self.avatar.layer.cornerRadius = 25.0;
    self.avatar.layer.masksToBounds = YES;
    
    _msgLabel.textInsets = UIEdgeInsetsZero;
    _msgLabel.numberOfLines = 0;
    _msgLabel.font = [UIFont systemFontOfSize:14];
    _msgLabel.backgroundColor = [UIColor clearColor];
    _msgLabel.linkAttributes = kLinkAttributes;
    _msgLabel.activeLinkAttributes = kLinkAttributesActive;
}

- (void)assignWithConversation:(COConversation *)conversation
{
    if (conversation.sender.userId == [COSession session].user.userId) {
        [self.avatar sd_setImageWithURL:[NSURL URLWithString:[COSession session].user.avatar] placeholderImage:nil];
    } else {
        [self.avatar sd_setImageWithURL:[NSURL URLWithString:conversation.friendUser.avatar] placeholderImage:nil];
    }
   
    self.timeLabel.text = [COUtility timestampToDay_A_HH_MM:conversation.createdAt];
    
    self.msgLabel.text = conversation.content;
    
    for (HtmlMediaItem *item in conversation.htmlMedia.mediaItems) {
        if (item.displayStr.length > 0
            && !(item.type == HtmlMediaItemType_Code || item.type == HtmlMediaItemType_EmotionEmoji)) {
            [_msgLabel addLinkToTransitInformation:[NSDictionary dictionaryWithObject:item forKey:@"value"] withRange:item.range];
        }
    }
}

+ (CGFloat)cellHeight:(COConversation *)conversation
{
    CGFloat cellHeight = 0;
    
    HtmlMedia *htmlMedia = [HtmlMedia htmlMediaWithString:conversation.content showType:MediaShowTypeNone];

    CGSize textSize = [conversation.content getSizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(212, CGFLOAT_MAX)];
    CGFloat mediaViewHeight = 0;
//    if (htmlMedia && htmlMedia.imageItems.count > 0) {
//        for (HtmlMediaItem *curItem in htmlMedia.imageItems) {
//            mediaViewHeight += [COMessageViewCell ccellSizeWithObj:curItem].height + 11;
//        }
//        mediaViewHeight -= 11;
//    }
    
    cellHeight += mediaViewHeight;
    cellHeight += textSize.height + 20 + 18 + 15;
    
    if (mediaViewHeight > 0 && htmlMedia.contentDisplay && htmlMedia.contentDisplay.length > 0) {
        cellHeight += 11;
    }
    return cellHeight;
}

+ (CGSize)ccellSizeWithObj:(NSObject *)obj
{
    CGSize itemSize;
    if ([obj isKindOfClass:[UIImage class]]) {
        itemSize = [COMessageViewCell sizeWithImage:(UIImage *)obj originalWidth:212 maxHeight:212];
    } else if ([obj isKindOfClass:[HtmlMediaItem class]]) {
        //HtmlMediaItem *curMediaItem = (HtmlMediaItem *)obj;
        //itemSize = [COMessageViewCell sizeWithSrc:curMediaItem.src originalWidth:212 maxHeight:212];
    }
    return itemSize;
}

//+ (CGSize)sizeWithSrc:(NSString *)src originalWidth:(CGFloat)originalWidth maxHeight:(CGFloat)maxHeight
//{
//    CGSize reSize = [COMessageViewCell sizeWithImageH_W:[COMessageViewCell sizeOfImage:src] originalWidth:originalWidth];
//    if (reSize.height > maxHeight) {
//        reSize.height = maxHeight;
//    }
//    return reSize;
//}

+ (CGSize)sizeWithImageH_W:(CGFloat)height_width originalWidth:(CGFloat)originalWidth
{
    CGSize reSize = CGSizeZero;
    reSize.width = originalWidth;
    reSize.height = originalWidth *height_width;
    return reSize;
}

+ (CGSize)sizeWithImage:(UIImage *)image originalWidth:(CGFloat)originalWidth maxHeight:(CGFloat)maxHeight
{
    CGSize reSize = [COMessageViewCell sizeWithImageH_W:(image.size.height/image.size.width) originalWidth:originalWidth];
    if (reSize.height > maxHeight) {
        reSize.height = maxHeight;
    }
    return reSize;
}

//+ (CGFloat)sizeOfImage:(NSString *)imagePath
//{
//    CGFloat imageSize = 1;
//    NSNumber *sizeValue = [_imageSizeDict objectForKey:imagePath];
//    if (sizeValue) {
//        imageSize = sizeValue.floatValue;
//    }
//    return imageSize;
//}

@end
