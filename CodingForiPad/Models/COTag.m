//
//  COTag.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/9/21.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "COTag.h"

@implementation COTag

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"updatedAt" : @"updated_at",
             @"createdAt" : @"created_at",
             @"tagId" : @"id",
             @"name" : @"name",
             @"type" : @"type",
             };
}

@end
