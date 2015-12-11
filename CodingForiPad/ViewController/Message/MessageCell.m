//
//  MessageCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//


#import "MessageCell.h"
#import "UITapImageView.h"
#import "MessageMediaItemCCell.h"
#import "UICustomCollectionView.h"
#import "COSession.h"
#import "UIImage+Common.h"
#import "NSString+Common.h"
#import "UIView+Extension.h"
#import "UIImageView+WebCache.h"
#import "ZLPhoto.h"

#define kMessageCell_FontContent [UIFont systemFontOfSize:14]
#define kMessageCell_PadingWidth 20.0
#define kMessageCell_PadingHeight 17.0
#define kMessageCell_ContentWidth (kRightView_Width*0.5)
#define kMessageCell_TimeHeight 30.0
#define kMessageCell_UserIconWith 50.0
#define kPaddingLeftWidth 20.0

@interface MessageCell() <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ZLPhotoPickerBrowserViewControllerDataSource, ZLPhotoPickerBrowserViewControllerDelegate>

@property (strong, nonatomic) COConversation *curPriMsg, *prePriMsg;

@property (strong, nonatomic) UITapImageView *userIconView;
@property (strong, nonatomic) UICustomCollectionView *mediaView;
@property (strong, nonatomic) NSMutableDictionary *imageViewsDict;

@property (strong, nonatomic) UIActivityIndicatorView *sendingStatus;
@property (strong, nonatomic) UITapImageView *failStatus;
@property (strong, nonatomic) UILabel *timeLabel;

@property (nonatomic, assign) CGFloat preMediaViewHeight;

@end

@implementation MessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        _preMediaViewHeight = 0;

        if (!_userIconView) {
            _userIconView = [[UITapImageView alloc] initWithFrame:CGRectMake(0, 0, kMessageCell_UserIconWith, kMessageCell_UserIconWith)];
            _userIconView.layer.masksToBounds = YES;
            _userIconView.layer.cornerRadius = _userIconView.frame.size.width/2;
            _userIconView.layer.borderWidth = 0.5;
            _userIconView.layer.borderColor = [UIColor colorWithHexString:@"0xdddddd"].CGColor;
            [self.contentView addSubview:_userIconView];
        }
        
        if (!_bgImgView) {
            _bgImgView = [[UILongPressMenuImageView alloc] initWithFrame:CGRectZero];
            _bgImgView.userInteractionEnabled = YES;
            [self.contentView addSubview:_bgImgView];
        }
        if (!_contentLabel) {
            _contentLabel = [[COAttributedLabel alloc] initWithFrame:CGRectMake(kMessageCell_PadingWidth, kMessageCell_PadingHeight, 0, 0)];
            _contentLabel.numberOfLines = 0;
            _contentLabel.font = kMessageCell_FontContent;
            _contentLabel.backgroundColor = [UIColor clearColor];
            [_contentLabel setTextColor:[UIColor colorWithRed:74/255.0 green:74/255.0 blue:74/255.0 alpha:1.0]];
            _contentLabel.linkAttributes = kLinkAttributes;
            _contentLabel.activeLinkAttributes = kLinkAttributesActive;
            _contentLabel.highlightedTextColor = [UIColor blackColor];
            [_bgImgView addSubview:_contentLabel];
        }
        if ([reuseIdentifier isEqualToString:kCellIdentifier_MessageMedia]) {
            if (!_mediaView) {
                UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
                _mediaView = [[UICustomCollectionView alloc] initWithFrame:CGRectMake(kMessageCell_PadingWidth, kMessageCell_PadingHeight - 2, kMessageCell_ContentWidth, 80) collectionViewLayout:layout];
                _mediaView.scrollEnabled = NO;
                [_mediaView setBackgroundView:nil];
                [_mediaView setBackgroundColor:[UIColor clearColor]];
                [_mediaView registerClass:[MessageMediaItemCCell class] forCellWithReuseIdentifier:kCCellIdentifier_MessageMediaItem];
                _mediaView.dataSource = self;
                _mediaView.delegate = self;
                [_bgImgView addSubview:_mediaView];
            }
            if (!_imageViewsDict) {
                _imageViewsDict = [[NSMutableDictionary alloc] init];
            }
        }
    }
    return self;
}

