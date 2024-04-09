//
//  LLZShareWechatHandler.m
//  LLZShareLib
//
//  Created by Lizhao on 2022/10/18.
//

#import <WechatOpenSDK/WXApi.h>
#import "LLZShareWechatHandler.h"
#import "WXApiRequestHandler.h"
#import <WechatOpenSDK/WXApi.h>
@import LLZShareLib;

@interface WXLogger : NSObject <WXApiLogDelegate>

+(instancetype)sharedWXLogger;

- (void)startLogWithLevel:(WXLogLevel)level;

@end

@implementation WXLogger

+ (instancetype)sharedWXLogger {
    static dispatch_once_t onceToken;
    static WXLogger  *instance;
    dispatch_once(&onceToken, ^{
        instance = [[WXLogger alloc] init];
    });
    return instance;
}

- (void)startLogWithLevel: (WXLogLevel)level {
    [WXApi startLogByLevel:level logDelegate: self];
}

- (void)onLog:(nonnull NSString *)log logLevel:(WXLogLevel)level {
    NSLog(@"%@", log);
}

@end

@interface LLZShareWechatHandler ()<WXApiDelegate>

@property (nonatomic, strong) LLZShareObject *shareObject;

@property (nonatomic, copy) ShareSuccessBlock successBlock;
@property (nonatomic, copy) ShareCancelBlock cancelBlock;
@property (nonatomic, copy) ShareErrorBlock errorBlock;

@property(assign,nonatomic) enum WXScene currentScene;
@property(assign,nonatomic) BOOL miniProgramTypeDidSet;

@end

@serviceEX(LLZShareWechatHandler, LLZShareChannelHandler)
//@implementation LLZShareWechatHandler

@synthesize platformType = _platformType;
@synthesize shareTitle = _shareTitle;
@synthesize shareChannelType = _shareChannelType;
@synthesize platformConfig = _platformConfig;
@synthesize isRegistered = _isRegistered;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _platformType = LLZSharePlatformWechat;
        _shareTitle = WechatShareChannelTitle;
    }
    return self;
}

- (void)setUp {
    if(self.needLogFromWX){
        [[WXLogger sharedWXLogger] startLogWithLevel:WXLogLevelNormal];
    }
}

- (BOOL)registerApp {
    _isRegistered = [WXApi registerApp:_platformConfig.appID universalLink:_platformConfig.universalLink];
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    if(_isRegistered){
        NSLog(@"微信平台注册app成功, bundle id: %@", bundleID);
    } else {
        NSLog(@"微信平台注册app失败, bundle id: %@", bundleID);
    }
    return _isRegistered;
}

- (void)shareWithObject:(nullable LLZShareObject *)object
     withViewController:(nullable UIViewController*)viewController
       withSuccessBlock:(ShareSuccessBlock)successHandler
        withCancelBlock:(ShareCancelBlock)cancelHandler
         withErrorBlock:(ShareErrorBlock)errorHandler {
    [self registerApp];
    [self shareInfoReset];
    
    self.successBlock = successHandler;
    self.cancelBlock = cancelHandler;
    self.errorBlock = errorHandler;
    
    if(![self isPreparedForSharing]){
        return;
    }
    if(![self setUpshareObject:object]){
        return;
    }
    [self shareToWechat];
}

- (void)sendMiniProgramUsername:(NSString *)userName
                              path:(NSString *)path
                              type:(NSInteger )type
                        completion:(void (^)(BOOL success))completion {
    [self registerApp];
    [WXApiRequestHandler sendMiniProgramUsername:userName path:path type:type completion:completion];
}

- (BOOL)isPreparedForSharing {
    if(![self isInstalled]){
        NSError *error = [[NSError alloc] initWithDomain:LLZShareErrorDomain code:LLZShareErrorType_NotInstall userInfo:@{NSLocalizedDescriptionKey:@"手机尚未安装微信"}];
        if(self.errorBlock){
            self.errorBlock(self.shareTitle, error);
        }
        return NO;
    }
    if(![self isSupport]){
        NSError *error = [[NSError alloc] initWithDomain:LLZShareErrorDomain code:LLZShareErrorType_NotSupport userInfo:@{NSLocalizedDescriptionKey:@"微信版本过低"}];
        if(self.errorBlock){
            self.errorBlock(self.shareTitle, error);
        }
        return NO;
    }
    return YES;
}

