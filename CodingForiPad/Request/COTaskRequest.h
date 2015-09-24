//
//  COTaskRequest.h
//  CodingModels
//
//  Created by sunguanglei on 15/6/18.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "CODataRequest.h"

@interface COMyTasksRequest : COPageRequest

/**
 * all         全部
 * processing  处理中
 * done        已完成
 */
@property (nonatomic, copy) COUriParameters NSString *type;

@end

@interface COTasksOfProjectRequest : COPageRequest

//@property (nonatomic, copy) COUriParameters NSString *projectName;
//@property (nonatomic, copy) COUriParameters NSString *globalKey;
@property (nonatomic, copy) COUriParameters NSString *backendProjectPath;
/**
 *  用户
 */
@property (nonatomic, copy) COUriParameters NSString *gloalKey;

@end

@interface COTaskCreateRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSString *backendProjectPath;
@property (nonatomic, copy) COFormParameters NSString *content;
@property (nonatomic, copy) COFormParameters NSString *deadline;
@property (nonatomic, copy) COFormParameters NSString *taskDescription;
@property (nonatomic, copy) COFormParameters NSString *ownerId;
@property (nonatomic, copy) COFormParameters NSNumber *priority;

@end

// 任务详情
COGetRequest
@interface COTaskDetailRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSNumber *taskId;
@property (nonatomic, copy) COUriParameters NSString *backendProjectPath;

@end


@interface COTaskUpdateRequest : CODataRequest

@property (nonatomic, copy) COUriParameters  NSNumber *taskId;
@property (nonatomic, copy) COFormParameters NSString *content;
@property (nonatomic, copy) COFormParameters NSString *deadline;
@property (nonatomic, copy) COFormParameters NSNumber *status;
@property (nonatomic, copy) COFormParameters NSNumber *ownerId;
@property (nonatomic, copy) COFormParameters NSNumber *priority;

@end

// 更新任务描述或获取任务描述
@interface COTaskDescriptionRequest : CODataRequest

@property (nonatomic, copy) COUriParameters  NSNumber *taskId;
@property (nonatomic, copy) COFormParameters NSString *descriptionStr;

@end

@interface COTaskCommentRequest : CODataRequest

@property (nonatomic, copy) COUriParameters  NSNumber *taskId;
@property (nonatomic, copy) COFormParameters NSString *content;

@end

// 删除任务评论
@interface COTaskCommentDeleteRequest : CODataRequest

@property (nonatomic, copy) COUriParameters  NSNumber *taskId;
@property (nonatomic, copy) COUriParameters  NSNumber *commentId;

@end

@interface COTaskCommentsRequest : COPageRequest

@property (nonatomic, copy) COUriParameters  NSNumber *taskId;

@end

// 任务状态改变，开启或完成
@interface COTaskStatusRequest : CODataRequest

@property (nonatomic, copy) COUriParameters  NSNumber *taskId;
@property (nonatomic, copy) COFormParameters NSNumber *status;

@end

// md编辑请求html
@interface COMDtoHtmlRequest : CODataRequest

@property (nonatomic, copy) COFormParameters  NSString *mdStr;

@end
