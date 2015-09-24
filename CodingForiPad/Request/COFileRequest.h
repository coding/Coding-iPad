//
//  COFileRequest.h
//  CodingModels
//
//  Created by sunguanglei on 15/6/3.
//  Copyright (c) 2015年 sgl. All rights reserved.
//

#import "CODataRequest.h"

COGetRequest
@interface COFoldersRequest : COPageRequest

@property (nonatomic, assign) COUriParameters NSInteger projectId;

@end

COGetRequest
@interface COFoldersCountRequest : CODataRequest

@property (nonatomic, assign) COUriParameters NSInteger projectId;

@end

COGetRequest
@interface COFolderFilesRequest : COPageRequest

@property (nonatomic, assign) COUriParameters NSInteger projectId;
@property (nonatomic, assign) COUriParameters NSInteger folderId;

@property (nonatomic, strong) COQueryParameters NSNumber *height;
@property (nonatomic, strong) COQueryParameters NSNumber *width;

@end

COGetRequest
@interface COFileDetailRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSNumber *projectId;
@property (nonatomic, copy) COUriParameters NSNumber *fileId;

@end

COPostRequest
@interface COCreateFolderRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSNumber *projectId;
@property (nonatomic, copy) COFormParameters NSNumber *parentId;
@property (nonatomic, copy) COFormParameters NSString *name;

@end

COPutRequest
@interface CORenameFolderRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSNumber *projectId;
@property (nonatomic, copy) COUriParameters NSNumber *folderId;
@property (nonatomic, copy) COUriParameters NSString *name;

@end

COPutRequest
@interface COMoveFileRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSNumber *projectId;
@property (nonatomic, copy) COUriParameters NSNumber *destFolderId;
@property (nonatomic, copy) COFormParameters NSString *fileIds;

@end

CODeleteRequest
@interface CODeleteFolderRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSNumber *projectId;
@property (nonatomic, copy) COUriParameters NSNumber *folderId;

@end

CODeleteRequest
@interface CODeleteFileRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSNumber *projectId;
@property (nonatomic, copy) COFormParameters NSString *fileIds;

@end