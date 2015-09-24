//
//  COCodeView.h
//  CodingForiPad
//
//  Created by sgl on 15/6/29.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COProject.h"
#import "COGitTree.h"

@interface COCodeView : UIView

@property (nonatomic, strong) NSString  *ref;
@property (nonatomic, strong) COProject *project;
@property (nonatomic, strong) COGitFile *gitFile;

@property (nonatomic, assign) CGFloat contentHeight;

- (void)load;

@end
