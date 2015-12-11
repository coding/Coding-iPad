//
//  ProjectTopicLabelView.m
//  Coding_iOS
//
//  Created by zwm on 15/4/24.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "ProjectTopicLabelView.h"
#import "COTopic.h"
#import "COTagView.h"

#define kCell_Width kRightView_Width
#define kPaddingLeftWidth 20

@interface ProjectTopicLabelView () <COTagViewDelegate>
{
    UITapGestureRecognizer *_singleTap;
}
@end

@implementation ProjectTopicLabelView

- (id)initWithFrame:(CGRect)frame projectTopic:(COTopic *)topic md:(BOOL)isMD
{
    self = [super initWithFrame:frame];
    if (self) {
        _labelH = 44;
        NSArray *labelAry = isMD ? topic.mdLabels : topic.labels;
        if (labelAry.count > 0) {
            CGFloat x = 0.0f;
            CGFloat y = 4.0f;
            CGFloat limitW = kCell_Width - kPaddingLeftWidth - 44 - 8;
            
            for (int i=0; i<labelAry.count; i++) {
                COTopicLabel *label = labelAry[i];
                COTagView *tLbl = [[COTagView alloc] initWithFrame:CGRectMake(x, y, 0, 0)];
                tLbl.delLabelDelegate = self;
                tLbl.tag = i;
                [tLbl setLabels:label];

                CGFloat width = tLbl.frame.size.width;
                if (x + width > limitW) {
                    y += 36.0f;
                    x = 0.0f;
                }
                [tLbl setFrame:CGRectMake(x, y, width, 36)];
                x += width;
                
                [self addSubview:tLbl];
            }
            _labelH = y + 36 + 4;
        } else {
            UIImageView *iconImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, (_labelH - 20) * 0.5, 20, 20)];
            [iconImg setImage:[UIImage imageNamed:@"icon_tag_none"]];
            
            UILabel *tLbl = [[UILabel alloc] initWithFrame:CGRectMake(25, (_labelH - 20) * 0.5, 40, 20)];
            
            tLbl.font = [UIFont systemFontOfSize:12];
            tLbl.text = @"标签";
            tLbl.textColor = [UIColor colorWithRed:59/255.0 green:189/255.0 blue:121/255.0 alpha:1.0];
            
            [self addSubview:iconImg];
            [self addSubview:tLbl];
        }
    }
    return self;
}

+ (CGFloat)heightWithObj:(COTopic *)topic md:(BOOL)isMD
{
    CGFloat labelH = 44;
    NSArray *labelAry = isMD ? topic.mdLabels : topic.labels;
    if (labelAry.count > 0) {
        CGFloat x = 0.0f;
        CGFloat y = 4.0f;
        CGFloat limitW = kCell_Width - kPaddingLeftWidth - 44 - 8;
        
        COTagView *tLbl = [[COTagView alloc] initWithFrame:CGRectMake(x, y, 0, 0)];
        
        for (int i=0; i<labelAry.count; i++) {
            COTopicLabel *label = labelAry[i];

            [tLbl setLabels:label];
            
            CGFloat width = tLbl.frame.size.width;
            if (x + width > limitW) {
                y += 36.0f;
                x = 0.0f;
            }
            x += width;
        }
        labelH = y + 36 + 4;
    }
    return labelH;
}

#pragma mark - COTagViewDelegate
- (void)delBtnClick:(COTagView *)label
{
    if (_delLabelBlock) {
        _delLabelBlock(label.tag);
    }
}


@end
