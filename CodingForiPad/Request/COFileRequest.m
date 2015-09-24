//
//  COFileRequest.m
//  CodingModels
//
//  Created by sunguanglei on 15/6/3.
//  Copyright (c) 2015年 sgl. All rights reserved.
//

#import "COFileRequest.h"
#import "COFolder.h"

@implementation COFoldersRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/project/%ld/all_folders", (long)self.projectId];
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COFolder class] responseType:CODataResponseTypePage];
}

@end

@implementation COFoldersCountRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/project/%ld/folders/all_file_count", (long)self.projectId];
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COFileCount class] responseType:CODataResponseTypeList];
}

@end

@implementation COFolderFilesRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/project/%ld/files/%ld", (long)self.projectId, (long)self.folderId];
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COFile class] responseType:CODataResponseTypePage];
}

@end

@implementation COFileDetailRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/project/%@/files/%@/view", self.projectId, self.fileId];
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COFileView class] responseType:CODataResponseTypeDefault];
}

@end

@implementation COCreateFolderRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/project/%@/mkdir", self.projectId];
}

- (NSDictionary *)parametersMap
{
    return @{@"name" : @"name",
             @"parentId" : @"parentId"};
}

@end

@implementation CORenameFolderRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/project/%@/dir/%@/name/%@", self.projectId, self.folderId, self.name];
}

@end

@implementation COMoveFileRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/project/%@/files/moveto/%@", self.projectId, self.destFolderId];
}

- (NSDictionary *)parametersMap
{
    return @{@"fileIds" : @"fileId"};
}

@end

@implementation CODeleteFolderRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/project/%@/rmdir/%@", self.projectId, self.folderId];
}

@end

@implementation CODeleteFileRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/project/%@/file/delete", self.projectId];
}

- (NSDictionary *)parametersMap
{
    return @{@"fileIds" : @"fileIds"};
}

@end
