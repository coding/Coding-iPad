//
//  COMessageRequest.h
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/23.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "CODataRequest.h"

@interface COConversationListRequest : COPageRequest

@end

@interface COConversationRequest : CODataRequest

@property (nonatomic, copy) COUriParameters NSString *globalKey;
@property (nonatomic, copy) COUriParameters NSString *type;
@property (nonatomic, copy) COQueryParameters NSNumber *lastId;
@property (nonatomic, copy) COQueryParameters NSNumber *pageSize;

@end

@interface COMessageSendRequest : CODataRequest

@property (nonatomic, copy) COFormParameters NSString *content;
@property (nonatomic, copy) COFormParameters NSString *extra;
@property (nonatomic, copy) COFormParameters NSString *receiverGlobalKey;

@end

@interface CONotificationRequest : COPageRequest

@property (nonatomic, strong) COQueryParameters NSNumber *type;

@end