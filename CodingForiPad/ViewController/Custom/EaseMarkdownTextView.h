//
//  EaseMarkdownTextView.h
//  Coding_iOS
//
//  Created by Ease on 15/2/9.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COPlaceHolderTextView.h"

@class COProject;
@interface EaseMarkdownTextView : COPlaceHolderTextView

@property (strong, nonatomic) COProject *curProject;

@property (copy, nonatomic) void(^atBlock)();

@end