- (void)setCurPriMsg:(COConversation *)curPriMsg andPrePriMsg:(COConversation *)prePriMsg
{
    CGFloat mediaViewHeight = [MessageCell mediaViewHeightWithObj:curPriMsg];

    if (_curPriMsg == curPriMsg && _prePriMsg == prePriMsg && _preMediaViewHeight == mediaViewHeight) {
        [self configSendStatus];
        return;
    } else {
        _curPriMsg = curPriMsg;
        _prePriMsg = prePriMsg;
    }
    
    if (!_curPriMsg) {
        return;
    }
    CGFloat curBottomY = 0;
    NSString *displayStr = [MessageCell displayTimeStrWithCurMsg:_curPriMsg preMsg:_prePriMsg];
    if (displayStr) {
        if (!_timeLabel) {
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, (kMessageCell_TimeHeight - 20)/2, kRightView_Width - 2*kPaddingLeftWidth, 20)];
            _timeLabel.backgroundColor = [UIColor clearColor];
            _timeLabel.font = [UIFont systemFontOfSize:12];
            _timeLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            _timeLabel.textAlignment = NSTextAlignmentCenter;
            [self.contentView addSubview:_timeLabel];
        }
        _timeLabel.hidden = NO;
        _timeLabel.text = displayStr;
        curBottomY += kMessageCell_TimeHeight;
    }else{
        _timeLabel.hidden = YES;
    }
    
    UIImage *bgImg;
    CGSize bgImgViewSize;
    CGSize textSize;
    
    NSString *audioTips = @"语音消息，暂时不支持播放";
    if (_curPriMsg.type == 1) {
        textSize = [audioTips getSizeWithFont:kMessageCell_FontContent constrainedToSize:CGSizeMake(kMessageCell_ContentWidth, CGFLOAT_MAX)];
    }
    else if (_curPriMsg.content.length > 0) {
        textSize = [_curPriMsg.content getSizeWithFont:kMessageCell_FontContent constrainedToSize:CGSizeMake(kMessageCell_ContentWidth, CGFLOAT_MAX)];
    } else {
        textSize = CGSizeZero;
    }
    
    [_contentLabel setWidth:kMessageCell_ContentWidth];
    if (_curPriMsg.type == 1) {
        _contentLabel.text = audioTips;
    }
    else {
        _contentLabel.text = _curPriMsg.content;
    }
    [_contentLabel sizeToFit];
    
    for (HtmlMediaItem *item in _curPriMsg.htmlMedia.mediaItems) {
        if (item.displayStr.length > 0 && !(item.type == HtmlMediaItemType_Code ||item.type == HtmlMediaItemType_EmotionEmoji)) {
            [self.contentLabel addLinkToTransitInformation:[NSDictionary dictionaryWithObject:item forKey:@"value"] withRange:item.range];
        }
    }
    
    textSize.height = CGRectGetHeight(_contentLabel.frame);
    
    if (mediaViewHeight > 0) {
        // 有图片
        [_contentLabel setY:2*kMessageCell_PadingHeight + mediaViewHeight - 2];
        
        bgImgViewSize = CGSizeMake(kMessageCell_ContentWidth + 2*kMessageCell_PadingWidth + 10,
                                   mediaViewHeight + textSize.height + kMessageCell_PadingHeight*(_curPriMsg.content.length > 0 ? 3:2));
    } else {
        [_contentLabel setY:kMessageCell_PadingHeight - 2];
        
        bgImgViewSize = CGSizeMake(textSize.width + 2*kMessageCell_PadingWidth + 10, textSize.height + 2*kMessageCell_PadingHeight);
    }
    
    CGRect bgImgViewFrame;
    if (curPriMsg.sender.userId != [COSession session].user.userId) {
        // 这是好友发的
        //[_contentLabel setTextColor:[UIColor colorWithRed:74/255.0 green:74/255.0 blue:74/255.0 alpha:1.0]];
        [_contentLabel setX:kMessageCell_PadingWidth + 5];
        [_mediaView setX:kMessageCell_PadingWidth + 5];
        
        bgImgViewFrame = CGRectMake(kPaddingLeftWidth + kMessageCell_UserIconWith + 10, curBottomY +kMessageCell_PadingHeight, bgImgViewSize.width, bgImgViewSize.height);
        [_userIconView setCenter:CGPointMake(kPaddingLeftWidth + kMessageCell_UserIconWith/2, CGRectGetMaxY(bgImgViewFrame)- kMessageCell_UserIconWith/2)];
        bgImg = [UIImage imageNamed:@"background_message_text_gray"];
        _bgImgView.frame = bgImgViewFrame;
    } else {
        // 这是自己发的
        //[_contentLabel setTextColor:[UIColor whiteColor]];
        [_contentLabel setX:kMessageCell_PadingWidth + 5];
        [_mediaView setX:kMessageCell_PadingWidth + 5];
        
        bgImgViewFrame = CGRectMake((kRightView_Width - kPaddingLeftWidth - kMessageCell_UserIconWith - 10) - bgImgViewSize.width, curBottomY + kMessageCell_PadingHeight, bgImgViewSize.width, bgImgViewSize.height);
        [_userIconView setCenter:CGPointMake(kRightView_Width - kPaddingLeftWidth - kMessageCell_UserIconWith/2, CGRectGetMaxY(bgImgViewFrame)- kMessageCell_UserIconWith/2)];
        bgImg = [UIImage imageNamed:@"background_message_text_blue"];
        _bgImgView.frame = bgImgViewFrame;
    }
    
    __weak typeof(self) weakSelf = self;
    [_userIconView addTapBlock:^(id obj) {
        weakSelf.tapUserIconBlock(weakSelf.curPriMsg.sender);
    }];
    [_userIconView sd_setImageWithURL:[COUtility urlForImage:_curPriMsg.sender.avatar] placeholderImage:[COUtility placeHolder]];
    
    [_bgImgView setImage:bgImg];
    
    //_contentLabel.text = _curPriMsg.content;
    
    if (_mediaView) {
        [_mediaView setHeight:mediaViewHeight];
        [_mediaView reloadData];
    }
    [self configSendStatus];
    
    _preMediaViewHeight = mediaViewHeight;
}

