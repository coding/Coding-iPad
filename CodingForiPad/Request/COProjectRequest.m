//
//  COProjectRequest.m
//  CodingModels
//
//  Created by sunguanglei on 15/5/19.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COProjectRequest.h"
#import "COUser.h"
#import "COProject.h"
#import "COProjectActivity.h"

@implementation COProjectsRequest

- (void)prepareForRequest
{
    // TODO: uriParameters
    self.path = @"/projects";// [NSString stringWithFormat:@"/user/%@/projects", self.userName];
}
- (NSDictionary *)parametersMap
{
    return @{
             @"type" : @"type",
             @"sort" : @"sort",
             };
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COProject class] responseType:CODataResponseTypePage];
}

@end

@implementation COUserProjectsRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/user/%@/public_projects", self.globalKey];
}

- (NSDictionary *)parametersMap
{
    return @{
             @"type" : @"type",
             };
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COProject class] responseType:CODataResponseTypePage];
}

@end

@implementation COUserPublicProjectsRequest

- (void)prepareForRequest
{
    self.path = @"/user/{userName}/projects/public";
}

@end

@implementation COUserHotProjectsRequest

- (void)prepareForRequest
{
    self.path = @"/user/{userName}/projects/hot";
}


@end

@implementation COUserRecommendedProjectsRequest

- (void)prepareForRequest
{
    self.path = @"/user/{userName}/projects/recommended";
}


@end

@implementation COUserProjectGroupRequest

- (void)prepareForRequest
{
    self.path = @"/user/{userName}/projects/project_group";
}
- (NSDictionary *)parametersMap
{
    return @{
             @"name" : @"name",
             @"ids" : @"ids",
             };
}

@end

@implementation COUserProjectGroupsRequest

- (void)prepareForRequest
{
    self.path = @"/user/{userName}/projects/project_group/groups";
}


@end

@implementation COUserProjectGroupInfoRequest

- (void)prepareForRequest
{
    // TODO: uriParameters
    self.path = @"/user/{userName}/projects/project_group/groups/{group_name}";
}


@end

@implementation COUserProjectGroupUpdateRequest

- (void)prepareForRequest
{
    // TODO: uriParameters
    self.path = @"/user/{userName}/projects/project_group/{group_id}";
}
- (NSDictionary *)parametersMap
{
    return @{
             @"name" : @"name",
             };
}

@end

@implementation COUserProjectGroupEditRequest

- (void)prepareForRequest
{
    self.path = @"/user/{userName}/projects/project_group/{group_id}/projects";
}
- (NSDictionary *)parametersMap
{
    return @{
             @"ids" : @"ids",
             };
}

@end

@implementation COProjectCreateRequest

- (void)prepareForRequest
{
    self.path = @"/project";
}
- (NSDictionary *)parametersMap
{
    return @{
             @"name" : @"name",
             @"desc" : @"description",
             @"type" : @"type",
             @"gitEnabled" : @"gitEnabled",
             @"gitReadmeEnabled" : @"gitReadmeEnabled",
             @"gitIgnore" : @"gitIgnore",
             @"gitLicense" : @"gitLicense",
             @"importFrom" : @"importFrom",
             @"vcsType" : @"vcsType",
             };
}

@end

@implementation COProjectDeleteRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/user/%@/project/%@", self.globalKey, self.projectName];
}

- (NSDictionary *)parametersMap
{
    return @{@"userName" : @"userName",
             @"projectName" : @"name",
             @"password" : @"password",
             };
}

@end

@implementation COProjectInfoRequest

- (void)prepareForRequest
{
    // TODO: uriParameters
    self.path = @"/user/{userName}/project/{projectName}";
}
- (NSDictionary *)parametersMap
{
    return @{
             @"userName" : @"userName",
             @"name" : @"name",
             @"desc" : @"description",
             @"defaultBranch" : @"default_branch",
             @"password" : @"password",
             };
}

@end

@implementation COProjectIconRequest

- (void)prepareForRequest
{
    self.path = @"/user/{userName}/project/{projectName}/project_icon";
}
- (NSDictionary *)parametersMap
{
    return @{
             @"form" : @"form",
             };
}

