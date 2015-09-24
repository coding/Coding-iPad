//
//  COTweetImagesView.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/17.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>

#define COSingleImageHeight 225.0
#define COMulityImageHeight 150.0

@interface COTweetImagesView : UICollectionView<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

- (void)loadImages:(NSArray *)images;

@end
