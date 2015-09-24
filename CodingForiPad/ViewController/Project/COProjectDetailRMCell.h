//
//  OPProjectDetailRMCell.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/14.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COProject.h"
#import "COGitTree.h"

typedef void(^COReadMeCellHeightChangeBlock)(CGFloat newHeight);

@interface COProjectDetailRMCell : UITableViewCell<UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webViewHegiht;

@property (nonatomic, assign) CGFloat contentHeight;

@property (nonatomic, copy) COReadMeCellHeightChangeBlock heightChangeBlock;
@property (nonatomic, copy) void (^loadRequestBlock)(NSURLRequest *curRequest);

+ (CGFloat)cellHeight;

- (void)showReadMe:(COGitTree *)tree;

+ (COProjectDetailRMCell *)cellWithTableView:(UITableView *)tableView;

@end
