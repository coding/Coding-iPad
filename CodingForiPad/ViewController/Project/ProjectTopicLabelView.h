//
//  ProjectTopicLabelView.h
//  Coding_iOS
//
//  Created by zwm on 15/4/24.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@class COTopic;
@interface ProjectTopicLabelView : UIView

@property (assign, nonatomic, readonly) CGFloat labelH;
@property (nonatomic, copy) void (^delLabelBlock)(NSInteger index);

- (id)initWithFrame:(CGRect)frame projectTopic:(COTopic *)topic md:(BOOL)isMD;

+ (CGFloat)heightWithObj:(COTopic *)topic md:(BOOL)isMD;

@end
