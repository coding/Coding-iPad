//
//  EaseStartView.m
//  Coding_iOS
//
//  Created by Ease on 14/12/26.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "EaseStartView.h"
#import <NYXImagesKit/NYXImagesKit.h>
#import "StartImagesManager.h"
#import "Masonry.h"
#import "UIView+Extension.h"
#import "UIImage+Common.h"

@interface EaseStartView ()

@property (strong, nonatomic) UIImageView *bgImageView, *logoIconView;
@property (strong, nonatomic) UILabel *descriptionStrLabel;

@end

@implementation EaseStartView

+ (instancetype)startView
{
    UIImage *logoIcon = [UIImage imageNamed:@"logo_coding_top"];
    StartImage *st = [[StartImagesManager shareManager] randomImage];
    return [[self alloc] initWithBgImage:st.image logoIcon:logoIcon descriptionStr:st.descriptionStr];
}

- (instancetype)initWithBgImage:(UIImage *)bgImage
                       logoIcon:(UIImage *)logoIcon
                 descriptionStr:(NSString *)descriptionStr
{
    self = [super initWithFrame:kScreen_Bounds];
    if (self) {
        //add custom code
        UIColor *blackColor = [UIColor blackColor];
        self.backgroundColor = blackColor;
        
        _bgImageView = [[UIImageView alloc] initWithFrame:kScreen_Bounds];
        _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
        _bgImageView.alpha = 0.0;
        [self addSubview:_bgImageView];
        
        [self addGradientLayerWithColors:@[(id)[blackColor colorWithAlphaComponent:0.4].CGColor, (id)[blackColor colorWithAlphaComponent:0.0].CGColor]
                               locations:nil
                              startPoint:CGPointMake(0.5, 0.0)
                                endPoint:CGPointMake(0.5, 0.4)];

        _logoIconView = [[UIImageView alloc] init];
        _logoIconView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_logoIconView];
        _descriptionStrLabel = [[UILabel alloc] init];
        _descriptionStrLabel.font = [UIFont systemFontOfSize:10];
        _descriptionStrLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        _descriptionStrLabel.textAlignment = NSTextAlignmentCenter;
        _descriptionStrLabel.alpha = 0.0;
        [self addSubview:_descriptionStrLabel];
        
        [_descriptionStrLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(@[self, _logoIconView]);
            make.height.mas_equalTo(10);
            make.bottom.equalTo(self.mas_bottom).offset(-15);
            make.left.equalTo(self.mas_left).offset(20);
            make.right.equalTo(self.mas_right).offset(-20);
        }];

        [_logoIconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.mas_equalTo(kScreen_Height/5*4 - 25);
            make.width.mas_equalTo(kScreen_Width/3.5f);
            make.height.mas_equalTo(kScreen_Width/3.5f *5/22);
        }];
        
        [self configWithBgImage:bgImage logoIcon:logoIcon descriptionStr:descriptionStr];
    }
    return self;
}

- (CGSize)doubleSizeOfFrame
{
    CGSize size = self.frame.size;
    return CGSizeMake(size.width*2, size.height*2);
}

- (void)configWithBgImage:(UIImage *)bgImage
                 logoIcon:(UIImage *)logoIcon
           descriptionStr:(NSString *)descriptionStr
{
    CGSize size = _bgImageView.frame.size;
    bgImage = [bgImage scaleToSize:CGSizeMake(size.width*2, size.height*2) usingMode:NYXResizeModeAspectFill];
    self.bgImageView.image = bgImage;
    self.logoIconView.image = logoIcon;
    self.descriptionStrLabel.text = descriptionStr;
    [self updateConstraintsIfNeeded];
    [self layoutIfNeeded];
}

- (void)startAnimationWithCompletionBlock:(void(^)(EaseStartView *easeStartView))completionHandler
{
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view bringSubviewToFront:self];
    _bgImageView.alpha = 0.0;
    _logoIconView.alpha = 1.0;
    _descriptionStrLabel.alpha = 0.0;
    self.alpha = 1.0;
    
    __weak typeof(self) weakself = self;
    [UIView animateWithDuration:2.0 animations:^{
        weakself.bgImageView.alpha = 1.0;
        [weakself.bgImageView setFrame:CGRectMake(-kScreen_Width/20, -kScreen_Height/20, 1.1*kScreen_Width, 1.1*kScreen_Height)];
        weakself.descriptionStrLabel.alpha = 1.0;
    } completion:^(BOOL finished) {
        weakself.backgroundColor = [UIColor clearColor];
        [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            weakself.bgImageView.alpha = 0.0;
            weakself.logoIconView.alpha = 0.0;
            weakself.descriptionStrLabel.alpha = 0.0;
            weakself.alpha = 0.0;
        } completion:^(BOOL finished) {
            [weakself removeFromSuperview];
            if (completionHandler) {
                completionHandler(weakself);
            }
        }];
    }];
}

- (void)addGradientLayerWithColors:(NSArray *)cgColorArray
                         locations:(NSArray *)floatNumArray
                        startPoint:(CGPoint )startPoint
                          endPoint:(CGPoint)endPoint
{
    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.frame = self.bounds;
    if (cgColorArray && [cgColorArray count] > 0) {
        layer.colors = cgColorArray;
    }else{
        return;
    }
    if (floatNumArray && [floatNumArray count] == [cgColorArray count]) {
        layer.locations = floatNumArray;
    }
    layer.startPoint = startPoint;
    layer.endPoint = endPoint;
    [self.layer addSublayer:layer];
}

@end
