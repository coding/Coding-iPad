//
//  COFile+Ext.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/9/21.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COFolder.h"

@interface COFile (Ext)

- (NSString *)fileIconName;
- (DownloadState)downloadState;
- (Coding_DownloadTask *)cDownloadTask;
- (NSURL *)hasBeenDownload;

@end
