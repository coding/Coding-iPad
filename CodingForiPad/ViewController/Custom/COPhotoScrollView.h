//
//  OPPhotoScrollView.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/22.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kPhotoMax 6

@protocol COPhotoScrollViewDelegate <NSObject>
- (void)photoChanged:(NSArray *)imageAry;
@end

@interface COPhotoScrollView : UIScrollView

@property (nonatomic, strong) NSMutableArray *imageAry;
@property (nonatomic, weak) id<COPhotoScrollViewDelegate> photoDelegate;

- (void)resetUI;

- (BOOL)setupPhotoPicker;

@end
