//
//  COProjectRequest.h
//  CodingModels
//
//  Created by sunguanglei on 15/5/19.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "CODataRequest.h"

@interface COProjectsRequest : COPageRequest

/**
 *   all joined created
 */
@property (nonatomic, copy) COQueryParameters NSString *type;
@property (nonatomic, copy) COQueryParameters NSString *sort;

@end

COGetRequest
@interface COUserProjectsRequest : COPageRequest

@property (nonatomic, copy) COUriParameters NSString *globalKey;

/**
 * project;
 * stared;
 */
@property (nonatomic, copy) COQueryParameters NSString *type;

@end

@interface COUserPublicProjectsRequest : CODataRequest


@end

@interface COUserHotProjectsRequest : CODataRequest


@end

@interface COUserRecommendedProjectsRequest : CODataRequest


@end

@interface COUserProjectGroupRequest : CODataRequest

@property (nonatomic, copy) COFormParameters NSString *name;
@property (nonatomic, copy) COFormParameters NSString *ids;

@end

@interface COUserProjectGroupsRequest : CODataRequest


@end

@interface COUserProjectGroupInfoRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSString *group_name;

@end

@interface COUserProjectGroupUpdateRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSString *group_id;
@property (nonatomic, copy) COFormParameters NSString *name;

@end

@interface COUserProjectGroupEditRequest : CODataRequest

@property (nonatomic, assign) COFormParameters NSInteger ids;

@end

@interface COProjectCreateRequest : CODataRequest

@property (nonatomic, copy) COFormParameters NSString *name;
@property (nonatomic, copy) COFormParameters NSString *desc;
@property (nonatomic, assign) COFormParameters NSInteger type;
@property (nonatomic, copy) COFormParameters NSString *gitEnabled;
@property (nonatomic, copy) COFormParameters NSString *gitReadmeEnabled;
@property (nonatomic, copy) COFormParameters NSString *gitIgnore;
@property (nonatomic, copy) COFormParameters NSString *gitLicense;
@property (nonatomic, copy) COFormParameters NSString *importFrom;
@property (nonatomic, copy) COFormParameters NSString *vcsType;

@end

CODeleteRequest
@interface COProjectDeleteRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSString *globalKey;
@property (nonatomic, copy) COUriParameters NSString *projectName;
@property (nonatomic, copy) COFormParameters NSString *userName;
@property (nonatomic, copy) COFormParameters NSString *password;

@end

@interface COProjectInfoRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSString *projectName;
@property (nonatomic, copy) COQueryParameters NSString *userName;
@property (nonatomic, copy) COQueryParameters NSString *name;
@property (nonatomic, copy) COQueryParameters NSString *desc;
@property (nonatomic, copy) COQueryParameters NSString *defaultBranch;
@property (nonatomic, copy) COQueryParameters NSString *password;

@end

@interface COProjectIconRequest : CODataRequest

@property (nonatomic, copy) COFormParameters NSString *form;

@end

// 更新项目图标
@interface COProjectUpdateIconRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSNumber *projectId;

@end

#pragma mark - 项目成员
COGetRequest
@interface COProjectMembersRequest : COPageRequest

@property (nonatomic, assign) COUriParameters NSInteger projectId;

@end

COPutRequest
@interface COProjectMemberAddRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSNumber *projectId;
//    一次添加多个成员(逗号分隔)：users=102,4
@property (nonatomic, copy) COFormParameters NSString *userId;

@end

COPostRequest
@interface COProjectMemberKickoutRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSNumber *projectId;
@property (nonatomic, copy) COUriParameters NSNumber *userId;

@end

// 请求项目详情
@interface COProjectDetailRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSString *projectOwnerName;
@property (nonatomic, copy) COUriParameters NSString *projectName;

@end

// 收藏项目
@interface COProjectStarRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSString *projectOwnerName;
@property (nonatomic, copy) COUriParameters NSString *projectName;

@end

// 取消收藏项目
@interface COProjectUnstarRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSString *projectOwnerName;
@property (nonatomic, copy) COUriParameters NSString *projectName;

@end

@interface COProjectStaredRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSString *backendProjectPath;

@end

@interface COProjectStargazersRequest : CODataRequest


@end

// fork项目
COPostRequest
@interface COProjectForkRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSString *projectOwnerName;
@property (nonatomic, copy) COUriParameters NSString *projectName;

@end

// 关注项目
@interface COProjectWatchRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSString *projectOwnerName;
@property (nonatomic, copy) COUriParameters NSString *projectName;

@end

// 取消关注项目
@interface COProjectUnwatchRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSString *projectOwnerName;
@property (nonatomic, copy) COUriParameters NSString *projectName;

@end

@interface COProjectWatchersRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSString *backendProjectPath;

@end

COGetRequest
@interface COProjectUpdateVisitRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSString *backendProjectPath;

@end

@interface COProjectQuitRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSNumber *projectId;

@end

@interface COProjectTransferRequest : CODataRequest

@property (nonatomic, copy) COFormParameters NSString *userId;

@end

@interface COProjectSearchUserRequest : CODataRequest


@end

@interface COProjectSearchResourceRequest : CODataRequest

@property (nonatomic, copy) COQueryParameters NSString *type;
@property (nonatomic, copy) COQueryParameters NSString *keyword;

@end

@interface COProjectActivitiesRequest : CODataRequest

//api/project/84839/activities
@property (nonatomic, copy) COUriParameters   NSNumber *projectId;
@property (nonatomic, copy) COQueryParameters NSNumber *lastId;
@property (nonatomic, copy) COQueryParameters NSNumber *userId;
/**
 *  全部 all
 *  任务 task
 *  讨论 topic
 *  文档 file
 *  代码 code
 *  其他 other
 */
@property (nonatomic, copy) COQueryParameters NSString *type;


@end

@interface COProjectUpdateRequest : CODataRequest

@property (nonatomic, copy) COFormParameters NSNumber *projectId;
@property (nonatomic, copy) COFormParameters NSString *projectName;
@property (nonatomic, copy) COFormParameters NSString *projectDesc;

@end

COGetRequest
@interface COProjectMemberTaskCountRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSNumber *projectId;

@end

