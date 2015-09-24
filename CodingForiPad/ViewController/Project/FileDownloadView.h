//
//  FileDownloadView.h
//  Coding_iOS
//
//  Created by Ease on 14/12/16.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "COFolder.h"

@interface FileDownloadView : UIView
@property (strong, nonatomic) COFile *file;
@property (nonatomic,copy) void(^completionBlock)();
@property (nonatomic,copy) void(^goToFileBlock)(COFile *file);
@end
