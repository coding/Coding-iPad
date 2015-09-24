//
//  COTopicRequest.h
//  CodingModels
//
//  Created by sunguanglei on 15/6/3.
//  Copyright (c) 2015年 sgl. All rights reserved.
//

#import "CODataRequest.h"

@interface COTopicRequest : COPageRequest

//@property (nonatomic, copy) COUriParameters NSString *globalKey;
//@property (nonatomic, copy) COUriParameters NSString *projectName;
@property (nonatomic, copy) COUriParameters NSString *backendProjectPath;
/**
 *  all 全部讨论
 *  my 我的讨论
 */
@property (nonatomic, copy) COQueryParameters NSString *type;
@property (nonatomic, copy) COQueryParameters NSString *topicLabelId;

/**
 *  51  最后评论排序
 *  49  发布时间排序
 *  53  热门排序
 */
@property (nonatomic, strong) COQueryParameters NSNumber *orderBy;

@end

@interface COTopicDetailRequest : CODataRequest

@property (nonatomic, copy) COUriParameters  NSNumber *topicId;
/**
 *  0  预览
 *  1  原始
 */
@property (nonatomic, copy) COQueryParameters  NSNumber *type;

@end

// 更新讨论
@interface COTopicUpdateRequest : CODataRequest

@property (nonatomic, copy) COUriParameters  NSNumber *topicId;
@property (nonatomic, copy) COFormParameters  NSString *title;
@property (nonatomic, copy) COFormParameters  NSString *content;
@property (nonatomic, copy) COFormParameters  NSString *label;

@end

// 删除讨论的评论
@interface COTopicDeleteRequest : CODataRequest

@property (nonatomic, copy) COUriParameters  NSNumber *topicId;

@end

// 新增讨论
@interface COTopicAddRequest : COPageRequest

@property (nonatomic, copy) COUriParameters  NSNumber *projectId;

@property (nonatomic, copy) COFormParameters  NSString *title;
@property (nonatomic, copy) COFormParameters  NSString *content;
@property (nonatomic, copy) COFormParameters  NSString *label;

@end

@interface COTopicCommentsRequest : COPageRequest

@property (nonatomic, copy) COUriParameters  NSNumber *topicId;

@end

// 讨论增加评论
@interface COTopicCommentAddRequest : COPageRequest

@property (nonatomic, copy) COUriParameters  NSNumber *projectId;
@property (nonatomic, copy) COUriParameters  NSNumber *topicId;

@property (nonatomic, copy) COQueryParameters  NSString *content;

@end

// 项目的所有标签及被使用计数
@interface COProjectTopicLabelsRequest : CODataRequest

@property (nonatomic, assign) COUriParameters NSInteger projectId;

@end

// 项目新增标签
@interface COProjectTopicLabelAddRequest : CODataRequest

@property (nonatomic, assign) COUriParameters NSInteger projectId;

@property (nonatomic, copy) COQueryParameters NSString *name;// POST
@property (nonatomic, copy) COQueryParameters NSString *color;

@end

// 项目所有、我参与的讨论数目
@interface COProjectTopicCountRequest : CODataRequest

@property (nonatomic, assign) COUriParameters NSInteger projectId;

@end

// 项目我参与的讨论的标签
@interface COProjectTopicLabelMyRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSString *ownerName;
@property (nonatomic, copy) COUriParameters NSString *projectName;

@end

// 删除项目的标签
@interface COProjectTopicLabelDelRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSNumber *projectId;
@property (nonatomic, copy) COUriParameters NSNumber *labelId;

@end

// 修改项目的标签
@interface COProjectTopicLabelMedifyRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSString *projectOwnerName;
@property (nonatomic, copy) COUriParameters NSString *projectName;
@property (nonatomic, copy) COUriParameters NSNumber *labelId;

@property (nonatomic, copy) COFormParameters NSString *name;// PUT
@property (nonatomic, copy) COFormParameters NSString *color;

@end

// 批量修改项目的标签
@interface COProjectTopicLabelChangesRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSString *projectOwnerName;
@property (nonatomic, copy) COUriParameters NSString *projectName;
@property (nonatomic, copy) COUriParameters NSNumber *topicId;

@property (nonatomic, copy) COFormParameters NSString *labelIds;

@end
