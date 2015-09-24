//
//  COTopicRequest.m
//  CodingModels
//
//  Created by sunguanglei on 15/6/3.
//  Copyright (c) 2015年 sgl. All rights reserved.
//

#import "COTopicRequest.h"
#import "COTopic.h"

@implementation COTopicRequest

- (void)prepareForRequest
{
//    self.path = [NSString stringWithFormat:@"/user/%@/project/%@/topics/mobile", _globalKey, _projectName];
    self.path = [NSString stringWithFormat:@"%@/topics/mobile", _backendProjectPath];
}

- (NSDictionary *)parametersMap
{
    return @{@"orderBy" : @"orderBy",
             @"topicLabelId" : @"labelId",
             @"type" : @"type",
             };
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COTopic class] responseType:CODataResponseTypePage];
}

@end

@implementation COTopicDetailRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/topic/%@", self.topicId];
}

- (NSDictionary *)parametersMap
{
    return @{@"type" : @"type"};
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COTopic class] responseType:CODataResponseTypeDefault];
}

@end

@implementation COTopicDeleteRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/topic/%@", self.topicId];
}

@end

@implementation COTopicUpdateRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/topic/%@", self.topicId];
}

- (NSDictionary *)parametersMap
{
    return @{@"title" : @"title",
             @"content" : @"content",
             @"label" : @"label"};
}

- (CODataResponse *)putResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COTopic class] responseType:CODataResponseTypeDefault];
}

@end

@implementation COTopicAddRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/project/%@/topic?parent=0", self.projectId];
}

- (NSDictionary *)parametersMap
{
    return @{@"title" : @"title",
             @"content" : @"content",
             @"label" : @"label"};
}

- (CODataResponse *)postResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COTopic class] responseType:CODataResponseTypeDefault];
}

@end

@implementation COTopicCommentsRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/topic/%@/comments", self.topicId];
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COTopic class] responseType:CODataResponseTypePage];
}

@end

@implementation COTopicCommentAddRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/project/%@/topic?parent=%@", self.projectId, self.topicId];
}

- (NSDictionary *)parametersMap
{
    return @{@"content" : @"content"};
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COTopic class] responseType:CODataResponseTypeDefault];
}

@end


@implementation COProjectTopicLabelsRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/project/%ld/topic/label?withCount=true", (long)_projectId];
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COTopicLabel class] responseType:CODataResponseTypeList];
}

@end

@implementation COProjectTopicLabelAddRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/project/%ld/topic/label?withCount=true", (long)_projectId];
}

- (NSDictionary *)parametersMap
{
    return @{@"name" : @"name",
             @"color" : @"color"};
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:nil responseType:CODataResponseTypeDefault];
}

@end

@implementation COProjectTopicCountRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/project/%ld/topic/count", (long)_projectId];
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:nil responseType:CODataResponseTypeDefault];
}

@end

@implementation COProjectTopicLabelMyRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/user/%@/project/%@/topics/labels/my", _ownerName, _projectName];
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COTopicLabel class] responseType:CODataResponseTypeList];
}

@end

@implementation COProjectTopicLabelDelRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/project/%@/topic/label/%@", _projectId, _labelId];
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:nil responseType:CODataResponseTypeDefault];
}

@end

@implementation COProjectTopicLabelMedifyRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/user/%@/project/%@/topics/label/%@", _projectOwnerName, _projectName, _labelId];
}

- (NSDictionary *)parametersMap
{
    return @{@"name" : @"name",
             @"color" : @"color"};
}

@end

@implementation COProjectTopicLabelChangesRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/user/%@/project/%@/topics/%@/labels", _projectOwnerName, _projectName, _topicId];
}

- (NSDictionary *)parametersMap
{
    return @{@"labelIds" : @"label_id"};
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:nil responseType:CODataResponseTypeDefault];
}

@end


