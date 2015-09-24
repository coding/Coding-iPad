//
//  COTweetImagesView.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/17.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COTweetImagesView.h"
#import "COTweetImageCell.h"
#import "COHtmlMedia.h"
#import "ZLPhoto.h"
#import "COUtility.h"
#import "ImageSizeManager.h"

@interface COTweetImagesView() <ZLPhotoPickerBrowserViewControllerDataSource, ZLPhotoPickerBrowserViewControllerDelegate>

@property (nonatomic, strong) NSArray *images;

@end

@implementation COTweetImagesView


- (void)loadImages:(NSArray *)images
{
    self.images = images;
    self.delegate = self;
    self.dataSource = self;
    [self reloadData];
}

#pragma mark -
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _images.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self deselectItemAtIndexPath:indexPath animated:YES];
    [self setupPhotoBrowser:indexPath.row];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    COTweetImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"COTweetImageCell" forIndexPath:indexPath];
    HtmlMediaItem *item = _images[indexPath.row];
    if (_images.count == 1) {
        if (item.type == HtmlMediaItemType_EmotionMonkey) {
            cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
            cell.imageView.backgroundColor = [UIColor clearColor];
        }
        else {
            cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
            cell.imageView.backgroundColor = [UIColor blackColor];
        }
        [cell loadImage:item.src single:YES];
    }
    else {
        if (item.type == HtmlMediaItemType_EmotionMonkey) {
            cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
            cell.imageView.backgroundColor = [UIColor clearColor];
        }
        else {
            cell.imageView.contentMode = UIViewContentModeCenter;
            cell.imageView.backgroundColor = [UIColor blackColor];
        }
        [cell loadImage:item.src single:NO];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (_images.count == 1) {
        HtmlMediaItem *item = _images.firstObject;
        if (item.type == HtmlMediaItemType_EmotionMonkey) {
            return CGSizeMake(COMulityImageHeight, COMulityImageHeight);
        }
        if ([[ImageSizeManager shareManager] hasSrc:item.src]) {
            return [[ImageSizeManager shareManager] sizeWithSrc:item.src originalWidth:300.0 maxHeight:500.0];
        }
        return CGSizeMake(300.0, COSingleImageHeight);
    }
    return CGSizeMake(150.0, COMulityImageHeight);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0.0, 0.0, 10.0, 10.0);
}

#pragma mark - ZLPhotoPickerBrowserViewControllerDataSource
- (NSInteger)numberOfSectionInPhotosInPickerBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser
{
    return 1;
}

- (NSInteger)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser numberOfItemsInSection:(NSUInteger)section
{
    return _images.count;
}

- (ZLPhotoPickerBrowserPhoto *)photoBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser photoAtIndexPath:(NSIndexPath *)indexPath
{
    COTweetImageCell *cell = (COTweetImageCell *)[self cellForItemAtIndexPath:indexPath];
    HtmlMediaItem *item = _images[indexPath.row];
    ZLPhotoPickerBrowserPhoto *photo = [ZLPhotoPickerBrowserPhoto photoAnyImageObjWith:item.src];
    photo.toView = cell.imageView;
    return photo;
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

@end
