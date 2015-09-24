//
//  COGitTree.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/23.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
#import "COUser.h"

@interface COGitDepot : MTLModel<MTLJSONSerializing>
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *name;
@end

@interface COGitFile : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *data;
@property (nonatomic, copy) NSString *lang;
@property (nonatomic, assign) NSInteger size;
@property (nonatomic, assign) BOOL previewed;
@property (nonatomic, copy) NSString *preview;
@property (nonatomic, copy) NSString *lastCommitMessage;
@property (nonatomic, assign) NSTimeInterval lastCommitDate;
@property (nonatomic, copy) NSString *lastCommitId;
@property (nonatomic, strong) COUser *lastCommitter;
@property (nonatomic, copy) NSString *mode;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *flattenPath;

@end

@interface COGitCommit : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *fullMessage;
@property (nonatomic, copy) NSString *shortMessage;
@property (nonatomic, copy) NSString *allMessage;
@property (nonatomic, copy) NSString *commitId;
@property (nonatomic, assign) NSTimeInterval commitTime;
@property (nonatomic, strong) COUser *committer;
@property (nonatomic, assign) NSInteger notesCount;

@end

@interface COGitTree : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy)   NSString *path;
@property (nonatomic, copy)   NSString *ref;
@property (nonatomic, strong) NSArray *files;
@property (nonatomic, assign) BOOL isHead;
@property (nonatomic, assign) BOOL can_edit;
@property (nonatomic, strong) COGitCommit *lastCommit;
@property (nonatomic, strong) COGitFile *readme;
@property (nonatomic, strong) COGitCommit *headCommit;
@property (nonatomic, strong) COUser *lastCommitter;

@end

@interface COGitTreeInfo : MTLModel<MTLJSONSerializing>

@property (nonatomic, strong) NSArray *infos;

@end


@interface COGitBlob : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy)   NSString *ref;
@property (nonatomic, strong) COGitFile *file;
@property (nonatomic, assign) BOOL isHead;
@property (nonatomic, assign) BOOL can_edit;
@property (nonatomic, strong) COGitCommit *headCommit;

@end

@interface COGitTreeCommit : MTLModel<MTLJSONSerializing>

@property (nonatomic, strong) NSArray  *committers;
@property (nonatomic, copy)   NSString *shortMessage;
@property (nonatomic, copy)   NSString *sha;

@end

@interface COGitBranch : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy)   NSString *name;
@property (nonatomic, assign) BOOL isDefaultBranch;
@property (nonatomic, assign) BOOL isProtected;

@end