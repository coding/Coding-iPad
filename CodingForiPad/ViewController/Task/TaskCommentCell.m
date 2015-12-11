//
//  TaskCommentCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14/10/28.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "TaskCommentCell.h"
#import "UICustomCollectionView.h"
#import "TaskCommentCCell.h"

#import "COTask.h"
#import "COUtility.h"
#import "UIImageView+WebCache.h"
#import "COUser.h"
#import "UILabel+Common.h"
#import "NSString+Common.h"
#import "ZLPhoto.h"

#define kCell_Width kRightView_Width

#define kTaskCommentCell_FontContent [UIFont systemFontOfSize:14]
#define kTaskCommentCell_LeftPading 20.0
#define kTaskCommentCell_LeftContentPading (kTaskCommentCell_LeftPading + 50)
#define kTaskCommentCell_ContentWidth (kCell_Width - kTaskCommentCell_LeftContentPading - kTaskCommentCell_LeftPading)

@interface TaskCommentCell ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ZLPhotoPickerBrowserViewControllerDataSource, ZLPhotoPickerBrowserViewControllerDelegate>
@property (strong, nonatomic) UIImageView *ownerIconView;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UICustomCollectionView *imageCollectionView;

@end

@implementation TaskCommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        CGFloat curBottomY = 20;
        if (!_ownerIconView) {
            _ownerIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kTaskCommentCell_LeftPading, curBottomY, 30, 30)];
            _ownerIconView.layer.cornerRadius = 15;
            _ownerIconView.layer.masksToBounds = TRUE;
            [self.contentView addSubview:_ownerIconView];
        }
        if (!_contentLabel) {
            _contentLabel = [[COAttributedLabel alloc] initWithFrame:CGRectMake(kTaskCommentCell_LeftContentPading, curBottomY, kTaskCommentCell_ContentWidth, 17)];
            _contentLabel.textColor = [UIColor colorWithRed:74/255.0 green:74/255.0 blue:74/255.0 alpha:1.0];
            _contentLabel.font = kTaskCommentCell_FontContent;
            _contentLabel.linkAttributes = kLinkAttributes;
            _contentLabel.activeLinkAttributes = kLinkAttributesActive;
            [self.contentView addSubview:_contentLabel];
        }
        if (!_timeLabel) {
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTaskCommentCell_LeftContentPading, 0, kTaskCommentCell_ContentWidth, 20)];
            _timeLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
            _timeLabel.font = [UIFont systemFontOfSize:12];
            [self.contentView addSubview:_timeLabel];
        }
        if ([reuseIdentifier isEqualToString:kCellIdentifier_TaskComment_Media]) {
            if (!self.imageCollectionView) {
                UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
                self.imageCollectionView = [[UICustomCollectionView alloc] initWithFrame:CGRectMake(kTaskCommentCell_LeftContentPading, 0, kTaskCommentCell_ContentWidth, 43) collectionViewLayout:layout];
                self.imageCollectionView.scrollEnabled = NO;
                [self.imageCollectionView setBackgroundView:nil];
                [self.imageCollectionView setBackgroundColor:[UIColor clearColor]];
                [self.imageCollectionView registerClass:[TaskCommentCCell class] forCellWithReuseIdentifier:kCCellIdentifier_TaskCommentCCell];
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

- (void)setCurComment:(COTaskComment *)curComment
{
    _curComment = curComment;
    if (!_curComment) {
        return;
    }
    CGFloat curBottomY = 25;
    [_ownerIconView sd_setImageWithURL:[COUtility urlForImage:_curComment.owner.avatar] placeholderImage:[COUtility placeHolder]];
    [_contentLabel setLongString:_curComment.content withFitWidth:kTaskCommentCell_ContentWidth];

    for (HtmlMediaItem *item in _curComment.htmlMedia.mediaItems) {
        if (item.displayStr.length > 0 && !(item.type == HtmlMediaItemType_Code ||item.type == HtmlMediaItemType_EmotionEmoji)) {
            [_contentLabel addLinkToTransitInformation:[NSDictionary dictionaryWithObject:item forKey:@"value"] withRange:item.range];
        }
    }
    
    curBottomY += [_curComment.content getHeightWithFont:kTaskCommentCell_FontContent constrainedToSize:CGSizeMake(kTaskCommentCell_ContentWidth, CGFLOAT_MAX)] + 5;
    
    NSInteger imagesCount = _curComment.htmlMedia.imageItems.count;
    if (imagesCount > 0) {
        self.imageCollectionView.hidden = NO;
        [self.imageCollectionView setFrame:CGRectMake(kTaskCommentCell_LeftContentPading, curBottomY, kTaskCommentCell_ContentWidth, [TaskCommentCell imageCollectionViewHeightWithCount:imagesCount])];
        [self.imageCollectionView reloadData];
    } else {
        self.imageCollectionView.hidden = YES;
    }
    
    curBottomY += [TaskCommentCell imageCollectionViewHeightWithCount:imagesCount];
    
    CGRect frame = _timeLabel.frame;
    frame.origin.y = curBottomY;
    _timeLabel.frame = frame;
    _timeLabel.text = [NSString stringWithFormat:@"%@ 发布于 %@", _curComment.owner.name, [COUtility  timestampToBefore:_curComment.createdAt]];
}

+ (CGFloat)cellHeightWithObj:(id)obj
{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[COTaskComment class]]) {
        COTaskComment *curComment = (COTaskComment *)obj;
        NSString *contentStr = curComment.content;
        cellHeight += 25 + [contentStr getHeightWithFont:kTaskCommentCell_FontContent constrainedToSize:CGSizeMake(kTaskCommentCell_ContentWidth, CGFLOAT_MAX)] + 5 + 20 +10;
        cellHeight += [self imageCollectionViewHeightWithCount:curComment.htmlMedia.imageItems.count];
    }
    return cellHeight;
}

+ (CGFloat)imageCollectionViewHeightWithCount:(NSInteger)countNum
{
    if (countNum <= 0) {
        return 0;
    }
    NSInteger numInOneLine = floorf((kTaskCommentCell_ContentWidth +5)/(33 + 5));
    NSInteger numOfline = ceilf(countNum/(float)numInOneLine);
    return (43 *numOfline);
}


#pragma mark Collection M
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _curComment.htmlMedia.imageItems.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TaskCommentCCell *ccell = [collectionView dequeueReusableCellWithReuseIdentifier:kCCellIdentifier_TaskCommentCCell forIndexPath:indexPath];
    ccell.curMediaItem = [_curComment.htmlMedia.imageItems objectAtIndex:indexPath.row];
    return ccell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [TaskCommentCCell ccellSize];
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
    return _curComment.htmlMedia.imageItems.count;
}

- (ZLPhotoPickerBrowserPhoto *)photoBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser photoAtIndexPath:(NSIndexPath *)indexPath
{
    //TaskCommentCCell *cell = (TaskCommentCCell *)[self.imageCollectionView cellForItemAtIndexPath:indexPath];
    HtmlMediaItem *item = _curComment.htmlMedia.imageItems[indexPath.row];
    ZLPhotoPickerBrowserPhoto *photo = [ZLPhotoPickerBrowserPhoto photoAnyImageObjWith:[NSURL URLWithString:item.src]];
    //photo.toView = (UIImageView *)cell.imgView;
    return photo;
}

@end
