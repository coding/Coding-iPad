//
//  AppDelegate.m
//  CodingForiPad
//
//  Created by sunguanglei on 15/6/8.
//  Copyright (c) 2015年 coding. All rights reserved.
//

#import "AppDelegate.h"
#import "COStyleFactory.h"
#import "COSession.h"
#import <KVOController/FBKVOController.h>
#import <AFNetworkActivityLogger.h>
#import "SDWebImageManager.h"
#import "EaseStartView.h"
#import "XGPush.h"
#import "CORootViewController+Notification.h"

#define degreesToRadian(x) (M_PI * (x) / 180.0)

@interface AppDelegate ()

@end

@implementation AppDelegate

#pragma mark XGPush
- (void)registerPushForIOS8{
    UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc] init];
    UIUserNotificationSettings *userSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert
                                                                                 categories:[NSSet setWithObject:categorys]];
    [[UIApplication sharedApplication] registerUserNotificationSettings:userSettings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)registerPush{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
}

- (void)xgRegPush
{
    void (^successCallback)(void) = ^(void){
        //如果变成需要注册状态
        if(![XGPush isUnRegisterStatus])
        {
            //iOS8注册push方法
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
            
            float sysVer = [[[UIDevice currentDevice] systemVersion] floatValue];
            if(sysVer < 8){
                [self registerPush];
            }
            else{
                [self registerPushForIOS8];
            }
#else
            //iOS8之前注册push方法
            //注册Push服务，注册后才能收到推送
            [self registerPush];
#endif
        }
    };
    [XGPush initForReregister:successCallback];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [XGPush startApp:kXGPushId appKey:kXGPushKey];
    //sd加载的数据类型
    [[[SDWebImageManager sharedManager] imageDownloader] setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
    
    // Override point for customization after application launch.
    [COStyleFactory applyStyle];
    [self observeUserStatus];
    
#ifdef DEBUG
    [[AFNetworkActivityLogger sharedLogger] startLogging];
#endif
    
    EaseStartView *startView = [EaseStartView startView];
    __weak typeof(self) weakself = self;
    [startView startAnimationWithCompletionBlock:^(EaseStartView *easeStartView) {
        //[[UIApplication sharedApplication] setStatusBarHidden:NO];
        [weakself completionStartAnimationWithOptions:launchOptions];
    }];
    return YES;
}

- (void)completionStartAnimationWithOptions:(NSDictionary *)launchOptions{
    if ([COSession session].userStatus == COSessionUserStatusLogined) {
        NSDictionary *remoteNotification = [launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (remoteNotification) {
            [[CORootViewController currentRoot] handleNotificationInfo:remoteNotification applicationState:UIApplicationStateInactive];
        }
    }
    
    //推送反馈(app不在前台运行时，点击推送激活时。统计而已)
    [XGPush handleLaunching:launchOptions];
}

- (void)observeUserStatus
{
    [self.KVOController observe:[COSession session] keyPath:@"userStatus" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id observer, COSession *object, NSDictionary *change) {
        if (object.userStatus == COSessionUserStatusDefault
            || object.userStatus == COSessionUserStatusLogout) {
            [XGPush setAccount:nil];
            [XGPush unRegisterDevice];
            UIStoryboard *login = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
            self.window.rootViewController = [login instantiateInitialViewController];
            [self.window makeKeyAndVisible];
        }
        else if (object.userStatus == COSessionUserStatusLogined) {
            NSLog(@"%@", object.user.globalKey);
            [XGPush setAccount:object.user.globalKey];
            [self xgRegPush];
            UIStoryboard *main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            self.window.rootViewController = [main instantiateInitialViewController];
            [self.window makeKeyAndVisible];
        }
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString * deviceTokenStr = [XGPush registerDevice:deviceToken successCallback:^{
//        NSLog(@"success");
    } errorCallback:^{
//        NSLog(@"error");
    }];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:deviceTokenStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alert show];
#ifdef DEBUG
    NSLog(@"deviceTokenStr : %@", deviceTokenStr);
#endif
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alert show];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
#ifdef DEBUG
    NSLog(@"didReceiveRemoteNotification-userInfo:-----\n%@", userInfo);
#endif
    [XGPush handleReceiveNotification:userInfo];
    [[CORootViewController currentRoot] handleNotificationInfo:userInfo applicationState:[application applicationState]];
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskAll;
}

@end