- (void)configSendStatus
{
    CGPoint statusCenter = CGPointMake(CGRectGetMinX(_bgImgView.frame) - 20, CGRectGetMinY(_bgImgView.frame) + 15);
    if (_curPriMsg.sendStatus == PrivateMessageStatusSendSucess) {
        if (_sendingStatus) {
            [_sendingStatus stopAnimating];
        }
        if (_failStatus) {
            _failStatus.hidden = YES;
        }
    } else if (_curPriMsg.sendStatus == PrivateMessageStatusSending) {
        if (!_sendingStatus) {
            _sendingStatus = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            _sendingStatus.hidesWhenStopped = YES;
            [self.contentView addSubview:_sendingStatus];
        }
        [_sendingStatus setCenter:statusCenter];
        [_sendingStatus startAnimating];
        if (_failStatus) {
            _failStatus.hidden = YES;
        }
    } else if (_curPriMsg.sendStatus == PrivateMessageStatusSendFail) {
        if (_sendingStatus) {
            [_sendingStatus stopAnimating];
        }
        __weak typeof(self) weakSelf = self;
        if (!_failStatus) {
            _failStatus = [[UITapImageView alloc] initWithImage:[UIImage imageNamed:@"private_message_send_fail"]];
            if (weakSelf.resendMessageBlock) {
                [weakSelf.failStatus addTapBlock:^(id obj) {
                    weakSelf.resendMessageBlock(weakSelf.curPriMsg);
                }];
            }
            [self.contentView addSubview:_failStatus];
        }
        [_failStatus setCenter:statusCenter];
        _failStatus.hidden = NO;
    }
}

+ (CGFloat)cellHeightWithObj:(id)obj preObj:(id)preObj
{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[COConversation class]]) {
        COConversation *curPriMsg = (COConversation *)obj;
        CGSize textSize = [curPriMsg.content getSizeWithFont:kMessageCell_FontContent constrainedToSize:CGSizeMake(kMessageCell_ContentWidth, CGFLOAT_MAX)];
        CGFloat mediaViewHeight = [MessageCell mediaViewHeightWithObj:curPriMsg];
        cellHeight += mediaViewHeight;
        cellHeight += textSize.height + kMessageCell_PadingHeight*4;
        
        if (mediaViewHeight > 0 && curPriMsg.content && curPriMsg.content.length > 0) {
            cellHeight += kMessageCell_PadingHeight;
        }
        
        COConversation *prePriMsg = (COConversation *)preObj;
        NSString *displayStr = [MessageCell displayTimeStrWithCurMsg:curPriMsg preMsg:prePriMsg];
        if (displayStr) {
            cellHeight += kMessageCell_TimeHeight;
        }
    }
    return cellHeight;
}

