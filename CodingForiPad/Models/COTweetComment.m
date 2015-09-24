//
// COTweetcomment.m
//

#import "COTweetcomment.h"

@implementation COTweetComment

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"createdAt" : @"created_at",
             @"content" : @"content",
             @"tweetId" : @"tweet_id",
             @"owner" : @"owner",
             @"tweetcommentId" : @"id",
             @"ownerId" : @"owner_id",
             };
}

+ (NSValueTransformer *)ownerJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[COUser class]];
}

@end
