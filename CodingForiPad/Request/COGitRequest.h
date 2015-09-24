//
//  COGitRequest.h
//  CodingModels
//
//  Created by sunguanglei on 15/6/3.
//  Copyright (c) 2015年 sgl. All rights reserved.
//

#import "CODataRequest.h"

@interface COGitTreeRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSString *gloabKey;
@property (nonatomic, copy) COUriParameters NSString *project;
@property (nonatomic, copy) COUriParameters NSString *ref;
@property (nonatomic, copy) COUriParameters NSString *filePath;
@property (nonatomic, copy) COUriParameters NSString *backendProjectPath;

@end

@interface COGitTreeInfosRequest : CODataRequest

//@property (nonatomic, copy) COUriParameters NSString *gloabKey;
//@property (nonatomic, copy) COUriParameters NSString *project;
@property (nonatomic, copy) COUriParameters NSString *ref;
@property (nonatomic, copy) COUriParameters NSString *filePath;
@property (nonatomic, copy) COUriParameters NSString *backendProjectPath;

@end

@interface COGitTreeFileRequest : CODataRequest

//@property (nonatomic, copy) COUriParameters NSString *gloabKey;
//@property (nonatomic, copy) COUriParameters NSString *project;
@property (nonatomic, copy) COUriParameters NSString *ref;
@property (nonatomic, copy) COUriParameters NSString *filePath;
@property (nonatomic, copy) COUriParameters NSString *backendProjectPath;

@end

@interface COGitListBranchesRequest : CODataRequest

//@property (nonatomic, copy) COUriParameters NSString *gloabKey;
//@property (nonatomic, copy) COUriParameters NSString *project;
@property (nonatomic, copy) COUriParameters NSString *backendProjectPath;

@end

@interface COGitListTagsRequest : CODataRequest

//@property (nonatomic, copy) COUriParameters NSString *gloabKey;
//@property (nonatomic, copy) COUriParameters NSString *project;
@property (nonatomic, copy) COUriParameters NSString *backendProjectPath;

@end
