//
//  COFile+Ext.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/9/21.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COFile+Ext.h"
#import "Coding_FileManager.h"

@implementation COFile (Ext)

- (Coding_DownloadTask *)cDownloadTask{
    Coding_FileManager *manager = [Coding_FileManager sharedManager];
    return [manager cDownloadTaskForKey:self.storageKey];
}

- (DownloadState)downloadState{
    DownloadState state = DownloadStateDefault;
    if ([self hasBeenDownload]) {
        state = DownloadStateDownloaded;
    }else{
        Coding_DownloadTask *cDownloadTask = [self cDownloadTask];
        if (cDownloadTask) {
            if (cDownloadTask.task.state == NSURLSessionTaskStateRunning) {
                state = DownloadStateDownloading;
            }else if (cDownloadTask.task.state == NSURLSessionTaskStateSuspended) {
                state = DownloadStatePausing;
            }else{
                [[Coding_FileManager sharedManager] removeCDownloadTaskForKey:self.storageKey];
            }
        }
    }
    return state;
}

- (NSURL *)hasBeenDownload{
    Coding_FileManager *manager = [Coding_FileManager sharedManager];
    NSURL *fileUrl = [manager diskDownloadUrlForFile:self.diskFileName];
    return fileUrl;
}

- (NSString *)fileIconName{
    NSString *fileType = self.fileType;
    
    if (!fileType) {
        fileType = @"";
    }
    fileType = [fileType lowercaseString];
    NSString *iconName;
    //XXX(s)
    if ([fileType hasPrefix:@"doc"]) {
        iconName = @"icon_file_doc";
    }else if ([fileType hasPrefix:@"ppt"]) {
        iconName = @"icon_file_ppt";
    }else if ([fileType hasPrefix:@"pdf"]) {
        iconName = @"icon_file_pdf";
    }else if ([fileType hasPrefix:@"xls"]) {
        iconName = @"icon_file_xls";
    }
    //XXX
    else if ([fileType isEqualToString:@"txt"]) {
        iconName = @"icon_file_txt";
    }else if ([fileType isEqualToString:@"ai"]) {
        iconName = @"icon_file_ai";
    }else if ([fileType isEqualToString:@"apk"]) {
        iconName = @"icon_file_apk";
    }else if ([fileType isEqualToString:@"md"]) {
        iconName = @"icon_file_md";
    }else if ([fileType isEqualToString:@"psd"]) {
        iconName = @"icon_file_psd";
    }
    //XXX||YYY
    else if ([fileType isEqualToString:@"zip"] || [fileType isEqualToString:@"rar"] || [fileType isEqualToString:@"arj"]) {
        iconName = @"icon_file_zip";
    }else if ([fileType isEqualToString:@"html"]
              || [fileType isEqualToString:@"xml"]
              || [fileType isEqualToString:@"java"]
              || [fileType isEqualToString:@"h"]
              || [fileType isEqualToString:@"m"]
              || [fileType isEqualToString:@"cpp"]
              || [fileType isEqualToString:@"json"]
              || [fileType isEqualToString:@"cs"]
              || [fileType isEqualToString:@"go"]) {
        iconName = @"icon_file_code";
    }else if ([fileType isEqualToString:@"avi"]
              || [fileType isEqualToString:@"rmvb"]
              || [fileType isEqualToString:@"rm"]
              || [fileType isEqualToString:@"asf"]
              || [fileType isEqualToString:@"divx"]
              || [fileType isEqualToString:@"mpeg"]
              || [fileType isEqualToString:@"mpe"]
              || [fileType isEqualToString:@"wmv"]
              || [fileType isEqualToString:@"mp4"]
              || [fileType isEqualToString:@"mkv"]
              || [fileType isEqualToString:@"vob"]) {
        iconName = @"icon_file_movie";
    }else if ([fileType isEqualToString:@"mp3"]
              || [fileType isEqualToString:@"wav"]
              || [fileType isEqualToString:@"mid"]
              || [fileType isEqualToString:@"asf"]
              || [fileType isEqualToString:@"mpg"]
              || [fileType isEqualToString:@"tti"]) {
        iconName = @"icon_file_music";
    }
    //unknown
    else{
        iconName = @"icon_file_unknown";
    }
    return iconName;
}

@end