- (BOOL)setUpshareObject:(LLZShareObject *)shareObject{
    if(shareObject == nil) {
        if(self.errorBlock){
            NSError *error = [NSError errorWithDomain:LLZShareErrorDomain code:LLZShareErrorType_shareObjectNil userInfo:@{NSLocalizedDescriptionKey: @"未传入分享内容"}];
            self.errorBlock(self.shareTitle, error);
        }
        return NO;
    }
    if([shareObject isKindOfClass:[LLZShareAutoTypeObject class]]){
        shareObject = [(LLZShareAutoTypeObject *)shareObject typedshareObject];
    }
    NSError *error;
    [shareObject buildValidshareObjectWithError:&error];
    if(error){
        if(self.errorBlock){
            self.errorBlock(self.shareTitle, error);
        }
        return NO;
    }
    self.shareObject = shareObject;
    return YES;
}

- (void)shareToWechat {
    if([self.shareObject isKindOfClass:[LLZShareMessageObject class]]){
        [self shareMessageToWechat];
    } else if([self.shareObject isKindOfClass:[LLZShareImageObject class]]){
        [self shareImageToWechat];
    } else if([self.shareObject isKindOfClass:[LLZShareWebpageObject class]]){
        [self shareWebLinkToWechat];
        
    } else if([self.shareObject isKindOfClass:[LLZShareMiniProgramObject class]]){
        [self shareMiniProgramToWechat];
    } else {
        if(self.errorBlock){
            NSError *error = [[NSError alloc] initWithDomain:LLZShareErrorDomain code:LLZShareErrorType_shareObjectTypeIllegal userInfo:@{NSLocalizedDescriptionKey: @"传入数据类型不支持，微信分享仅支持链接/图片/小程序/文字"}];
            self.errorBlock(self.shareTitle, error);
        }
        return;
    }
}

- (void)shareMessageToWechat {
    LLZShareMessageObject *object = (LLZShareMessageObject *)self.shareObject;
    [WXApiRequestHandler sendText:object.shareContent InScene:self.currentScene];
}

- (void)shareImageToWechat {
    LLZShareImageObject *object = (LLZShareImageObject *)self.shareObject;
    UIImage *thumbImage;
    if(object.thumbImage){
        thumbImage = [LLZShareImageUtils imageByScalingImage:object.thumbImage proportionallyToSize:CGSizeMake(100, 100)];
    } else {
        thumbImage = [LLZShareImageUtils imageByScalingImage:object.shareImage proportionallyToSize:CGSizeMake(100, 100)];
    }
    NSData *imgData = [LLZShareImageUtils imageDataFromImage:object.shareImage isPNG:object.isPNG];
    [WXApiRequestHandler  sendImageData:imgData
                                TagName:@""
                             MessageExt:nil
                                 Action:nil
                             ThumbImage:thumbImage
                                InScene:self.currentScene];
}

- (void)shareWebLinkToWechat {
    LLZShareWebpageObject *object = (LLZShareWebpageObject *)self.shareObject;
    if([object.shareTitle isEmpty] && [object.shareContent isEmpty]){
        if(self.errorBlock){
            self.errorBlock(self.shareTitle, [NSError errorWithDomain:LLZShareErrorDomain code:LLZShareErrorType_shareObjectIncomplete userInfo:@{NSLocalizedDescriptionKey:@"微信网页分享, title与content不可同时为空"}]);
        }
        return;
    }

    UIImage *thumbImage = [LLZShareImageUtils imageByScalingImage:object.thumbImage proportionallyToSize:CGSizeMake(100, 100)];
    if (thumbImage) {
        NSData *data = [LLZShareImageUtils imageDataByCompressImage:thumbImage toLength:30];
        if (data) {
            thumbImage = [UIImage imageWithData:data];
        }
    }
    [WXApiRequestHandler sendLinkURL:object.webpageUrl
                             TagName:@""
                               Title:object.shareTitle
                         Description:object.shareContent
                          ThumbImage:thumbImage
                             InScene:self.currentScene];
}