+ (NSString *)displayTimeStrWithCurMsg:(COConversation *)cur preMsg:(COConversation *)pre
{
    NSString *displayStr = nil;
    if (!pre || cur.createdAt - pre.createdAt > 1*60*1000) {
        displayStr = [COUtility timestampToDay_A_HH_MM:cur.createdAt];
    }
    return displayStr;
}

+ (CGFloat)mediaViewHeightWithObj:(COConversation *)curPriMsg
{
    CGFloat mediaViewHeight = 0;
    if (curPriMsg.hasMedia) {
        if (curPriMsg.nextImg) {
            mediaViewHeight += [MessageMediaItemCCell ccellSizeWithObj:curPriMsg.nextImg].height;
        } else {
            for (HtmlMediaItem *curItem in curPriMsg.htmlMedia.imageItems) {
                mediaViewHeight += [MessageMediaItemCCell ccellSizeWithObj:curItem].height +kMessageCell_PadingHeight;
            }
            mediaViewHeight -= kMessageCell_PadingHeight;
        }
    }
    return mediaViewHeight;
}

#pragma mark Collection M
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (!_curPriMsg) {
        return 0;
    }
    NSUInteger mediaCount = (_curPriMsg.htmlMedia && _curPriMsg.htmlMedia.imageItems.count> 0)? _curPriMsg.htmlMedia.imageItems.count : 1;
    return mediaCount;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MessageMediaItemCCell *ccell = [collectionView dequeueReusableCellWithReuseIdentifier:kCCellIdentifier_MessageMediaItem forIndexPath:indexPath];
    ccell.refreshMessageMediaCCellBlock = self.refreshMessageMediaCCellBlock;

    ccell.curPriMsg = _curPriMsg;
    if (_curPriMsg.nextImg) {
        ccell.curObj = _curPriMsg.nextImg;
    } else {
        HtmlMediaItem *curItem = [_curPriMsg.htmlMedia.imageItems objectAtIndex:indexPath.row];
        ccell.curObj = curItem;
    }
    [_imageViewsDict setObject:ccell.imgView forKey:indexPath];
    return ccell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize itemSize = CGSizeZero;
    if (_curPriMsg.nextImg) {
        itemSize = [MessageMediaItemCCell ccellSizeWithObj:_curPriMsg.nextImg];
    } else {
        HtmlMediaItem *curItem = [_curPriMsg.htmlMedia.imageItems objectAtIndex:indexPath.row];
        itemSize = [MessageMediaItemCCell ccellSizeWithObj:curItem];
    }
    return itemSize;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return kMessageCell_PadingHeight;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZLPhotoPickerBrowserViewController *pickerBrowser = [[ZLPhotoPickerBrowserViewController alloc] init];
    pickerBrowser.status = UIViewAnimationAnimationStatusFade;
    pickerBrowser.delegate = self;
    pickerBrowser.dataSource = self;
    pickerBrowser.editing = NO;
    pickerBrowser.currentIndexPath = indexPath;
    [pickerBrowser show];
}

#pragma mark - ZLPhotoPickerBrowserViewControllerDelegate
- (void)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser removePhotoAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - ZLPhotoPickerBrowserViewControllerDataSource
- (NSInteger)numberOfSectionInPhotosInPickerBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser
{
    return 1;
}

- (NSInteger)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser numberOfItemsInSection:(NSUInteger)section
{
    if (_curPriMsg.nextImg) {
        return 1;
    }
    return (_curPriMsg.htmlMedia && _curPriMsg.htmlMedia.imageItems.count> 0)? _curPriMsg.htmlMedia.imageItems.count : 1;
}

- (ZLPhotoPickerBrowserPhoto *)photoBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser photoAtIndexPath:(NSIndexPath *)indexPath
{
    ZLPhotoPickerBrowserPhoto *photo;
    if (_curPriMsg.nextImg) {
        photo = [ZLPhotoPickerBrowserPhoto photoAnyImageObjWith:_curPriMsg.nextImg];
        photo.toView = [_imageViewsDict objectForKey:indexPath];
    } else {
        HtmlMediaItem *imageItem = [_curPriMsg.htmlMedia.imageItems objectAtIndex:indexPath.row];
        photo = [ZLPhotoPickerBrowserPhoto photoAnyImageObjWith:imageItem.src];
        photo.toView = [_imageViewsDict objectForKey:indexPath];
    }
    return photo;
}

@end
