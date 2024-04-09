//
//  LLZShareChannelManager.m
//  LLZShareLib
//
//  Created by Lizhao on 2022/10/24.
//

#import <sys/time.h>
#import "LLZShareChannelManager.h"
#import "LLZShareObject+LLZShareLib.h"
#import "LLZShareChannelHandler.h"
#import "LLZSharePhoneHandler.h"
#import "LLZShareSMSHandler.h"
#import "LLZShareSaveImageHandler.h"
#import "LLZShareSaveVideoHandler.h"
#import "LLZShareEventTracker.h"
#import "LLZService.h"
@import LLZShareService;
@import YYModel;

// 毫秒
#define SHARE_LIMIT_INTERVAL 1500

// 获取当前毫秒时间
long long currentMilliSecond(void) {
    struct timeval t;
    gettimeofday(&t,NULL);
    long long dwTime = ((long long)1000000 * t.tv_sec + (long long)t.tv_usec)/1000;
    return dwTime;
}

@interface LLZShareChannelManager ()

@property (nonatomic, strong) NSMutableDictionary * shareChannelHandlers;

@property (nonatomic, strong) NSMutableDictionary * platformShareHandlers;

@property (assign, nonatomic) long long lastShareTime;

@end

@implementation LLZShareChannelManager

+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    static LLZShareChannelManager  *instance;
    dispatch_once(&onceToken, ^{
        instance = [[LLZShareChannelManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super self];
    if(self) {
        _shareChannelHandlers = @{}.mutableCopy;
        _platformShareHandlers = @{}.mutableCopy;
        _needTrackEvent = YES;
    }
    return self;
}

#pragma mark - 直接分享

- (void)shareToChannel:(LLZShareChannelType)shareChannelType
       withShareObject:(nullable LLZShareObject *)shareObject
 currentViewController:(nullable UIViewController *)currentViewController
      withShareContext:(LLZShareContextModel *)context
      withSuccessBlock:(ShareSuccessBlock)successBlock
       withCancelBlock:(ShareCancelBlock)cancelBlock
        withErrorBlock:(ShareErrorBlock)errorBlock {

    // 防bb web容器分段式分享重复调用,2s内只能分享一次
    if(![self canShare]){
        return;
    }
    
    // 选择对应渠道的分享处理类
    id<LLZShareChannelHandler> targetHandler = [self.shareChannelHandlers objectForKey:@(shareChannelType)];
    if(!targetHandler) {
        if(errorBlock){
            errorBlock(DefaultShareChannelTitle, [NSError errorWithDomain:LLZShareErrorDomain code:LLZShareErrorType_NoGetShareChannel userInfo:@{NSLocalizedDescriptionKey:@"传递分享渠道错误"}]);
        }
        return;
    }
    if(![self.allRegisteredShareChannels containsObject:@(shareChannelType)]){
        if(errorBlock){
            errorBlock(DefaultShareChannelTitle, [NSError errorWithDomain:LLZShareErrorDomain code:LLZShareErrorType_NotRegistered userInfo:@{NSLocalizedDescriptionKey:@"尚未向平台注册app"}]);
        }
        return;
    }
    targetHandler.shareChannelType = shareChannelType;
    
    // 交由对应分享处理类处理分享请求并返回结果
    if(_needTrackEvent){
        NSString *shareObjStr = [shareObject yy_modelToJSONString];
        [targetHandler shareWithObject:shareObject
                    withViewController:currentViewController
                      withSuccessBlock:^(LLZShareResponseTitle title, NSString * _Nonnull msg) {
            if(successBlock){
                successBlock(title, msg);
            }
            NSLog(@"%@:  %@  share_channel_code: %lu  share_object: %@", title, msg, (unsigned long)shareChannelType, shareObjStr);
         
            [LLZShareEventTracker shareResultTrackWithShareChannel:shareChannelType shareResult:YES shareContext:context];
        }
                       withCancelBlock:^(LLZShareResponseTitle title, NSString * _Nonnull msg) {
            if(cancelBlock){
                cancelBlock(title, msg);
            }
            NSLog(@"%@:  %@  share_channel_code: %lu  share_object: %@", title, msg, (unsigned long)shareChannelType, shareObjStr);
          
            [LLZShareEventTracker shareResultTrackWithShareChannel:shareChannelType shareResult:NO shareContext:context];
        }
                        withErrorBlock:^(LLZShareResponseTitle title, NSError * _Nonnull error) {
            if(errorBlock){
                errorBlock(title, error);
            }
            NSLog(@"%@:  分享失败  error: %@  share_channel_code: %lu  share_object: %@", title, error, (unsigned long)shareChannelType, shareObjStr);
            [LLZShareEventTracker shareResultTrackWithShareChannel:shareChannelType shareResult:NO shareContext:context];
        }];
    } else {
        [targetHandler shareWithObject:shareObject
                    withViewController:currentViewController
                      withSuccessBlock:successBlock
                       withCancelBlock:cancelBlock
                        withErrorBlock:errorBlock];
    }
}


#pragma mark - 分享平台状态查询

- (BOOL)isInstalled:(LLZShareChannelType)channelType {
    id<LLZShareChannelHandler> handler = [self.shareChannelHandlers objectForKey:@(channelType)];
    if(!handler) return NO;
    if([handler respondsToSelector:@selector(isInstalled)]){
        return [handler isInstalled];
    }
    return YES;
}

- (BOOL)isSupportSharing:(LLZShareChannelType)channelType {
    id<LLZShareChannelHandler> handler = [self.shareChannelHandlers objectForKey:@(channelType)];
    if(!handler) return NO;
    if([handler respondsToSelector:@selector(isSupport)]){
        return [handler isSupport];
    }
    return YES;
}

- (BOOL)isRegistered:(LLZShareChannelType)channelType {
    id<LLZShareChannelHandler> handler = [self.shareChannelHandlers objectForKey:@(channelType)];
    if(!handler) return NO;
    if([handler respondsToSelector:@selector(isRegistered)]){
        return [handler isRegistered];
    }
    return YES;
}

- (BOOL)isChannel:(LLZShareChannelType)channelType SupportSharingWithObject:(LLZShareObject *)shareObject {
    if([shareObject isKindOfClass:[LLZShareAutoTypeObject class]]){
        shareObject = [(LLZShareAutoTypeObject *)shareObject typedshareObject];
    }
    SupportShareObjectOptions option;
    if([shareObject isKindOfClass:[LLZShareImageObject class]]){
        option = SupportShareObjectImage;
    } else if ([shareObject isKindOfClass:[LLZShareVideoObject class]]) {
        option = SupportShareObjectVideo;
    } else if ([shareObject isKindOfClass:[LLZShareWebpageObject class]]) {
        option = SupportShareObjectWebpage;
    } else if ([shareObject isKindOfClass:[LLZShareMiniProgramObject class]]) {
        option = SupportShareObjectMiniApp;
    } else {
        option = SupportShareObjectMessage;
    }
    id<LLZShareChannelHandler> handler = [self.shareChannelHandlers objectForKey:@(channelType)];
    if(!handler) return NO;
    handler.shareChannelType = channelType;
    if([handler supportSharingObjectOptions] & option){
        return YES;
    }
    return NO;
}

- (NSArray *)allRegisteredShareChannels {
     NSMutableArray *channelArray = [NSMutableArray array];
    for(id channelKey in self.shareChannelHandlers){
        id<LLZShareChannelHandler> handler = self.shareChannelHandlers[channelKey];
        if([handler respondsToSelector:@selector(isRegistered)] && ![handler isRegistered]){
            continue;
        }
        [channelArray addObject:channelKey];
    }
    return channelArray;
}

- (NSArray *)allAvailableShareChannels {
    NSMutableArray *filteredChannels = [LLZShareChannelManager defaultManager].allRegisteredShareChannels.mutableCopy;
    NSMutableArray *tempChannels = filteredChannels.mutableCopy;
    NSArray *allRegisteredShareChannels = [LLZShareChannelManager defaultManager].allRegisteredShareChannels;
    // 过滤一遍未注册的分享平台
    for(id channel in tempChannels){
        LLZShareChannelType channelType = [channel integerValue];
        if(![allRegisteredShareChannels  containsObject:@(channelType)]){
            [filteredChannels removeObject:@(channelType)];
        }
    }
    if(filteredChannels.count == 0){
        return @[];
    }
    tempChannels = filteredChannels.mutableCopy;
    
    // 过滤一遍未安装的分享平台
    for(id channel in tempChannels){
        LLZShareChannelType channelType = [channel integerValue];
        if(![[LLZShareChannelManager defaultManager] isInstalled:channelType]){
            [filteredChannels removeObject:@(channelType)];
        }
    }
    if(filteredChannels.count == 0){
        return @[];
    }
    tempChannels = filteredChannels.mutableCopy;
    
    // 过滤一遍目前不支持分享的渠道
    for(id channel in tempChannels){
        LLZShareChannelType channelType = [channel integerValue];
        if(![[LLZShareChannelManager defaultManager] isSupportSharing:channelType]){
            [filteredChannels removeObject:@(channelType)];
        }
    }
    if(filteredChannels.count <= 0){
        return @[];
    }
    return filteredChannels.copy;
}

#pragma mark - 第三方平台返回分享消息回调

- (void)onShareResp:(id)resp forPlatform:(LLZSharePredefinedPlatformType)platform{
    id<LLZShareChannelHandler> handler;
    switch(platform){
        case LLZSharePlatformDY:
            handler = [self shareHandlerWithChannelType:LLZShareChannelTypeDY];
            break;
        case LLZSharePlatformKS:
            handler = [self shareHandlerWithChannelType:LLZShareChannelTypeKS];
            break;
        case LLZSharePlatformQQ:
            handler = [self shareHandlerWithChannelType:LLZShareChannelTypeQQ];
            break;
        case LLZSharePlatformWechat:
            handler = [self shareHandlerWithChannelType:LLZShareChannelTypeWechatSession];
            break;
    }
    if([handler respondsToSelector:@selector(onResp:)] && [handler respondsToSelector:@selector(platformConfig)] && handler.platformConfig.isCrossAppCallbackDelegate == NO){
        [handler onResp:resp];
    }
}

- (id<LLZShareChannelHandler>)shareHandlerWithChannelType:(LLZShareChannelType)shareChannelType {
    id<LLZShareChannelHandler> targetHandler = [self.shareChannelHandlers objectForKey:@(shareChannelType)];
    return targetHandler ?: nil;
}

#pragma mark - 初始化 & 配置 & 注册平台

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions {
    [self setUpBuiltInHandlers];
    [self setUpRuntimeHandlers];
    for(id<LLZShareChannelHandler>handler in self.shareChannelHandlers.allValues){
        if([handler respondsToSelector:@selector(share_applicationshare_application:didFinishLaunchingWithOptions:)]){
            [handler share_application:application didFinishLaunchingWithOptions:launchOptions];
        }
    }
    return YES;
}

- (void)setPushBlock:(LLZSharePushBlock)pushBlock {
    if(pushBlock && self.shareChannelHandlers.count > 0){
        for(id channelKey in self.shareChannelHandlers){
            id<LLZShareChannelHandler> handler = self.shareChannelHandlers[channelKey];
            if([handler respondsToSelector:@selector(pushBlock)]){
                handler.pushBlock = pushBlock;
            }
        }
    }
}

- (BOOL)registerPlatform:(NSInteger)platform withPlatformConfig:(nonnull LLZSharePlatformConfig *)platformConfig {
    
    id<LLZShareChannelHandler> platformShareHandler = (id<LLZShareChannelHandler>)[self.platformShareHandlers objectForKey:@(platform)];
    
    NSAssert(platformShareHandler != nil, @"当前app未集成分享平台%d对应模块", (int)platform);
    NSAssert([platformShareHandler respondsToSelector:@selector(supportShareChannels)], @"三方平台分享渠道需要实现supportShareChannels");
    NSAssert([platformShareHandler respondsToSelector:@selector(registerApp)], @"三方平台分享协议需要实现registerApp");
    NSAssert([platformShareHandler respondsToSelector:@selector(platformConfig)], @"三方平台分享协议需要声明platformConfig");
    
    platformShareHandler.platformConfig = platformConfig;
    if([platformShareHandler registerApp]){
        for(NSNumber *shareChannel in platformShareHandler.supportShareChannels){
            [self.shareChannelHandlers setObject:platformShareHandler forKey:shareChannel];
        }
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - 分享跳转回调

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    for(id<LLZShareChannelHandler>handler in self.shareChannelHandlers.allValues){
        if([handler respondsToSelector:@selector(share_applicationshare_applicationshare_applicationshare_application:continueUserActivity:restorationHandler:)]){
            if([handler share_application:application continueUserActivity:userActivity restorationHandler:restorationHandler]){
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    for(id<LLZShareChannelHandler>handler in self.shareChannelHandlers.allValues){
        if([handler respondsToSelector:@selector(share_applicationshare_applicationshare_applicationshare_applicationshare_application:openURL:options:)]){
            if([handler share_application:app openURL:url options:options]){
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark - 分享渠道字符串转换

- (LLZShareResponseChannelStr)shareChannelStr: (LLZShareChannelType)type {
    switch (type) {
        case LLZShareChannelTypeSaveImage:
            return SaveImage;
        case LLZShareChannelTypeSaveVideo:
            return SaveVideo;
        case LLZShareChannelTypeSMS:
            return SMS;
        case LLZShareChannelTypePhone:
            return Phone;
        case LLZShareChannelTypeWechatSession:
            return WechatSession;
        case LLZShareChannelTypeWechatTimeline:
            return WechatTimeLine;
        case LLZShareChannelTypeQQ:
            return QQ;
        case LLZShareChannelTypeQzone:
            return QZone;
        case LLZShareChannelTypeDY:
            return DouYin;
        case LLZShareChannelTypeKS:
            return KuaiShou;
        default:
            return NoShareChannel;
    }
}


# pragma mark - private methods

- (void)setUpBuiltInHandlers {
    LLZShareSMSHandler *smsHandler = [[LLZShareSMSHandler alloc] init];
    LLZSharePhoneHandler *phoneHandler = [[LLZSharePhoneHandler alloc] init];
    LLZShareSaveImageHandler *saveImageHandler = [[LLZShareSaveImageHandler alloc] init];
    LLZShareSaveVideoHandler *saveVideoHandler = [[LLZShareSaveVideoHandler alloc] init];
    NSDictionary *builtInHandlers = @{
        @(LLZShareChannelTypeSaveImage):saveImageHandler,
        @(LLZShareChannelTypeSaveVideo):saveVideoHandler,
        @(LLZShareChannelTypeSMS):smsHandler,
        @(LLZShareChannelTypePhone):phoneHandler
    };
    [self.shareChannelHandlers addEntriesFromDictionary:builtInHandlers];
}

- (void)setUpRuntimeHandlers {
    NSArray<id<LLZShareChannelHandler>> *handlers =  (NSArray<id<LLZShareChannelHandler>> *)[[LLZService shared] servicesForProtocol:@protocol(LLZShareChannelHandler) fromContext:nil];
    
    for(id<LLZShareChannelHandler> handler in handlers) {
        if([handler respondsToSelector:@selector(setUp)]){
            [handler setUp]; // 初始化
        }
        
        NSAssert([handler respondsToSelector:@selector(platformType)], @"分享协议实现需声明三方平台类型 platformType");
        
        [self.platformShareHandlers setObject:handler forKey:@(handler.platformType)];
        
    }
}

- (BOOL)canShare {
    long long nowtime = currentMilliSecond();
    long long space = nowtime - _lastShareTime;
    
    _lastShareTime = nowtime;
    //2s内只能分享一次，主要是防bb web容器分段式分享重复调用
    if (space <= SHARE_LIMIT_INTERVAL) {
        return NO;
    }
    return YES;
}

@end
