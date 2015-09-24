//
//  COTag.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/9/21.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface COTag : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign) NSTimeInterval createdAt;
@property (nonatomic, assign) NSTimeInterval updatedAt;
@property (nonatomic, assign) NSInteger tagId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *type;

@end
