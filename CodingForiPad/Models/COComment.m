//
// COComment.m
//

#import "COComment.h"

@implementation COComment

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"project" : @"project",
             @"title" : @"title",
             @"createdAt" : @"created_at",
             @"labels" : @"labels",
             @"updatedAt" : @"updated_at",
             @"content" : @"content",
             @"parentId" : @"parent_id",
             @"currentUserRoleId" : @"current_user_role_id",
             @"childCount" : @"child_count",
             @"owner" : @"owner",
             @"projectId" : @"project_id",
             @"type" : @"type",
             @"commentId" : @"id",
             @"ownerId" : @"owner_id",
             };
}

@end
