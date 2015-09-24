//
//  COSegmentControl.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/22.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COSegmentControl.h"

#define kHspace (15)
#define kLineHeight (1)
#define kAnimationTime (0.3)
#define kHorizontalLineH (0)
#define kVerticalLineSpace (5)

@interface WMSegmentControlItem : UILabel

@property (nonatomic, strong) UILabel *titleLabel;

- (void)setSelected:(BOOL)selected;
- (void)resetTitle:(NSString *)title;

@end

@implementation WMSegmentControlItem

- (id)initWithFrame:(CGRect)frame title:(NSString *)title
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        _titleLabel = ({
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kHspace, 0, CGRectGetWidth(self.bounds) - 2 * kHspace, CGRectGetHeight(self.bounds))];
            label.font = [UIFont boldSystemFontOfSize:kTextFont];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = title;
            label.textColor = kTextColor;
            label.backgroundColor = [UIColor clearColor];
            label;
        });
        
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _titleLabel.frame = CGRectMake(kHspace, 0, CGRectGetWidth(self.bounds) - 2 * kHspace, CGRectGetHeight(self.bounds));
}

- (void)setSelected:(BOOL)selected
{
    [_titleLabel setTextColor:(selected ? kLineColor : kTextColor)];
}

- (void)resetTitle:(NSString *)title
{
    _titleLabel.text = title;
}

@end

@interface COSegmentControl () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *contentView;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIView *bottomLineView;
@property (nonatomic, strong) NSMutableArray *itemFrames;
@property (nonatomic, strong) NSMutableArray *itemViews;

@property (nonatomic, copy) COSegmentControlBlock block;

@end

@implementation COSegmentControl
- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_contentView) {
        _contentView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        _contentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        _bottomLineView.frame = CGRectMake(0, CGRectGetHeight(self.frame) - kHorizontalLineH, CGRectGetWidth(self.frame), kHorizontalLineH);
        
        float x = 0;
        float height = CGRectGetHeight(self.bounds);
        float width = self.frame.size.width / _itemViews.count;
        for (int i = 0; i < _itemViews.count; i++) {
            CGRect rect = CGRectMake(x, 0, width, height);
            x += width;
            
            [_itemFrames replaceObjectAtIndex:i withObject:[NSValue valueWithCGRect:rect]];
            
            WMSegmentControlItem *item = _itemViews[i];
            item.frame = rect;
            if (i == _currentIndex) {
                CGRect lineRect = CGRectMake(CGRectGetMinX(rect) + kHspace, CGRectGetHeight(rect) - kLineHeight - kHorizontalLineH, CGRectGetWidth(rect) - 2 * kHspace, kLineHeight);
                _lineView.frame = lineRect;
            }
        }
    }
}

- (void)initUI
{
    if (!_contentView) {
        _contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        _contentView.backgroundColor = [UIColor clearColor];
        _contentView.delegate = self;
        _contentView.showsHorizontalScrollIndicator = NO;
        _contentView.scrollsToTop = NO;
        [self addSubview:_contentView];
        
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doTap:)];
        [_contentView addGestureRecognizer:tapGes];
        [tapGes requireGestureRecognizerToFail:_contentView.panGestureRecognizer];
        
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = kLineColor;
        [_contentView addSubview:_lineView];
        
        _bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - kHorizontalLineH, CGRectGetWidth(self.bounds), kHorizontalLineH)];
        _bottomLineView.backgroundColor = kHLineColor;
        [self addSubview:_bottomLineView];
    }
}

- (void)setItemsWithTitleArray:(NSArray *)titleArray selectedBlock:(COSegmentControlBlock)selectedHandle
{
    self.block = selectedHandle;
    [self setItemsWithTitleArray:titleArray];
}

- (void)setItemsWithTitleArray:(NSArray *)titleArray
{
    [self initUI];
    if (_itemViews.count > 0) {
        for (WMSegmentControlItem *item in _itemViews) {
            [item removeFromSuperview];
        }
    }
    
    _itemFrames = @[].mutableCopy;
    _itemViews = @[].mutableCopy;
    
    float x = 0;
    float height = CGRectGetHeight(self.bounds);
    float width = self.frame.size.width / titleArray.count;
    for (int i = 0; i < titleArray.count; i++) {
        CGRect rect = CGRectMake(x, 0, width, height);
        x += width;
        [_itemFrames addObject:[NSValue valueWithCGRect:rect]];
        
        NSString *title = titleArray[i];
        WMSegmentControlItem *item = [[WMSegmentControlItem alloc] initWithFrame:rect title:title];
        if (i == 0) {
            [item setSelected:YES];
            CGRect lineRect = CGRectMake(CGRectGetMinX(rect) + kHspace, CGRectGetHeight(rect) - kLineHeight - kHorizontalLineH, CGRectGetWidth(rect) - 2 * kHspace, kLineHeight);
            _lineView.frame = lineRect;
        }
        [_itemViews addObject:item];
        [_contentView addSubview:item];
    }
    
    [_contentView setContentSize:CGSizeMake(CGRectGetMaxX([[_itemFrames lastObject] CGRectValue]), CGRectGetHeight(self.bounds))];
    _currentIndex = -1;
    [self selectIndex:0];
}

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    currentIndex = MAX(0, MIN(currentIndex, _itemViews.count));
    
    if (currentIndex != _currentIndex) {
        WMSegmentControlItem *preItem = [_itemViews objectAtIndex:_currentIndex];
        WMSegmentControlItem *curItem = [_itemViews objectAtIndex:currentIndex];
        [preItem setSelected:NO];
        [curItem setSelected:YES];
        _currentIndex = currentIndex;
    }
}

