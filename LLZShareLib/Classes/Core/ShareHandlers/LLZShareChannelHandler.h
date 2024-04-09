//
//  LLZShareChannelHandler.h
//  LLZShareLib
//
//  Created by Lizhao on 2022/10/18.
//

#import <Foundation/Foundation.h>
@import LLZShareService;
#import "LLZServiceCenter.h"

NS_ASSUME_NONNULL_BEGIN

@interface LLZSharePlatformConfig : NSObject

@property (nonatomic, copy) NSString *appID;

@property (nonatomic, copy) NSString *universalLink;

// 是否在分享库中处理其他平台消息回调
// 比如微信app消息回调涉及支付/登陆等场景回调，这里需要设置为no
@property (nonatomic, assign) BOOL isCrossAppCallbackDelegate;

@end


typedef NS_OPTIONS(NSUInteger, SupportShareObjectOptions) {
    SupportShareObjectMessage = 1 << 0,
    SupportShareObjectImage = 1 << 1,
    SupportShareObjectVideo = 1 << 2,
    SupportShareObjectWebpage = 1 << 3,
    SupportShareObjectMiniApp = 1 << 4,
};

@class LLZShareObject;

@protocol LLZShareChannelHandler <NSObject, LLZServiceProtocol>

@required

// 分享名称
@property(nonatomic, strong) NSString *shareTitle;

// 实现分享方法
- (void)shareWithObject:(nullable LLZShareObject *)object
     withViewController:(nullable UIViewController*)viewController
       withSuccessBlock:(ShareSuccessBlock)successHandler
        withCancelBlock:(ShareCancelBlock)cancelHandler
         withErrorBlock:(ShareErrorBlock)errorHandler;

// 渠道支持的分享内容类型
- (SupportShareObjectOptions)supportSharingObjectOptions;

// 当前分享渠道类型 比如微信聊天和微信朋友圈
@property(nonatomic, assign) LLZShareChannelType shareChannelType;

@optional

- (void)setUp;

// 渠道在分享菜单上的名称
@property(nonatomic, strong) NSString *shareChannelName;

// 渠道在分享菜单上的图标
@property(nonatomic, strong) UIImage *shareChannelIcon;

// 触发 push
@property(nonatomic,copy) LLZSharePushBlock pushBlock;

#pragma mark - 三方平台分享渠道相关

// 所属第三方分享平台类型
@property(nonatomic, assign) NSInteger platformType;

// 第三方分享平台配置信息, 外部读取info.plist设置
@property(nonatomic, strong) LLZSharePlatformConfig *platformConfig;

// 第三方分享平台支持的分享渠道类型
@property(nonatomic, strong) NSArray *supportShareChannels;

@property(nonatomic, assign) BOOL isRegistered;

// 向三方平台注册app
- (BOOL)registerApp;
// 渠道是否被安装
-(BOOL)isInstalled;
// 渠道是否支持分享
-(BOOL)isSupport;
// 接受第三方平台返回消息的回调
- (void)onResp:(id)resp;

// 从第三方平台回调到本app的回调
- (BOOL)share_application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler;
- (BOOL)share_application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options;

// 处理生命周期
- (BOOL)share_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions;

@end

NS_ASSUME_NONNULL_END
