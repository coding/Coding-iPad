//
//  CODataResponse.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/20.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "CODataResponse.h"
#import <Mantle.h>

const NSInteger OPErrorCodeNeedAuthCode = 70013;

@implementation CODataResponse

- (instancetype)initWithResponse:(id)response
{
    return [self initWithResponse:response dataModleClass:nil responseType:CODataResponseTypeDefault];
}

- (instancetype)initWithResponse:(id)response dataModleClass:(Class)dataModelClass responseType:(CODataResponseType)responseType
{
    self = [super init];
    if (self) {
        @try {
            self.code = [response[@"code"] integerValue];
            self.msg = response[@"msg"];
            if (nil == dataModelClass) {
                self.data = response[@"data"];
            }
            else {
                NSError *error = nil;
                if (CODataResponseTypeDefault == responseType) {
                    self.data = [MTLJSONAdapter modelOfClass:dataModelClass fromJSONDictionary:response[@"data"] error:&error];
                }
                else if (CODataResponseTypeList == responseType) {
                    self.data = [MTLJSONAdapter modelsOfClass:dataModelClass fromJSONArray:response[@"data"] error:&error];
                }
                else if (CODataResponseTypePage == responseType) {
                    NSDictionary *pageData = response[@"data"];
                    self.data = [MTLJSONAdapter modelsOfClass:dataModelClass fromJSONArray:pageData[@"list"] error:&error];
                    self.extraData = [self extraPageInfo:pageData];
                }
                self.error = error;
            }
        }
        @catch (NSException *exception) {
            self.error = [NSError errorWithDomain:@"net.coding.codingForiPad" code:1001 userInfo:@{NSLocalizedDescriptionKey:@"Response data format error.", NSLocalizedFailureReasonErrorKey:@"Response data format error."}];
        }
        @finally {
            //
        }
    }
    return self;
}

- (NSDictionary *)extraPageInfo:(NSDictionary *)pageData
{
    NSMutableDictionary *pageInfo = [NSMutableDictionary dictionaryWithDictionary:pageData];
    if (pageInfo[@"list"]) {
        [pageInfo removeObjectForKey:@"list"];
    }
    return [NSDictionary dictionaryWithDictionary:pageInfo];
}

- (NSString *)displayMsg
{
    // TODO: 确认返回形式
    if ([self.msg isKindOfClass:[NSDictionary class]]) {
        NSArray *msgs = [self.msg allValues];
        return [msgs componentsJoinedByString:@"\n"];
    }
    return @"未知错误";
}

@end
