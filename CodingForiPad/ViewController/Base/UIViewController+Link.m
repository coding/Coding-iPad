//
//  UIViewController+Link.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/8/21.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "UIViewController+Link.h"

#import "COMesageController.h"
#import <RegexKitLite.h>
#import "CODataRequest.h"
#import "COTopicDetailController.h"
#import "COTopic.h"
#import "COUserController.h"
#import "COProjectDetailController.h"
#import "COTaskDetailController.h"
#import "COFilePreViewController.h"
#import "COFileViewController.h"
#import "COFileRootViewController.h"
#import "COTweetDetailViewController.h"
#import "COWebViewController.h"


@implementation UIViewController (Link)

- (BOOL)analyseVCFromLinkStr:(NSString *)linkStr showBlock:(COLinkShowBlock)showBlock
{
    if (!linkStr || linkStr.length <= 0) {
        showBlock(nil, COLinkShowTypeUnSupport, linkStr);
        return NO;
    }
    else if (![linkStr hasPrefix:@"/"] && ![linkStr hasPrefix:@"https://coding.net"]){
        showBlock([COWebViewController webVCWithUrlStr:linkStr], COLinkShowTypeWeb, linkStr);
        return NO;
    }
    
    NSString *userRegexStr = @"/u/([^/]+)$";
    NSString *userTweetRegexStr = @"/u/([^/]+)/bubble$";
    NSString *ppRegexStr = @"/u/([^/]+)/pp/([0-9]+)$";
    NSString *topicRegexStr = @"/u/([^/]+)/p/([^/]+)/topic/(\\d+)";
    NSString *taskRegexStr = @"/u/([^/]+)/p/([^/]+)/task/(\\d+)";
    NSString *gitMRPRCommitRegexStr = @"/u/([^/]+)/p/([^/]+)/git/(merge|pull|commit)/(\\d+)";
    NSString *conversionRegexStr = @"/user/messages/history/([^/]+)$";
    NSString *projectRegexStr = @"/u/([^/]+)/p/([^/]+)";
    NSArray *matchedCaptures = nil;
    
    if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:ppRegexStr]).count > 0){
        //冒泡
        NSString *user_global_key = matchedCaptures[1]; // globalKey
        NSString *pp_id = matchedCaptures[2];           // 冒泡ID
        NSLog(@"%@, %@", user_global_key, pp_id);
        COTweetDetailViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COTweetDetailViewController"];
        
        // FixMe: 宽度调整
        controller.targetWidth = 574.0;
        showBlock(controller, COLinkShowTypeRight, linkStr);
        [controller loadTweetDetail:user_global_key tweetId:@([pp_id integerValue])];
        return YES;
    }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:gitMRPRCommitRegexStr]).count > 0){
        //MR
        NSString *path = [linkStr stringByReplacingOccurrencesOfString:@"https://coding.net" withString:@""];
        NSString *projectName = matchedCaptures[2];
        NSString *globalKey = matchedCaptures[1];
        NSString *commitId = matchedCaptures[3];
        NSLog(@"%@,%@,%@,%@", path, projectName, globalKey, commitId);
        showBlock(nil, COLinkShowTypeWeb, linkStr);
        return YES;
    }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:topicRegexStr]).count > 0){
        //讨论
        NSString *topic_id = matchedCaptures[3];
        COTopicDetailController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COTopicDetailController"];
        COTopic *topic = [[COTopic alloc] init];
        topic.topicId = [topic_id integerValue];
        controller.topic = topic;
//        COMesageController *root = (COMesageController *)self.parentViewController;
//        [root pushDetail:controller];
        showBlock(controller, COLinkShowTypeRight, linkStr);
        return YES;
    }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:taskRegexStr]).count > 0){
        //任务
        NSString *user_global_key = matchedCaptures[1];
        NSString *project_name = matchedCaptures[2];
        NSString *taskId = matchedCaptures[3];
        NSString *backend_project_path = [NSString stringWithFormat:@"/user/%@/project/%@", user_global_key, project_name];
        COTaskDetailController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COTaskDetailController"];
//        COMesageController *root = (COMesageController *)self.parentViewController;
//        [root pushDetail:controller];
        showBlock(controller, COLinkShowTypeRight, linkStr);
        [controller loadTaskDetail:[taskId integerValue] backendProjectPath:backend_project_path];
        
        return YES;
        
    }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:conversionRegexStr]).count > 0) {
        //私信
        //        NSString *user_global_key = matchedCaptures[1];
        //        if ([presentingVC isKindOfClass:[ConversationViewController class]]) {
        //            ConversationViewController *vc = (ConversationViewController *)presentingVC;
        //            if ([vc.myPriMsgs.curFriend.global_key isEqualToString:user_global_key]) {
        //                [vc doPoll];
        //                analyseVCIsNew = NO;
        //                analyseVC = vc;
        //            }
        //        }
        //        if (!analyseVC) {
        //            ConversationViewController *vc = [[ConversationViewController alloc] init];
        //            vc.myPriMsgs = [PrivateMessages priMsgsWithUser:[User userWithGlobalKey:user_global_key]];
        //            analyseVC = vc;
        //        }
        showBlock(nil, COLinkShowTypeUnSupport, linkStr);
        return YES;
    }
    
    else    if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:userRegexStr]).count > 0) {
        //AT某人
        NSString *user_global_key = matchedCaptures[1];
        COUserController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COUserController"];
//        [self rootPushViewController:controller animated:YES];
        showBlock(controller, COLinkShowTypePush, linkStr);
        [controller showUserWithGlobalKey:user_global_key];
        return YES;
    }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:userTweetRegexStr]).count > 0){
        //某人的冒泡
        //            UserTweetsViewController *vc = [[UserTweetsViewController alloc] init];
        NSString *user_global_key = matchedCaptures[1];
        COUserController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COUserController"];
//        [self rootPushViewController:controller animated:YES];
        showBlock(controller, COLinkShowTypePush, linkStr);
        [controller showUserWithGlobalKey:user_global_key];
        return YES;
    }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:projectRegexStr]).count > 0){
        //项目
        NSString *user_global_key = matchedCaptures[1];
        NSString *project_name = matchedCaptures[2];
        COProject *project = [[COProject alloc] init];
        project.name = project_name;
        project.ownerUserName = user_global_key;
        COProjectDetailController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"COProjectDetailController"];
//        COMesageController *root = (COMesageController *)self.parentViewController;
//        [root pushDetail:controller];
        showBlock(controller, COLinkShowTypeRight, linkStr);
        [controller showProject:project];
        return YES;
    }

    showBlock([COWebViewController webVCWithUrlStr:linkStr], COLinkShowTypeWeb, linkStr);
    return NO;
}

@end
