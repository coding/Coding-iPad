//
//  FileViewController.h
//  Coding_iOS
//
//  Created by Ease on 14/12/15.
//  Copyright (c) 2014年 Coding. All rights reserved.
//
#import <QuickLook/QuickLook.h>
#import "COBaseViewController.h"
#import "COFolder.h"
//#import "ProjectFolders.h"
//#import "ProjectFile.h"

@interface FileViewController : COBaseViewController
@property (strong, nonatomic) COFile *curFile;
@property (nonatomic, weak) IBOutlet UIView *headView;
@end
