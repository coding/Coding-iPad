//
//  TopicCommentCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-27.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kTopicCommentCell_FontContent [UIFont systemFontOfSize:14]

#import "TopicCommentCell.h"
#import "COAttributedLabel.h"

#import "UICustomCollectionView.h"
#import "TopicCommentCCell.h"

#import "COUtility.h"
#import "UIImageView+WebCache.h"
#import "UILabel+Common.h"
#import "NSString+Common.h"
#import "ZLPhoto.h"

#define kCell_Width 573
#define kPaddingLeftWidth 20

@interface TopicCommentCell ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ZLPhotoPickerBrowserViewControllerDataSource, ZLPhotoPickerBrowserViewControllerDelegate>

@property (strong, nonatomic) UIImageView *ownerIconView;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UICustomCollectionView *imageCollectionView;

@end

@implementation TopicCommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        CGFloat curBottomY = 25;
        if (!_ownerIconView) {
            _ownerIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 20, 30, 30)];
            _ownerIconView.layer.cornerRadius = 15;
            _ownerIconView.layer.masksToBounds = TRUE;
            [self.contentView addSubview:_ownerIconView];
        }
        CGFloat curWidth = kCell_Width - 50 - 2*kPaddingLeftWidth;
        if (!_contentLabel) {
            _contentLabel = [[COAttributedLabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth + 50, curBottomY, curWidth, 17)];
            _contentLabel.textColor = [UIColor colorWithRed:74/255.0 green:74/255.0 blue:74/255.0 alpha:1.0];
            _contentLabel.font = kTopicCommentCell_FontContent;
            _contentLabel.linkAttributes = kLinkAttributes;
            _contentLabel.activeLinkAttributes = kLinkAttributesActive;
            [self.contentView addSubview:_contentLabel];
        }
        if (!_timeLabel) {
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth + 50, 0, curWidth, 20)];
            _timeLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
            _timeLabel.font = [UIFont systemFontOfSize:12];
            [self.contentView addSubview:_timeLabel];
        }
        
        if ([reuseIdentifier isEqualToString:kCellIdentifier_TopicComment_Media]) {
            if (!self.imageCollectionView) {
                UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
                self.imageCollectionView = [[UICustomCollectionView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth + 50, 0, curWidth, 43) collectionViewLayout:layout];
                self.imageCollectionView.scrollEnabled = NO;
                [self.imageCollectionView setBackgroundView:nil];
                [self.imageCollectionView setBackgroundColor:[UIColor clearColor]];
                [self.imageCollectionView registerClass:[TopicCommentCCell class] forCellWithReuseIdentifier:kCCellIdentifier_TopicCommentCCell];
                self.imageCollectionView.dataSource = self;
                self.imageCollectionView.delegate = self;
                [self.contentView addSubview:self.imageCollectionView];
            }
        }
        
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = selectedColor;
    }
    return self;
}

- (void)setToComment:(COTopic *)comment
{
    _toComment = comment;
    
    if (!_toComment) {
        return;
    }
    CGFloat curBottomY = 25;
    CGFloat curWidth = kCell_Width - 50 - 2*kPaddingLeftWidth;
    [_ownerIconView sd_setImageWithURL:[COUtility urlForImage:_toComment.owner.avatar] placeholderImage:[COUtility placeHolder]];
    [_contentLabel setLongString:_toComment.content withFitWidth:curWidth];
    
    for (HtmlMediaItem *item in _toComment.htmlMedia.mediaItems) {
        if (item.displayStr.length > 0 && !(item.type == HtmlMediaItemType_Code ||item.type == HtmlMediaItemType_EmotionEmoji)) {
            [_contentLabel addLinkToTransitInformation:[NSDictionary dictionaryWithObject:item forKey:@"value"] withRange:item.range];
        }
    }
    
    curBottomY += [_toComment.content getHeightWithFont:kTopicCommentCell_FontContent constrainedToSize:CGSizeMake(curWidth, CGFLOAT_MAX)] + 5;
    
    NSInteger imagesCount = _toComment.htmlMedia.imageItems.count;
    if (imagesCount > 0) {
        self.imageCollectionView.hidden = NO;
        [self.imageCollectionView setFrame:CGRectMake(kPaddingLeftWidth + 50, curBottomY, curWidth, [TopicCommentCell imageCollectionViewHeightWithCount:imagesCount])];
        [self.imageCollectionView reloadData];
    } else {
        self.imageCollectionView.hidden = YES;
    }
    
    curBottomY += [TopicCommentCell imageCollectionViewHeightWithCount:imagesCount];
    
    CGRect frame = _timeLabel.frame;
    frame.origin.y = curBottomY;
    _timeLabel.frame = frame;
    _timeLabel.text = [NSString stringWithFormat:@"%@ 发布于 %@", _toComment.owner.name, [COUtility  timestampToBefore:_toComment.createdAt]];
}

