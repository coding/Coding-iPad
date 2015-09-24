//
//  TagsManager.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-10-11.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "COTag.h"

@interface TagsManager : NSObject

@property (readwrite, nonatomic, strong) NSArray *tagArray;

- (NSString *)getTags_strWithTags:(NSArray *)tags;

@end

