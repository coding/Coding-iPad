//
//  CODataResponse.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/20.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    CODataResponseTypeDefault,
    CODataResponseTypeList,
    CODataResponseTypePage,
} CODataResponseType;

// 需要二次认证
extern const NSInteger OPErrorCodeNeedAuthCode;

@interface CODataResponse : NSObject

@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) id        msg;
@property (nonatomic, strong) NSError   *error;
@property (nonatomic, strong) id        data;
@property (nonatomic, strong) NSDictionary *extraData;

- (NSString *)displayMsg;

- (instancetype)initWithResponse:(id)response;
- (instancetype)initWithResponse:(id)response
                  dataModleClass:(Class)dataModelClass
                    responseType:(CODataResponseType)responseType;

@end
