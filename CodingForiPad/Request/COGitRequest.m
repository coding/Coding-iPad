//
//  COGitRequest.m
//  CodingModels
//
//  Created by sunguanglei on 15/6/3.
//  Copyright (c) 2015年 sgl. All rights reserved.
//

#import "COGitRequest.h"
#import "COGitTree.h"

@implementation COGitTreeRequest

- (void)prepareForRequest
{
    if (self.filePath) {
//        self.path = [NSString stringWithFormat: @"/user/%@/project/%@/git/tree/%@/%@", self.gloabKey, self.project, self.ref, self.filePath];
        self.path = [NSString stringWithFormat:@"%@/git/tree/%@/%@", self.backendProjectPath, self.ref, self.filePath];
    }
    else {
//        self.path = [NSString stringWithFormat: @"/user/%@/project/%@/git/tree/%@/", self.gloabKey, self.project, self.ref];
        self.path = [NSString stringWithFormat:@"%@/git/tree/%@/", self.backendProjectPath, self.ref];
    }
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COGitTree class] responseType:CODataResponseTypeDefault];
}

@end

@implementation COGitTreeInfosRequest

- (void)prepareForRequest
{
    if (self.filePath) {
//        self.path = [NSString stringWithFormat: @"/user/%@/project/%@/git/treeinfo/%@/%@", self.gloabKey, self.project, self.ref, self.filePath];
        self.path = [NSString stringWithFormat:@"%@/git/treeinfo/%@/%@", self.backendProjectPath, self.ref, self.filePath];
    }
    else {
//        self.path = [NSString stringWithFormat: @"/user/%@/project/%@/git/treeinfo/%@/", self.gloabKey, self.project, self.ref];
        self.path = [NSString stringWithFormat:@"%@/git/treeinfo/%@/", self.backendProjectPath, self.ref];
    }
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COGitTreeInfo class] responseType:CODataResponseTypeDefault];
}

@end

@implementation COGitTreeFileRequest

- (void)prepareForRequest
{
//    self.path = [NSString stringWithFormat: @"/user/%@/project/%@/git/blob/%@/%@", self.gloabKey, self.project, self.ref, self.filePath];
    self.path = [NSString stringWithFormat:@"%@/git/blob/%@/%@", self.backendProjectPath, self.ref, self.filePath];
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COGitBlob class] responseType:CODataResponseTypeDefault];
}

@end

@implementation COGitListBranchesRequest

- (void)prepareForRequest
{
//    self.path = [NSString stringWithFormat: @"/user/%@/project/%@/git/list_branches", self.gloabKey, self.project];
    self.path = [NSString stringWithFormat: @"%@/git/list_branches", self.backendProjectPath];
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COGitBranch class] responseType:CODataResponseTypeList];
}

@end

@implementation COGitListTagsRequest

- (void)prepareForRequest
{
//    self.path = [NSString stringWithFormat: @"/user/%@/project/%@/git/tree/master/", self.gloabKey, self.project];
    self.path = [NSString stringWithFormat: @"%@/git/list_tags", self.backendProjectPath];
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COGitBranch class] responseType:CODataResponseTypeList];
}

@end