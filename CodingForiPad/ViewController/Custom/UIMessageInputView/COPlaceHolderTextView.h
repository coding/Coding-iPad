//
//  COInputTextView.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/22.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kInputTextHeightMax 260
#define kInputTextHeightMin 20

@interface COPlaceHolderTextView : UITextView

@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) UIColor *placeholderColor;
@property (nonatomic, assign) NSInteger type;// 1为输入框 0为其他

- (void)textChanged:(NSNotification *)notification;

@end
