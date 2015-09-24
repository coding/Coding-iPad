//
// COConversation.m
//

#import "COConversation.h"

@implementation COConversation

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"type" : @"type",
             @"count" : @"count",
             @"unreadCount" : @"unreadCount",
             @"readAt" : @"read_at",
             @"sender" : @"sender",
             @"createdAt" : @"created_at",
             @"content" : @"content",
             @"status" : @"status",
             @"conversationId" : @"id",
             @"friendUser" : @"friend",
             };
}

+ (NSValueTransformer *)senderJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COUser class]];
}

+ (NSValueTransformer *)friendUserJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COUser class]];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _sendStatus = PrivateMessageStatusSendSucess;
    }
    return self;
}

- (void)setContent:(NSString *)content
{
    if (_content != content) {
        _htmlMedia = [HtmlMedia htmlMediaWithString:content showType:MediaShowTypeCode];
        if (_htmlMedia.contentDisplay.length <= 0 && _htmlMedia.imageItems.count <= 0 && !_nextImg) {
            _content = @"    ";//占位
        } else {
            _content = _htmlMedia.contentDisplay;
        }
    }
}

- (BOOL)hasMedia
{
    return self.nextImg || (self.htmlMedia && self.htmlMedia.imageItems.count>0);
}

@end


@implementation CONotification

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"status" : @"status",
             @"createdAt" : @"created_at",
             @"targetId" : @"target_id",
             @"targetType" : @"target_type",
             @"content" : @"content",
             @"type" : @"type",
             @"bId" : @"id",
             @"ownerId" : @"owner_id",
             };
}
@end
