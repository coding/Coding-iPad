//
//  COMessageRequest.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/23.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COMessageRequest.h"
#import "COConversation.h"

@implementation COConversationListRequest

- (void)prepareForRequest
{
    self.path = @"/message/conversations";
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COConversation class] responseType:CODataResponseTypePage];
}

@end

@implementation COConversationRequest

- (void)prepareForRequest
{
    self.path = [NSString stringWithFormat:@"/message/conversations/%@/%@", self.globalKey, self.type];
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COConversation class] responseType:CODataResponseTypeList];
}

- (NSDictionary *)parametersMap
{
    return @{@"lastId" : @"id",
             @"pageSize" : @"pageSize",};
}

@end

@implementation COMessageSendRequest

- (void)prepareForRequest
{
    self.path = @"/message/send";
}

- (NSDictionary *)parametersMap
{
    return @{@"content" : @"content",
             @"extra" : @"extra",
             @"receiverGlobalKey" : @"receiver_global_key"};
}

- (CODataResponse *)postResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[COConversation class] responseType:CODataResponseTypeDefault];
}

@end

@implementation CONotificationRequest

- (void)prepareForRequest
{
    self.path = @"/notification";
}

- (NSDictionary *)parametersMap
{
    return @{@"type" : @"type"};
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response dataModleClass:[CONotification class] responseType:CODataResponseTypePage];
}

@end
