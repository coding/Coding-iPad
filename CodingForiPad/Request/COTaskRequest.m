//
//  COTaskRequest.m
//  CodingModels
//
//  Created by sunguanglei on 15/6/18.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COTaskRequest.h"
#import "COTask.h"

@implementation COMyTasksRequest

- (void)prepareForRequest
{
    if (self.type.length == 0) {
        self.path =@"/tasks/all";
    }
    else {
        self.path = [NSString stringWithFormat:@"/tasks/%@", self.type];
    }
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COTask class] responseType:CODataResponseTypePage];
}

@end

@implementation COTasksOfProjectRequest

- (void)prepareForRequest
{
//    self.path = [NSString stringWithFormat:@"/user/%@/project/%@/tasks/all", self.globalKey, self.projectName];
    if ([self.gloalKey length] > 0) {
        self.path = [NSString stringWithFormat:@"%@/tasks/user/%@/all", self.backendProjectPath, self.gloalKey];
    }
    else {
        self.path = [NSString stringWithFormat:@"%@/tasks/all", self.backendProjectPath];
    }
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COTask class] responseType:CODataResponseTypePage];
}

@end

@implementation COTaskCreateRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"%@/task", self.backendProjectPath];
}

- (NSDictionary *)parametersMap
{
    return @{@"content"         : @"content",
             @"deadline"        : @"deadline",
             @"ownerId"         : @"owner_id",
             @"priority"        : @"priority",
             @"taskDescription" : @"description",};
}

- (CODataResponse *)postResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COTask class] responseType:CODataResponseTypeDefault];
}

@end

@implementation COTaskDetailRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"%@/task/%@", _backendProjectPath, _taskId];
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COTask class] responseType:CODataResponseTypeDefault];
}

@end

@implementation COTaskUpdateRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/task/%@/update", self.taskId];
}

- (NSDictionary *)parametersMap
{
    return @{@"content"         : @"content",
             @"deadline"        : @"deadline",
             @"ownerId"         : @"owner_id",
             @"priority"        : @"priority",
             @"status"          : @"status",};
}

- (CODataResponse *)putResponseParser:(id)response
{
    return [[CODataResponse alloc] init];
}

@end

@implementation COTaskDescriptionRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/task/%@/description", self.taskId];
}

- (NSDictionary *)parametersMap
{
    return @{@"descriptionStr" : @"description"};
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COTaskDescription class] responseType:CODataResponseTypeDefault];
}

- (CODataResponse *)putResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COTaskDescription class] responseType:CODataResponseTypeDefault];
}

@end

@implementation COTaskCommentRequest

- (void)prepareForRequest
{
    //api/task/43100/comment
    self.path = [NSString stringWithFormat:@"/task/%@/comment", self.taskId];
}

- (NSDictionary *)parametersMap
{
    return @{@"content" : @"content",};
}

- (CODataResponse *)postResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COTask class] responseType:CODataResponseTypeDefault];
}

@end

@implementation COTaskCommentDeleteRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/task/%@/comment/%@", self.taskId, self.commentId];
}

@end

@implementation COTaskCommentsRequest

- (void)prepareForRequest
{
    //api/task/43100/comment
    self.path = [NSString stringWithFormat:@"/task/%@/comments", self.taskId];
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COTaskComment class] responseType:CODataResponseTypePage];
}

@end

@implementation COTaskStatusRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/task/%@/status", self.taskId];
}

- (NSDictionary *)parametersMap
{
    return @{@"status" : @"status",};
}

@end

@implementation COMDtoHtmlRequest

- (void)prepareForRequest
{
    self.path = @"/markdown/previewNoAt";
}

- (NSDictionary *)parametersMap
{
    return @{@"mdStr" : @"content",};
}

@end