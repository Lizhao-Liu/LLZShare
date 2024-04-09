//
//  LLZShareManager.h
//  LLZShareLib
//
//  Created by Lizhao on 2022/10/18.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@import LLZShareService;

NS_ASSUME_NONNULL_BEGIN

@interface LLZShareManager : NSObject

#pragma mark - 直接分享(无UI分享)
/// 直接分享
/// @param shareChannelType 目标分享渠道 渠道类型 @see LLZShareChannelType
/// @param shareObject 分享的内容 @see LLZShareObject
/// @note shareObject 电话分享场景则不需要传入分享内容object
/// @param currentViewController 只针对sms等需要传入viewcontroller的渠道, 非必填, 默认使用当前正在展示的vc
/// @param context 分享的context信息, 用于埋点上报使用 @see LLZShareContextModel
/// @param successBlock 分享成功的回调
/// @param cancelBlock 分享取消的回调
/// @param errorBlock 分享失败的回调
+ (void)shareToChannel:(LLZShareChannelType)shareChannelType
       withShareObject:(nullable LLZShareObject *)shareObject
 currentViewController:(nullable UIViewController *)currentViewController
      withShareContext:(LLZShareContextModel *)context
      withSuccessBlock:(ShareSuccessBlock)successBlock
       withCancelBlock:(ShareCancelBlock)cancelBlock
        withErrorBlock:(ShareErrorBlock)errorBlock;



#pragma mark - 查询平台是否安装
+ (BOOL)isQQInstalled;
+ (BOOL)isWXAppInstalled;
+ (BOOL)isKSAppInstalled;
+ (BOOL)isDYAppInstalled;
+ (BOOL)isInstalled:(LLZShareChannelType)channelType;

+ (NSArray *)allAvailableShareChannels;


#pragma mark - 分享跳转回调
+ (BOOL)sharelib_application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler;

+ (BOOL)sharelib_application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options;


#pragma mark - LLZShareLib初始化
+ (BOOL)sharelib_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions;


#pragma mark - LLZShareLib配置
// 设置推送push block
+ (void)setPushBlock: (LLZSharePushBlock)pushBlock;

// 设置开启记录埋点 默认开启
+ (void)setTrackShareEventOn: (BOOL)isOn;
@end

NS_ASSUME_NONNULL_END
