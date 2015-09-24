//
//  CODataRequest.h
//  CodingModels
//
//  Created by sunguanglei on 15/5/19.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import "CODataResponse.h"

#define COAPIDomain @"https://coding.net/api"

#define COQueryParameters
#define COUriParameters
#define COFormParameters

#define COGetRequest    /** Get请求 */

#define COPostRequest   /** Post请求 */

#define COPutRequest    /** Pust请求 */

#define CODeleteRequest /** Delete请求 */


@interface CODataRequest : NSObject

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSDictionary *params;

+ (instancetype)request;

- (NSDictionary *)parametersMap;
- (NSDictionary *)buildParameters;
- (void)prepareForRequest;
- (void)readyForRequest;

- (void)getWithSuccess:(void (^)(CODataResponse *responseObject))success
                failure:(void (^)(NSError *error))failure;

- (void)postWithSuccess:(void (^)(CODataResponse * responseObject))success
                failure:(void (^)(NSError *error))failure;

- (void)putWithSuccess:(void (^)(CODataResponse * responseObject))success
                failure:(void (^)(NSError *error))failure;

- (void)deleteWithSuccess:(void (^)(CODataResponse * responseObject))success
                failure:(void (^)(NSError *error))failure;

- (CODataResponse *)getResponseParser:(id)response;
- (CODataResponse *)postResponseParser:(id)response;
- (CODataResponse *)putResponseParser:(id)response;
- (CODataResponse *)deleteResponseParser:(id)response;

- (void)postWithSuccess:(void (^)(CODataResponse *responseObject))success
                failure:(void (^)(NSError *error))failure
                   file:(NSDictionary *)file;

@end

COGetRequest
@interface COPageRequest : CODataRequest

@property (nonatomic, assign) COQueryParameters NSInteger page;
@property (nonatomic, assign) COQueryParameters NSInteger pageSize;

@end
