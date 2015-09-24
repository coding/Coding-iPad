//
//  COTweetImageCell.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/7/12.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface COTweetImageCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (void)loadImage:(NSString *)imageUrl single:(BOOL)single;

@end
