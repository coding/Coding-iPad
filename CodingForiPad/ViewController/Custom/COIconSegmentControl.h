//
//  SegmentControl.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/22.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kLineColor [UIColor colorWithRed:59/255.0 green:189/255.0 blue:121/255.0 alpha:1.0]
#define kHLineColor [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:0.0]
#define kIconDefault [UIImage imageNamed:@"icon_alltask"]
#define kIconWidth (50)
#define kIconHeight (50)
#define kItemWidth (60)

typedef void(^COIconSegmentControlBlock)(NSInteger index);

@class COIconSegmentControl;
@protocol COIconSegmentControlDelegate <NSObject>
- (void)segmentControl:(COIconSegmentControl *)control selectedIndex:(NSInteger)index;
@end

@interface COIconSegmentControl : UIView

@property (nonatomic) NSInteger currentIndex;
@property (nonatomic, weak) id <COIconSegmentControlDelegate> delegate;

- (void)setItemsWithIconArray:(NSArray *)titleItem selectedBlock:(COIconSegmentControlBlock)selectedHandle;
- (void)setItemsWithIconArray:(NSArray *)titleItem;

- (void)selectIndex:(NSInteger)index;

- (void)moveIndexWithProgress:(float)progress;

@end
