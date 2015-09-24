//
// COConversation.h
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
#import "COUser.h"
#import "COHtmlMedia.h"
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PrivateMessageSendStatus) {
    PrivateMessageStatusSendSucess = 0,
    PrivateMessageStatusSending,
    PrivateMessageStatusSendFail
};

@interface COConversation : MTLModel<MTLJSONSerializing>

@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) NSInteger unreadCount;
@property (nonatomic, assign) NSInteger readAt;
@property (nonatomic, strong) COUser *sender;
@property (nonatomic, assign) NSTimeInterval createdAt;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, assign) NSInteger conversationId;
@property (nonatomic, strong) COUser *friendUser;

@property (assign, nonatomic) PrivateMessageSendStatus sendStatus;
@property (readwrite, nonatomic, strong) HtmlMedia *htmlMedia;
@property (strong, nonatomic) UIImage *nextImg;

// 发送中、发送失败的显示及处理
//@property (assign, nonatomic) PrivateMessageSendStatus sendStatus;
//@property (strong, nonatomic) UIImage *nextImg;

- (BOOL)hasMedia;

@end


@interface CONotification : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *status;
@property (nonatomic, assign) NSTimeInterval createdAt;
@property (nonatomic, copy) NSString *targetId;
@property (nonatomic, copy) NSString *targetType;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *bId;
@property (nonatomic, copy) NSString *ownerId;

@end

