//
// COTopic.m
//

#import "COTopic.h"

@implementation COTopicLabel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"topicLabelId" : @"id",
             @"projectId"    : @"project_id",
             @"name"         : @"name",
             @"color"        : @"color",
             @"ownerId"      : @"owner_id",
             @"count"        : @"count",
             };
}
@end

@implementation COTopic

- (instancetype)init
{
    self = [super init];
    if (self) {
        _contentHeight = 1;
        _createdAt = [[NSDate date] timeIntervalSince1970] * 1000;
        _title = @"";
        _content = @"";
        _mdTitle = @"";
        _mdContent = @"";
        
        _labels = [[NSMutableArray alloc] initWithCapacity:3];
        _mdLabels = [[NSMutableArray alloc] initWithCapacity:3];
    }
    return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"project" : @"project",
             @"title" : @"title",
             @"createdAt" : @"created_at",
             @"labels" : @"labels",
             @"updatedAt" : @"updated_at",
             @"content" : @"content",
             @"parentId" : @"parent_id",
             @"parent" : @"parent",
             @"currentUserRoleId" : @"current_user_role_id",
             @"childCount" : @"child_count",
             @"owner" : @"owner",
             @"projectId" : @"project_id",
             @"type" : @"type",
             @"topicId" : @"id",
             @"ownerId" : @"owner_id",
             @"path" : @"path",
             };
}

+ (NSValueTransformer *)projectJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COProject class]];
}

+ (NSValueTransformer *)ownerJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COUser class]];
}

+ (NSValueTransformer *)labelsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[COTopicLabel class]];
}

+ (NSValueTransformer *)parentJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COTopic class]];
}

- (HtmlMedia *)htmlMedia
{
    if (!_htmlMedia) {
        _htmlMedia = [HtmlMedia htmlMediaWithString:_content showType:MediaShowTypeNone];
        _content = _htmlMedia.contentDisplay;
    }
    return _htmlMedia;
}

@end

@implementation COTopicDetail

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
             @"topicId" : @"id",
             @"ownerId" : @"owner_id",
             @"path" : @"path",
             };
}

+ (NSValueTransformer *)projectJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COProject class]];
}

+ (NSValueTransformer *)ownerJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COUser class]];
}

+ (NSValueTransformer *)labelsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[COTopicLabel class]];
}

@end
