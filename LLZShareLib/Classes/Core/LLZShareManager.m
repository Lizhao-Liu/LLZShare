//
//  LLZShareManager.m
//  LLZShareLib
//
//  Created by Lizhao on 2022/10/18.
//

#import "LLZShareManager.h"
#import "LLZShareChannelManager.h"

@interface LLZShareManager ()

@property(nonatomic, strong) LLZShareChannelManager *channelManager;

@end

@implementation LLZShareManager

+ (void)shareToChannel:(LLZShareChannelType)shareChannelType
       withShareObject:(nullable LLZShareObject *)shareObject
 currentViewController:(nullable UIViewController *)currentViewController
      withShareContext:(LLZShareContextModel *)context
      withSuccessBlock:(ShareSuccessBlock)successBlock
       withCancelBlock:(ShareCancelBlock)cancelBlock
        withErrorBlock:(ShareErrorBlock)errorBlock {
    [[LLZShareChannelManager defaultManager] shareToChannel:shareChannelType
                                           withShareObject:shareObject
                                     currentViewController:currentViewController
                                          withShareContext:context
                                          withSuccessBlock:successBlock
                                           withCancelBlock:cancelBlock
                                            withErrorBlock:errorBlock];

}


+ (BOOL)isQQInstalled {
    return [[LLZShareChannelManager defaultManager] isInstalled:LLZShareChannelTypeQQ];
}
+ (BOOL)isWXAppInstalled {
    return [[LLZShareChannelManager defaultManager] isInstalled:LLZShareChannelTypeWechatSession];
}
+ (BOOL)isKSAppInstalled {
    return [[LLZShareChannelManager defaultManager] isInstalled:LLZShareChannelTypeKS];
}
+ (BOOL)isDYAppInstalled {
    return [[LLZShareChannelManager defaultManager] isInstalled:LLZShareChannelTypeDY];
}
+ (BOOL)isInstalled:(LLZShareChannelType)channelType {
    return [[LLZShareChannelManager defaultManager] isInstalled:channelType];
}

+ (NSArray *)allAvailableShareChannels {
    return [LLZShareChannelManager defaultManager].allAvailableShareChannels;
}

+ (void)setPushBlock:(LLZSharePushBlock)pushBlock {
    [LLZShareChannelManager defaultManager].pushBlock = pushBlock;
}

- (void)setTrackShareEventOn: (BOOL)isOn {
    [LLZShareChannelManager defaultManager].needTrackEvent = isOn;
}

+ (BOOL)sharelib_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions {
    return [[LLZShareChannelManager defaultManager] application:application didFinishLaunchingWithOptions:launchOptions];
}

+ (BOOL)sharelib_application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    return [[LLZShareChannelManager defaultManager] application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
}

+ (BOOL)sharelib_application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [[LLZShareChannelManager defaultManager] application:app openURL:url options:options];
}

+ (void)setTrackShareEventOn:(BOOL)isOn {
    [LLZShareChannelManager defaultManager].needTrackEvent = isOn;
}

@end
