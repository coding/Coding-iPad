//
// COTweet.m
//

#import "COTweet.h"

@implementation COTweet

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"liked" : @"liked",
             @"activityId" : @"activity_id",
             @"coord" : @"coord",
             @"createdAt" : @"created_at",
             @"location" : @"location",
             @"comments" : @"comments",
             @"content" : @"content",
             @"device" : @"device",
             @"commentList" : @"comment_list",
             @"likes" : @"likes",
             @"owner" : @"owner",
             @"tweetId" : @"id",
             @"likeUsers" : @"like_users",
             @"ownerId" : @"owner_id",
             };
}

+ (NSValueTransformer *)ownerJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COUser class]];
}

+ (NSValueTransformer *)commentListJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[COTweetComment class]];
}

+ (NSValueTransformer *)likeUsersJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[COUser class]];
}

- (void)cleanHeight
{
    _height = 0.0;
    _contentHeight = 0.0;
    _imagesHeight = 0.0;
    _commentHeight = 0.0;
}

@end