- (void)shareMiniProgramToWechat {
    LLZShareMiniProgramObject *object = (LLZShareMiniProgramObject *)self.shareObject;
    //hdImageData: 小程序节点高清大图,小于128K
    NSData *hdImageData = nil;
    if (object.hdImage) {
        hdImageData = [LLZShareImageUtils imageDataByCompressImage:object.hdImage toLength:125];
        
    }
    WXMiniProgramType type = WXMiniProgramTypeRelease;
    if(object.type){ // 传入了小程序类型参数需要指定小程序版本类型
        if([object.type isEqualToString:LLZShareMiniProgramTypeRelease]){
            type = WXMiniProgramTypeRelease;
        }
        else if([object.type isEqualToString:LLZShareMiniProgramTypeTest]){
            type = WXMiniProgramTypeTest;
        }
        else if([object.type isEqualToString:LLZShareMiniProgramTypePreview]){
            type = WXMiniProgramTypePreview;
        } else { // 小程序版本类型参数错误
            if(self.errorBlock){
                self.errorBlock(self.shareTitle, [NSError errorWithDomain:LLZShareErrorDomain code:LLZShareErrorType_shareObjectIncomplete userInfo:@{NSLocalizedDescriptionKey:@"小程序指定版本类型仅支持 release / test / preview"}]);
            }
            return;
        }
    }

    [WXApiRequestHandler sendMiniProgram:object.sharePageUrl
                                userName:object.userName
                                    path:object.path
                             hdImageData:hdImageData
                                   title:object.shareTitle
                             description:object.shareContent
                                miniType:type];
}

- (BOOL)isInstalled {
    return [WXApi isWXAppInstalled];
}

- (BOOL)isSupport {
    return [WXApi isWXAppSupportApi];
}

- (BOOL)share_application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    if(_platformConfig.isCrossAppCallbackDelegate){
        return [WXApi handleOpenURL:url delegate:self];
    }
    return NO;
}

- (BOOL)share_application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    if(_platformConfig.isCrossAppCallbackDelegate){
        return [WXApi handleOpenUniversalLink:userActivity delegate:self];
    }
    return NO;
}

- (void)onResp:(BaseResp *)resp {
    if(![resp isKindOfClass:[SendMessageToWXResp class]]){
        return;
    }
    SendMessageToWXResp *messageResp = (SendMessageToWXResp *)resp;
    
    if (messageResp.errCode == 0) {
        if(self.successBlock){
            self.successBlock(self.shareTitle, @"微信分享成功");
        }
    }
    else if (messageResp.errCode == WXErrCodeUserCancel) {
        if (self.cancelBlock) {
            self.cancelBlock(self.shareTitle, @"微信分享取消");
        }
    }
    else {
        if (self.errorBlock) {
            NSError *error = [NSError errorWithDomain:LLZShareErrorDomain code:LLZShareErrorType_ShareFailed userInfo:@{NSLocalizedDescriptionKey:messageResp.errStr?:@"微信分享失败"}];
            self.errorBlock(self.shareTitle, error);
        }
    }
    [self shareInfoReset];
}

#pragma mark - private methods

- (enum WXScene)currentScene {
    if(self.shareChannelType == LLZShareChannelTypeWechatSession){
        return WXSceneSession;
    } else {
        return WXSceneTimeline;
    }
}

- (void)shareInfoReset {
    self.shareObject = nil;
    self.successBlock = nil;
    self.errorBlock = nil;
    self.cancelBlock = nil;
}

- (SupportShareObjectOptions)supportSharingObjectOptions {
    if(self.shareChannelType == LLZShareChannelTypeWechatSession){
        return SupportShareObjectImage | SupportShareObjectMessage | SupportShareObjectWebpage | SupportShareObjectMiniApp;
    }
    return SupportShareObjectImage | SupportShareObjectMessage | SupportShareObjectWebpage;
}

- (NSArray *)supportShareChannels {
    return @[@(LLZShareChannelTypeWechatSession), @(LLZShareChannelTypeWechatTimeline)];
}


@end


