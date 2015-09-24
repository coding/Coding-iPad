//
//  COSegmentControl.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/22.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kLineColor [UIColor colorWithRed:59/255.0 green:189/255.0 blue:121/255.0 alpha:1.0]
#define kHLineColor [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:0.0]
#define kTextColor [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0]
#define kTextFont (14)

typedef void(^COSegmentControlBlock)(NSInteger index);

@class COSegmentControl;
@protocol COSegmentControlDelegate <NSObject>

- (void)segmentControl:(COSegmentControl *)control selectedIndex:(NSInteger)index;

@end

@interface COSegmentControl : UIView

@property (nonatomic) NSInteger currentIndex;
@property (nonatomic , weak) id <COSegmentControlDelegate> delegate;

- (void)setItemsWithTitleArray:(NSArray *)titleArray selectedBlock:(COSegmentControlBlock)selectedHandle;
- (void)setItemsWithTitleArray:(NSArray *)titleArray;

- (void)selectIndex:(NSInteger)index;

- (void)setTitle:(NSString *)title withIndex:(NSInteger)index;

- (void)moveIndexWithProgress:(float)progress;

@end