+ (CGFloat)cellHeightWithObj:(id)obj
{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[COTopic class]]) {
        COTopic *toComment = (COTopic *)obj;
        CGFloat curWidth = kCell_Width - 50 - 2*kPaddingLeftWidth;
        cellHeight += 25 + [toComment.content getHeightWithFont:kTopicCommentCell_FontContent constrainedToSize:CGSizeMake(curWidth, CGFLOAT_MAX)] + 5 + 20 + 10;
        cellHeight += [self imageCollectionViewHeightWithCount:toComment.htmlMedia.imageItems.count];
    }
    return cellHeight;
}

+ (CGFloat)imageCollectionViewHeightWithCount:(NSInteger)countNum
{
    if (countNum <= 0) {
        return 0;
    }
    CGFloat curWidth = kCell_Width - 50 - 2*kPaddingLeftWidth;
    NSInteger numInOneLine = floorf((curWidth + 5)/(33 + 5));
    NSInteger numOfline = ceilf(countNum/(float)numInOneLine);
    return (43 * numOfline);
}

#pragma mark Collection M
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _toComment.htmlMedia.imageItems.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TopicCommentCCell *ccell = [collectionView dequeueReusableCellWithReuseIdentifier:kCCellIdentifier_TopicCommentCCell forIndexPath:indexPath];
    ccell.curMediaItem = [_toComment.htmlMedia.imageItems objectAtIndex:indexPath.row];
    return ccell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [TopicCommentCCell ccellSize];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 显示大图
    [self setupPhotoBrowser:indexPath.row];
}

- (void)setupPhotoBrowser:(NSInteger)curIndex
{
    ZLPhotoPickerBrowserViewController *pickerBrowser = [[ZLPhotoPickerBrowserViewController alloc] init];
    pickerBrowser.status = UIViewAnimationAnimationStatusFade;
    pickerBrowser.delegate = self;
    pickerBrowser.dataSource = self;
    pickerBrowser.editing = NO;
    pickerBrowser.currentIndexPath = [NSIndexPath indexPathForRow:curIndex inSection:0];
    [pickerBrowser show];
}

#pragma mark - ZLPhotoPickerBrowserViewControllerDataSource
- (NSInteger)numberOfSectionInPhotosInPickerBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser
{
    return 1;
}

- (NSInteger)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser numberOfItemsInSection:(NSUInteger)section
{
    return _toComment.htmlMedia.imageItems.count;
}

- (ZLPhotoPickerBrowserPhoto *)photoBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser photoAtIndexPath:(NSIndexPath *)indexPath
{
    //TaskCommentCCell *cell = (TaskCommentCCell *)[self.imageCollectionView cellForItemAtIndexPath:indexPath];
    HtmlMediaItem *item = _toComment.htmlMedia.imageItems[indexPath.row];
    ZLPhotoPickerBrowserPhoto *photo = [ZLPhotoPickerBrowserPhoto photoAnyImageObjWith:[NSURL URLWithString:item.src]];
    //photo.toView = (UIImageView *)cell.imgView;
    return photo;
}

@end
