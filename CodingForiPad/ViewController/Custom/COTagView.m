//
//  COTagView.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/22.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COTagView.h"
#import "COTopic.h"
#import "UIColor+Hex.h"

@interface COTagView ()
{
    UITapGestureRecognizer *_singleTap;
    UILongPressGestureRecognizer *_longPressTap;
}

@property (nonatomic, strong) UILabel *label;
@end

@implementation COTagView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    _label = [[UILabel alloc] initWithFrame:CGRectZero];
    _label.font = [UIFont systemFontOfSize:12];
    _label.textAlignment = NSTextAlignmentCenter;
  
    _label.textColor = [UIColor whiteColor];
    _label.layer.borderColor = [UIColor greenColor].CGColor;
    _label.layer.backgroundColor = [UIColor redColor].CGColor;
    _label.layer.cornerRadius = 16 * 0.5f;
    [self addSubview:_label];
    
//    _longPressTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressTapRecognized:)];
//    [self addGestureRecognizer:_longPressTap];
    
    _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapRecognized:)];
    [_singleTap setNumberOfTouchesRequired:1];
    [_singleTap setNumberOfTapsRequired:1];
    [self addGestureRecognizer:_singleTap];
    self.userInteractionEnabled = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideMenu) name:@"UIMenuControllerWillHideMenuNotification" object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setFrame:(CGRect)frame
{
   [super setFrame:frame];
    _label.frame = CGRectMake(5, 11, self.frame.size.width - 10, 16);
}

- (void)setLabels:(COTopicLabel *)labels
{
    if (labels) {
        _label.text = labels.name;
        UIColor *color = [UIColor colorWithHex:labels.color];
        _label.layer.backgroundColor = color.CGColor;
        _label.textColor = [UIColor whiteColor];
        CGFloat redValue, greenValue, blueValue, alphaValue;
        if ([color getRed:&redValue green:&greenValue blue:&blueValue alpha:&alphaValue]) {
            if (redValue > 0.6 && greenValue > 0.6 && blueValue > 0.6) {
                _label.textColor = [UIColor blackColor];
            }
        }
        [_label sizeToFit];
        CGRect frame = self.frame;
        frame.size.width = _label.frame.size.width + 30;
        frame.size.height = 36;
        self.frame = frame;
    }
}

- (void)hideMenu
{
    _label.layer.borderWidth = 0;
}

#pragma mark - Callbacks
- (void)longPressTapRecognized:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == _longPressTap) {
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            [self becomeFirstResponder];    // must be called even when NS_BLOCK_ASSERTIONS=0
            
            _label.layer.borderWidth = 1;
            
            UIMenuController *delMenu = [UIMenuController sharedMenuController];
            UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(delBtnClick:)];
            NSArray *menuItems = [NSArray arrayWithObjects:item, nil];
            [delMenu setMenuItems:menuItems];
            [delMenu setTargetRect:self.bounds inView:self];
            [delMenu setMenuVisible:YES animated:YES];
        }
    }
}

- (void)singleTapRecognized:(UITapGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == _singleTap) {
        if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
            [self becomeFirstResponder];    // must be called even when NS_BLOCK_ASSERTIONS=0
            
            _label.layer.borderWidth = 1;
            
            UIMenuController *delMenu = [UIMenuController sharedMenuController];
            UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(delBtnClick:)];
            NSArray *menuItems = [NSArray arrayWithObjects:item, nil];
            [delMenu setMenuItems:menuItems];
            [delMenu setTargetRect:self.bounds inView:self];
            [delMenu setMenuVisible:YES animated:YES];
        }
    }
}

#pragma mark - UIResponder

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    BOOL retValue = NO;
    if (action == @selector(delBtnClick:)) {
        retValue = YES;
    } else {
        // Pass the canPerformAction:withSender: message to the superclass
        // and possibly up the responder chain.
        retValue = [super canPerformAction:action withSender:sender];
    }
    
    return retValue;
}

- (IBAction)delBtnClick:(id)sender
{
    self.layer.borderWidth = 0;
    
    if (self.delLabelDelegate && [self.delLabelDelegate respondsToSelector:@selector(delBtnClick:)]) {
        [self.delLabelDelegate delBtnClick:self];
    }
}

@end
