//
//  LLZShareChannelManager.h
//  LLZShareLib
//
//  Created by Lizhao on 2022/10/24.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@import LLZShareService;

NS_ASSUME_NONNULL_BEGIN
@protocol LLZShareChannelHandler;
@class LLZSharePlatformConfig;

@interface LLZShareChannelManager : NSObject

// 返回所有已向第三方平台注册的分享渠道
@property(nonatomic,readonly,strong) NSArray * allRegisteredShareChannels;

@property(nonatomic,readonly,strong) NSArray * allAvailableShareChannels;

// 触发 push
@property(nonatomic,copy) LLZSharePushBlock pushBlock;


@property(nonatomic,assign) BOOL needTrackEvent;


+ (instancetype)defaultManager;

/// 注册分享平台信息
- (BOOL)registerPlatform:(NSInteger)platform
      withPlatformConfig:(LLZSharePlatformConfig *)platformConfig;

//// 获得对应的分享渠道类型的id<LLZShareChannelHandler>渠道类
- (id<LLZShareChannelHandler>)shareHandlerWithChannelType:(LLZShareChannelType)shareChannelType;

/// 三方分享回调
- (void)onShareResp:(id)resp forPlatform:(LLZSharePredefinedPlatformType)platform;

/// 直接分享
/// @param shareChannelType 目标分享渠道 渠道类型 @see LLZShareChannelType
/// @param shareObject 分享的内容 @see LLZShareObject
/// @note shareObject 电话分享场景则不需要传入分享内容object
/// @param currentViewController 只针对sms等需要传入viewcontroller的渠道, 非必填, 默认使用当前正在展示的vc
/// @param context 分享的context信息, 用于埋点上报使用 @see LLZShareContextModel
/// @param successBlock 分享成功的回调
/// @param cancelBlock 分享取消的回调
/// @param errorBlock 分享失败的回调
- (void)shareToChannel:(LLZShareChannelType)shareChannelType
       withShareObject:(nullable LLZShareObject *)shareObject
 currentViewController:(nullable UIViewController *)currentViewController
      withShareContext:(LLZShareContextModel *)context
      withSuccessBlock:(ShareSuccessBlock)successBlock
       withCancelBlock:(ShareCancelBlock)cancelBlock
        withErrorBlock:(ShareErrorBlock)errorBlock;


// 查询平台是否安装
- (BOOL)isInstalled:(LLZShareChannelType)channelType;

// 查询平台是否注册
- (BOOL)isRegistered:(LLZShareChannelType)channelType;

// 查询平台是否支持分享
- (BOOL)isSupportSharing:(LLZShareChannelType)channelType;

// 查询平台是否支持分享该类型
- (BOOL)isChannel:(LLZShareChannelType)channelType SupportSharingWithObject:(LLZShareObject *)shareObject;

// LLZShareLib初始化
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions;

// 分享跳转回调
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler;
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options;

///获得对应的分享渠道的字符串名称
- (LLZShareResponseChannelStr)shareChannelStr:(LLZShareChannelType)type;
@end

NS_ASSUME_NONNULL_END
