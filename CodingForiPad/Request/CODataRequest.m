//
//  CODataRequest.m
//  CodingModels
//
//  Created by sunguanglei on 15/5/19.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "CODataRequest.h"
#import <UIKit/UIKit.h>

@implementation CODataRequest

+ (instancetype)request
{
    return [[[self class] alloc] init];
}

- (NSDictionary *)parametersMap
{
    return nil;
}

- (NSDictionary *)buildParameters
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSDictionary *maps = [self parametersMap];
    for (NSString *key in maps.allKeys) {
        id val = [self valueForKey:key];
        if (val) {
            [params setObject:val forKey:maps[key]];
        }
    }
    return [NSDictionary dictionaryWithDictionary:params];
}

- (void)prepareForRequest
{
    
}

- (void)readyForRequest
{
    
}

- (void)getWithSuccess:(void (^)(CODataResponse *responseObject))success
               failure:(void (^)(NSError *error))failure
{
    [self prepareForRequest];
    self.params = [self buildParameters];
    
    NSAssert(self.path != nil, @"Path can't be nil.");
    
    NSString *encodedUrl = [self.path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *url = [NSString stringWithFormat:@"%@%@", COAPIDomain, encodedUrl];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", @"text/html", nil];
    [self readyForRequest];
    [manager GET:url parameters:self.params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) success([self getResponseParser:responseObject]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) failure(error);
    }];
}

- (void)postWithSuccess:(void (^)(CODataResponse *responseObject))success
                failure:(void (^)(NSError *error))failure
{
    [self prepareForRequest];
    self.params = [self buildParameters];
    
    NSAssert(self.path != nil, @"Path can't be nil.");
    
    NSString *url = [NSString stringWithFormat:@"%@%@", COAPIDomain, self.path];
    
    [self readyForRequest];
    [[AFHTTPRequestOperationManager manager] POST:url parameters:self.params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) success([self postResponseParser:responseObject]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) failure(error);
    }];
}

- (void)postWithSuccess:(void (^)(CODataResponse *responseObject))success
                failure:(void (^)(NSError *error))failure
                   file:(NSDictionary *)file
{
    [self prepareForRequest];
    self.params = [self buildParameters];
    
    NSAssert(self.path != nil, @"Path can't be nil.");
    
    NSString *url = [NSString stringWithFormat:@"%@%@", COAPIDomain, self.path];
    
    // Data
    NSData *data;
    NSString *name, *fileName;
    
    if (file) {
        UIImage *image = file[@"image"];
        
        // 缩小到最大 800x800
        // image = [image scaledToMaxSize:CGSizeMake(500, 500)];
        
        // 压缩
        data = UIImageJPEGRepresentation(image, 1.0);
        if ((float)data.length/1024 > 1000) {
            data = UIImageJPEGRepresentation(image, 1024*1000.0/(float)data.length);
        }
        
        name = file[@"name"];
        fileName = file[@"fileName"];
    }

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperationManager manager] POST:url parameters:self.params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (file) {
            [formData appendPartWithFileData:data name:name fileName:fileName mimeType:@"image/jpeg"];
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) success([self postResponseParser:responseObject]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) failure(error);
    }];
    [operation start];
}

- (void)putWithSuccess:(void (^)(CODataResponse *responseObject))success
               failure:(void (^)(NSError *error))failure
{
    [self prepareForRequest];
    self.params = [self buildParameters];
    
    NSAssert(self.path != nil, @"Path can't be nil.");
    
    NSString *url = [NSString stringWithFormat:@"%@%@", COAPIDomain, self.path];
    
    [self readyForRequest];
    [[AFHTTPRequestOperationManager manager] PUT:url parameters:self.params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) success([self putResponseParser:responseObject]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) failure(error);
    }];
}

- (void)deleteWithSuccess:(void (^)(CODataResponse *responseObject))success
                  failure:(void (^)(NSError *error))failure
{
    [self prepareForRequest];
    self.params = [self buildParameters];
    
    NSAssert(self.path != nil, @"Path can't be nil.");
    
    NSString *url = [NSString stringWithFormat:@"%@%@", COAPIDomain, self.path];
    
    [self readyForRequest];
    [[AFHTTPRequestOperationManager manager] DELETE:url parameters:self.params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) success([self deleteResponseParser:responseObject]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) failure(error);
    }];
}

- (CODataResponse *)getResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response];
}

- (CODataResponse *)postResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response];
}

- (CODataResponse *)putResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response];
}

- (CODataResponse *)deleteResponseParser:(id)response
{
    return [[CODataResponse alloc] initWithResponse:response];
}

@end

@implementation COPageRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.page = 1;
        self.pageSize = 20;
    }
    return self;
}

- (void)readyForRequest
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.params];
    [params setObject:@(self.page) forKey:@"page"];
    [params setObject:@(self.pageSize) forKey:@"pageSize"];
    self.params = [NSDictionary dictionaryWithDictionary:params];
}

@end
