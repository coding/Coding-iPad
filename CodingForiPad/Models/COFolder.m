//
// COFolder.m
//

#import "COFolder.h"

#define kNetPath_Code_Base        @"https://coding.net/"

@implementation COFolder

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"ownerName" : @"owner_name",
             @"name" : @"name",
             @"createdAt" : @"created_at",
             @"updatedAt" : @"updated_at",
             @"parentId" : @"parent_id",
             @"fileId" : @"file_id",
             @"subFolders" : @"sub_folders",
             @"type" : @"type",
             @"ownerId" : @"owner_id",
             };
}

+ (NSValueTransformer *)subFoldersJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[COFolder class]];
}
            
@end

@implementation COFile

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"size" : @"size",
             @"name" : @"name",
             @"path" : @"path",
             @"title" : @"title",
             @"currentUserRoleId" : @"current_user_role_id",
             @"ownerPreview" : @"owner_preview",
             @"createdAt" : @"created_at",
             @"updatedAt" : @"updated_at",
             @"number" : @"number",
             @"storageKey" : @"storage_key",
             @"parentId" : @"parent_id",
             @"storageType" : @"storage_type",
             @"fileId" : @"file_id",
             @"owner" : @"owner",
             @"preview" : @"preview",
             @"type" : @"type",
             @"fileType" : @"fileType",
             @"ownerId" : @"owner_id",
             @"projectId" : @"project_id",
             };
}

+ (NSValueTransformer *)ownerJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COUser class]];
}

- (BOOL)isEmpty
{
    return !(self.storageKey && self.storageKey.length > 0);
}

- (NSString *)downloadPath
{
    NSString *path = [NSString stringWithFormat:@"%@api/project/%ld/files/%ld/download", kNetPath_Code_Base, (long)_projectId, _fileId];
    return path;
}

- (NSString *)diskFileName
{
    if (!_diskFileName) {
        if (_projectId == 0) {
            return nil;
        }
        else {
            _diskFileName = [NSString stringWithFormat:@"%@|||%ld|||%@|%@", _name, (long)_projectId, _storageType, _storageKey];
        }
    }
    return _diskFileName;
}

@end

@implementation COFileView

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"content" : @"content",
             @"file" : @"file",
             };
}

+ (NSValueTransformer *)fileJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COFile class]];
}

@end

@implementation COFileCount

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"folderId" : @"folder",
             @"count" : @"count",
             };
}

@end
