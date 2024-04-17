//
//  CPDAppDelegate.m
//  PROJECT
//
//  Created by PROJECT_OWNER on TODAYS_DATE.
//  Copyright (c) TODAYS_YEAR PROJECT_OWNER. All rights reserved.
//

#import "DemoAppDelegate.h"
#import "DemoViewController.h"
@import LLZShareLib;

@implementation DemoAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [LLZShareManager sharelib_application:application didFinishLaunchingWithOptions:launchOptions];
    NSDictionary *shareConfigDict = (NSDictionary *)[[[NSBundle mainBundle] infoDictionary] objectForKey:@"AppShareConfig"];
    NSArray *sharePlatforms =  (NSArray *)[shareConfigDict objectForKey:@"SharePlatforms"];
    
    for(id sharePlatform in sharePlatforms){
        NSDictionary *sharePlatformDict = (NSDictionary *)sharePlatform;
        NSString *appId = (NSString *)[sharePlatformDict objectForKey:@"AppID"];
        NSString *universalLink = (NSString *)[sharePlatformDict objectForKey:@"UniversalLink"];
        NSInteger sharePlatformType = [[sharePlatformDict objectForKey:@"PlatformType"] integerValue];
        BOOL isResponder = [[sharePlatformDict objectForKey:@"isCallbackDelegate"] boolValue];

        
        LLZSharePlatformConfig *platformConfig = [[LLZSharePlatformConfig alloc] init];
        platformConfig.appID = appId;
        platformConfig.universalLink = universalLink;
        platformConfig.isCrossAppCallbackDelegate = isResponder;
        [[LLZShareChannelManager defaultManager] registerPlatform:sharePlatformType withPlatformConfig:platformConfig];
    }
    
    UIViewController *demoViewController = [[DemoViewController alloc] init];
    UINavigationController *navigationVC = [[UINavigationController alloc] initWithRootViewController:demoViewController];
    [self.window setRootViewController:navigationVC];
    [self.window makeKeyAndVisible];
    
    
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
