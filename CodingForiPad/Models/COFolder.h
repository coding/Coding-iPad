//
// COFolder.h
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
#import "COUser.h"

@class Coding_DownloadTask;

typedef NS_ENUM(NSInteger, DownloadState){
    DownloadStateDefault = 0,
    DownloadStateDownloading,
    DownloadStatePausing,
    DownloadStateDownloaded
};

@interface COFolder : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *ownerName;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSTimeInterval createdAt;
@property (nonatomic, assign) NSTimeInterval updatedAt;
@property (nonatomic, assign) NSInteger parentId;
@property (nonatomic, assign) NSInteger fileId;
@property (nonatomic, strong) NSArray *subFolders;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger ownerId;

@end

@interface COFile : MTLModel<MTLJSONSerializing>

@property (nonatomic, assign) NSInteger size;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *path; // 在动态中使用
@property (nonatomic, copy) NSString *title; // 在动态中使用
@property (nonatomic, assign) NSInteger currentUserRoleId;
@property (nonatomic, copy) NSString *ownerPreview;
@property (nonatomic, assign) NSTimeInterval createdAt;
@property (nonatomic, assign) NSTimeInterval updatedAt;
@property (nonatomic, assign) NSInteger number;
@property (nonatomic, copy) NSString *storageKey;
@property (nonatomic, assign) NSInteger parentId;
@property (nonatomic, copy) NSString *storageType;
@property (nonatomic, assign) NSInteger fileId;
@property (nonatomic, strong) COUser *owner;
@property (nonatomic, copy) NSString *preview;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy) NSString *fileType;
@property (nonatomic, assign) NSInteger ownerId;
@property (nonatomic, assign) NSInteger projectId;

@property (readwrite, nonatomic, strong) NSString *diskFileName;

- (BOOL)isEmpty;
- (NSString *)downloadPath;

@end

@interface COFileView : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy)   NSString *content;
@property (nonatomic, strong) COFile *file;

@end

@interface COFileCount : MTLModel<MTLJSONSerializing>

@property (nonatomic, assign) NSInteger folderId;
@property (nonatomic, assign) NSInteger count;

@end
