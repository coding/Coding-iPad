//
//  SegmentControl.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/22.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COIconSegmentControl.h"
#import "COUtility.h"
#import "UIImageView+WebCache.h"

#define kControlHspace (0)
#define kLineHeight (1)
#define kAnimationTime (0.3)
#define kHorizontalLineH (0)

@interface XTIconSegControlItem : UIView

@property (nonatomic, strong) UIImageView *iconView;

- (void)setSelected:(BOOL)selected;

@end

@implementation XTIconSegControlItem

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.bounds) - kIconWidth) * 0.5,
                                                                  (CGRectGetHeight(self.bounds)- kIconHeight) * 0.5, kIconWidth, kIconHeight)];
        _iconView.layer.masksToBounds = YES;
        _iconView.layer.cornerRadius = kIconWidth * 0.5;
        _iconView.layer.borderWidth = 0.5;
        _iconView.layer.borderColor = [UIColor whiteColor].CGColor;
        [self addSubview:_iconView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected
{
}

@end

@interface COIconSegmentControl () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *contentView;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIView *bottomLineView;
@property (nonatomic, strong) NSMutableArray *itemFrames;
@property (nonatomic, strong) NSMutableArray *itemViews;

@property (nonatomic, copy) COIconSegmentControlBlock block;

@end

@implementation COIconSegmentControl
- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_contentView) {
        _contentView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        _contentView.frame = self.bounds;
        _bottomLineView.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - kHorizontalLineH, CGRectGetWidth(self.bounds), kHorizontalLineH);
    }
}