@end

@implementation COProjectUpdateIconRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/project/%@/project_icon", self.projectId];
}

@end

#pragma mark - 项目成员
@implementation COProjectMembersRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/project/%lu/members", (long)self.projectId];
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COProjectMember class] responseType:CODataResponseTypePage];
}

@end

@implementation COProjectMemberAddRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/project/%@/members/add", self.projectId];
}

- (NSDictionary *)parametersMap
{
    return @{@"userId" : @"users"};
}

@end

@implementation COProjectMemberKickoutRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/project/%@/kickout/%@", self.projectId, self.userId];
}

@end

@implementation COProjectDetailRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/user/%@/project/%@", _projectOwnerName, _projectName];
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COProject class] responseType:CODataResponseTypeDefault];
}

@end

@implementation COProjectStarRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/user/%@/project/%@/star", _projectOwnerName, _projectName];
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:nil responseType:CODataResponseTypeDefault];
}

@end

@implementation COProjectUnstarRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/user/%@/project/%@/unstar", _projectOwnerName, _projectName];
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:nil responseType:CODataResponseTypeDefault];
}

@end

@implementation COProjectStaredRequest

- (void)prepareForRequest
{
    self.path = @"/user/{userName}/project/{projectName}/stared";
}

@end

@implementation COProjectStargazersRequest

- (void)prepareForRequest
{
    self.path = @"/user/{userName}/project/{projectName}/stargazers";
}

@end

@implementation COProjectForkRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/user/%@/project/%@/git/fork", self.projectOwnerName, self.projectName];
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:nil responseType:CODataResponseTypeDefault];
}

@end

@implementation COProjectWatchRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/user/%@/project/%@/watch", _projectOwnerName, _projectName];
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:nil responseType:CODataResponseTypeDefault];
}

@end

@implementation COProjectUnwatchRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/user/%@/project/%@/unwatch", _projectOwnerName, _projectName];
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:nil responseType:CODataResponseTypeDefault];
}

@end

@implementation COProjectWatchersRequest

- (void)prepareForRequest
{
    self.path = @"/user/{userName}/project/{projectName}/watchers";
}


@end

@implementation COProjectUpdateVisitRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/%@/update_visit", self.backendProjectPath];
}

@end

@implementation COProjectQuitRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/project/%@/quit", self.projectId];
}

- (CODataResponse *)postResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response];
}

@end

@implementation COProjectTransferRequest

- (void)prepareForRequest
{
    self.path = @"/user/{userName}/project/{projectName}/transfer_to";
}
- (NSDictionary *)parametersMap
{
    return @{
             @"userId" : @"user_id",
             };
}

@end

@implementation COProjectSearchUserRequest

- (void)prepareForRequest
{
    self.path = @"/user/{userName}/project/{projectName}/search/user";
}


@end

@implementation COProjectSearchResourceRequest

- (void)prepareForRequest
{
    self.path = @"/user/{userName}/project/{projectName}/search/resource";
}
- (NSDictionary *)parametersMap
{
    return @{
             @"type" : @"type",
             @"keyword" : @"keyword",
             };
}

@end

@implementation COProjectActivitiesRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/project/%@/activities", self.projectId];
}

- (NSDictionary *)parametersMap
{
    return @{
             @"type" : @"type",
             @"lastId" : @"last_id",
             @"userId" : @"user_id",
             };
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COProjectActivity class] responseType:CODataResponseTypeList];
}

@end

@implementation COProjectUpdateRequest

- (void)prepareForRequest
{
    self.path = @"/project";
}

- (NSDictionary *)parametersMap
{
    return @{@"projectDesc" : @"description",
             @"projectId"   : @"id",
             @"projectName"        : @"name",
             };
}

- (CODataResponse *)putResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response];
}

@end


@implementation COProjectMemberTaskCountRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/project/%@/task/user/count", self.projectId];
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COProjectMemberTaskCount class] responseType:CODataResponseTypeList];
}

@end
