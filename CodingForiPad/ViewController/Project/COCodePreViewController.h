//
//  COCodePreViewController.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/28.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COBaseViewController.h"
#import "COGitTree.h"
#import "COProject.h"

@interface COCodePreViewController : COBaseViewController<UIWebViewDelegate>

@property (nonatomic, strong) COProject *project;
@property (nonatomic, strong) COGitFile *gitFile;
@property (nonatomic, strong) NSString *ref;
@property (nonatomic, strong) NSString *backendProjectPath;

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@end