- (void)initUI
{
    if (!_contentView) {
        _contentView = [[UIScrollView alloc] initWithFrame:self.bounds];
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

- (void)setItemsWithIconArray:(NSArray *)iconArray selectedBlock:(COIconSegmentControlBlock)selectedHandle
{
    self.block = selectedHandle;
    [self setItemsWithIconArray:iconArray];
}

- (void)setItemsWithIconArray:(NSArray *)iconArray
{
    [self initUI];
    if (_itemViews.count > 0) {
        for (XTIconSegControlItem *item in _itemViews) {
            [item removeFromSuperview];
        }
    }
    
    _itemFrames = @[].mutableCopy;
    _itemViews = @[].mutableCopy;
    float y = 0;
    float height = CGRectGetHeight(self.bounds);
    
    for (int i = 0; i < iconArray.count; i++) {
        float x = i > 0 ? CGRectGetMaxX([_itemFrames[i-1] CGRectValue]) : 0;
        CGRect rect = CGRectMake(x, y, kItemWidth, height);
        [_itemFrames addObject:[NSValue valueWithCGRect:rect]];

        NSString *iconPath = iconArray[i];
        XTIconSegControlItem *item = [[XTIconSegControlItem alloc] initWithFrame:rect];
        if (iconPath.length > 0) {
            [item.iconView sd_setImageWithURL:[COUtility urlForImage:iconPath] placeholderImage:[COUtility placeHolder]];
        } else {
            [item.iconView setImage:kIconDefault];
        }
        
        if (i == 0) {
            [item setSelected:YES];
            CGRect lineRect = CGRectMake(CGRectGetMinX(rect) + kControlHspace, CGRectGetHeight(rect) - kLineHeight - kHorizontalLineH, CGRectGetWidth(rect) - 2 * kControlHspace, kLineHeight);
            _lineView.frame = lineRect;
        }
        [_itemViews addObject:item];
        [_contentView addSubview:item];
    }
    
    [_contentView setContentSize:CGSizeMake(CGRectGetMaxX([[_itemFrames lastObject] CGRectValue]), CGRectGetHeight(self.bounds))];
    _currentIndex = -1;
    [self selectIndex:0];
}

- (void)selectIndex:(NSInteger)index
{   
    if (index != _currentIndex) {
        XTIconSegControlItem *curItem = [_itemViews objectAtIndex:index];
        CGRect rect = [_itemFrames[index] CGRectValue];
        CGRect lineRect = CGRectMake(CGRectGetMinX(rect) + kControlHspace, CGRectGetHeight(rect) - kLineHeight - kHorizontalLineH, CGRectGetWidth(rect) - 2 * kControlHspace, kLineHeight);

        [UIView animateWithDuration:kAnimationTime animations:^{
            _lineView.frame = lineRect;
        } completion:^(BOOL finished) {
            [_itemViews enumerateObjectsUsingBlock:^(XTIconSegControlItem *item, NSUInteger idx, BOOL *stop) {
                [item setSelected:NO];
            }];
            [curItem setSelected:YES];
            _currentIndex = index;
        }];
    }
    [self setScrollOffset:index];
}

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    currentIndex = MAX(0, MIN(currentIndex, _itemViews.count));
    
    if (currentIndex != _currentIndex) {
        XTIconSegControlItem *preItem = [_itemViews objectAtIndex:_currentIndex];
        XTIconSegControlItem *curItem = [_itemViews objectAtIndex:currentIndex];
        [preItem setSelected:NO];
        [curItem setSelected:YES];
        _currentIndex = currentIndex;
    }
}

- (void)moveIndexWithProgress:(float)progress
{
    progress = MAX(0, MIN(progress, _itemViews.count));
    
    float delta = progress - _currentIndex;
    
    CGRect origionRect = [_itemFrames[_currentIndex] CGRectValue];;
    
    CGRect origionLineRect = CGRectMake(CGRectGetMinX(origionRect) + kControlHspace, CGRectGetHeight(origionRect) - kLineHeight - kHorizontalLineH, CGRectGetWidth(origionRect) - 2 * kControlHspace, kLineHeight);
    
    CGRect rect;
    
    if (delta > 0) {
        // 如果delta大于1的话，不能简单的用相邻item间距的乘法来计算距离
        if (delta > 1) {
            self.currentIndex += floorf(delta);
            delta -= floorf(delta);
            origionRect = [_itemFrames[_currentIndex] CGRectValue];;
            origionLineRect = CGRectMake(CGRectGetMinX(origionRect) + kControlHspace, CGRectGetHeight(origionRect) - kLineHeight - kHorizontalLineH, CGRectGetWidth(origionRect) - 2 * kControlHspace, kLineHeight);
        }
        
        if (_currentIndex == _itemFrames.count - 1) {
            return;
        }
        
        rect = [_itemFrames[_currentIndex + 1] CGRectValue];
        
        CGRect lineRect = CGRectMake(CGRectGetMinX(rect) + kControlHspace, CGRectGetHeight(rect) - kLineHeight - kHorizontalLineH, CGRectGetWidth(rect) - 2 * kControlHspace, kLineHeight);
        
        CGRect moveRect = CGRectZero;
        
        moveRect.size = CGSizeMake(CGRectGetWidth(origionLineRect) + delta * (CGRectGetWidth(lineRect) - CGRectGetWidth(origionLineRect)), CGRectGetHeight(lineRect));
        moveRect.origin = CGPointMake(CGRectGetMidX(origionLineRect) + delta * (CGRectGetMidX(lineRect) - CGRectGetMidX(origionLineRect)) - CGRectGetMidX(moveRect), CGRectGetMidY(origionLineRect) - CGRectGetMidY(moveRect));
        _lineView.frame = moveRect;
    } else if (delta < 0) {
        
        if (_currentIndex == 0) {
            return;
        }
        rect = [_itemFrames[_currentIndex - 1] CGRectValue];
        CGRect lineRect = CGRectMake(CGRectGetMinX(rect) + kControlHspace, CGRectGetHeight(rect) - kLineHeight - kHorizontalLineH, CGRectGetWidth(rect) - 2 * kControlHspace, kLineHeight);
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
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(COIconSegmentControlDelegate)] && [self.delegate respondsToSelector:@selector(segmentControl:selectedIndex:)]) {
        
        [self.delegate segmentControl:self selectedIndex:index];
        
    } else if (self.block) {
        
        self.block(index);
    }
}

- (void)setScrollOffset:(NSInteger)index
{
    if (_contentView.contentSize.width <= self.frame.size.width) {
        return;
    }
    
    CGRect rect = [_itemFrames[index] CGRectValue];

    float midX = CGRectGetMidX(rect);
    
    float offset = 0;
    
    float contentWidth = _contentView.contentSize.width;
    
    float halfWidth = CGRectGetWidth(self.bounds) / 2.0;
    
    if (midX < halfWidth) {
        offset = 0;
    } else if (midX > contentWidth - halfWidth) {
        offset = contentWidth - 2 * halfWidth;
    } else {
        offset = midX - halfWidth;
    }
    
    [UIView animateWithDuration:kAnimationTime animations:^{
        [_contentView setContentOffset:CGPointMake(offset, 0) animated:NO];
    }];
}

@end

