//
//  COTagView.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/22.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@class COTagView;
@protocol COTagViewDelegate <NSObject>
@optional
- (void)delBtnClick:(COTagView *)tagView;
@end

@class COTopicLabel;
@interface COTagView : UIView

@property (nonatomic, weak) id<COTagViewDelegate> delLabelDelegate;

- (void)setLabels:(COTopicLabel *)labels;

@end