- (void)selectIndex:(NSInteger)index
{
    if (index != _currentIndex) {
        WMSegmentControlItem *curItem = [_itemViews objectAtIndex:index];
        CGRect rect = [_itemFrames[index] CGRectValue];
        CGRect lineRect = CGRectMake(CGRectGetMinX(rect) + kHspace, CGRectGetHeight(rect) - kLineHeight - kHorizontalLineH, CGRectGetWidth(rect) - 2 * kHspace, kLineHeight);

        _currentIndex = index;
        [UIView animateWithDuration:kAnimationTime animations:^{
            _lineView.frame = lineRect;
        } completion:^(BOOL finished) {
            [_itemViews enumerateObjectsUsingBlock:^(WMSegmentControlItem *item, NSUInteger idx, BOOL *stop) {
                [item setSelected:NO];
            }];
            [curItem setSelected:YES];
        }];
    }
}

- (void)setTitle:(NSString *)title withIndex:(NSInteger)index
{
    WMSegmentControlItem *curItem = [_itemViews objectAtIndex:index];
    [curItem resetTitle:title];
}

- (void)moveIndexWithProgress:(float)progress
{
    progress = MAX(0, MIN(progress, _itemViews.count));
    
    float delta = progress - _currentIndex;
    
    CGRect origionRect = [_itemFrames[_currentIndex] CGRectValue];;
    
    CGRect origionLineRect = CGRectMake(CGRectGetMinX(origionRect) + kHspace, CGRectGetHeight(origionRect) - kLineHeight - kHorizontalLineH, CGRectGetWidth(origionRect) - 2 * kHspace, kLineHeight);
    
    CGRect rect;
    
    if (delta > 0) {
        // 如果delta大于1的话，不能简单的用相邻item间距的乘法来计算距离
        if (delta > 1) {
            self.currentIndex += floorf(delta);
            delta -= floorf(delta);
            origionRect = [_itemFrames[_currentIndex] CGRectValue];;
            origionLineRect = CGRectMake(CGRectGetMinX(origionRect) + kHspace, CGRectGetHeight(origionRect) - kLineHeight - kHorizontalLineH, CGRectGetWidth(origionRect) - 2 * kHspace, kLineHeight);
        }
        
        if (_currentIndex == _itemFrames.count - 1) {
            return;
        }
        
        rect = [_itemFrames[_currentIndex + 1] CGRectValue];
        
        CGRect lineRect = CGRectMake(CGRectGetMinX(rect) + kHspace, CGRectGetHeight(rect) - kLineHeight - kHorizontalLineH, CGRectGetWidth(rect) - 2 * kHspace, kLineHeight);
        
        CGRect moveRect = CGRectZero;
        
        moveRect.size = CGSizeMake(CGRectGetWidth(origionLineRect) + delta * (CGRectGetWidth(lineRect) - CGRectGetWidth(origionLineRect)), CGRectGetHeight(lineRect));
        moveRect.origin = CGPointMake(CGRectGetMidX(origionLineRect) + delta * (CGRectGetMidX(lineRect) - CGRectGetMidX(origionLineRect)) - CGRectGetMidX(moveRect), CGRectGetMidY(origionLineRect) - CGRectGetMidY(moveRect));
        _lineView.frame = moveRect;
    } else if (delta < 0){
        
        if (_currentIndex == 0) {
            return;
        }
        rect = [_itemFrames[_currentIndex - 1] CGRectValue];
        CGRect lineRect = CGRectMake(CGRectGetMinX(rect) + kHspace, CGRectGetHeight(rect) - kLineHeight - kHorizontalLineH, CGRectGetWidth(rect) - 2 * kHspace, kLineHeight);
        CGRect moveRect = CGRectZero;
        moveRect.size = CGSizeMake(CGRectGetWidth(origionLineRect) - delta * (CGRectGetWidth(lineRect) - CGRectGetWidth(origionLineRect)), CGRectGetHeight(lineRect));
        moveRect.origin = CGPointMake(CGRectGetMidX(origionLineRect) - delta * (CGRectGetMidX(lineRect) - CGRectGetMidX(origionLineRect)) - CGRectGetMidX(moveRect), CGRectGetMidY(origionLineRect) - CGRectGetMidY(moveRect));
        _lineView.frame = moveRect;
        if (delta < -1) {
            self.currentIndex -= 1;
        }
    }
}

#pragma mark - private
- (void)doTap:(UITapGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:sender.view];
    
    __weak typeof(self) weakSelf = self;
    
    [_itemFrames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        CGRect rect = [obj CGRectValue];
        
        if (CGRectContainsPoint(rect, point)) {
            
            [weakSelf selectIndex:idx];
            
            [weakSelf transformAction:idx];
            
            *stop = YES;
        }
    }];
}

- (void)transformAction:(NSInteger)index
{
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(COSegmentControlDelegate)] && [self.delegate respondsToSelector:@selector(segmentControl:selectedIndex:)]) {
        
        [self.delegate segmentControl:self selectedIndex:index];
        
    } else if (self.block) {
        
        self.block(index);
    }
}

@end

