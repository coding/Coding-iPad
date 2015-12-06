//
//  COTweetImageCell.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/7/12.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COTweetImageCell.h"
#import "UIImageView+WebCache.h"
#import "COUtility.h"
#import "ImageSizeManager.h"
#import "COTweetViewController.h"
#import "View+MASAdditions.h"

@interface COTweetImageCell()

@property (nonatomic, strong) NSString *url;
@property (strong, nonatomic) UIImageView *gifMarkView;

@end

@implementation COTweetImageCell

- (void)loadImage:(NSString *)imageUrl single:(BOOL)single
{
    self.url = imageUrl;
    self.imageView.backgroundColor = [UIColor clearColor];
    
    __weak typeof(self) weakself = self;
    NSURL *u = nil;
    if (single) {
        u = [COUtility urlForImage:imageUrl withWidth:300.0];
    }
    else {
        u = [COUtility urlForImage:imageUrl withWidth:150.0];
    }
    
    [_imageView sd_setImageWithURL:u placeholderImage:[UIImage imageNamed:@"placeholder_image_gray"] options:SDWebImageRetryFailed | SDWebImageHandleCookies | SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) {
            NSLog(@"%@", error);
        }
        else {
//            if ([weakself.url  isEqualToString:imageUrl]) {
//                if (image.size.height < weakself.imageView.frame.size.height) {
//                    weakself.imageView.backgroundColor = [UIColor blackColor];
//                }
//                else {
//                    weakself.imageView.backgroundColor = [UIColor clearColor];
//                }
//            }
            if (single) {
                if (![[ImageSizeManager shareManager] hasSrc:weakself.url]) {
                    [[ImageSizeManager shareManager] saveImage:weakself.url size:image.size];
                    // TODO: reload cell
                    [[NSNotificationCenter defaultCenter] postNotificationName:COTweetImageResizeNotification object:nil];
                }
            }
            
            if ([imageUrl rangeOfString:@".gif"].location != NSNotFound) {
                if (!_gifMarkView) {
                    _gifMarkView = ({
                        UIImageView *imgView = [UIImageView new];
                        imgView.image = [UIImage imageNamed:@"gif_mark"];
                        [self.imageView addSubview:imgView];
                        [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
                            make.size.mas_equalTo(CGSizeMake(24, 13));
                            make.right.bottom.equalTo(self.imageView).offset(0);
                        }];
                        imgView;
                    });
                }
                self.gifMarkView.hidden = NO;
            }else{
                self.gifMarkView.hidden = YES;
            }
        }
    }];
}

@end
