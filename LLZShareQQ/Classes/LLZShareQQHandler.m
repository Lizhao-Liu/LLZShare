//
//  LLZShareQQHandler.m
//  LLZShareLib
//
//  Created by Lizhao on 2022/10/18.
//

#import "LLZShareQQHandler.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import <TencentOpenAPI/TencentOAuth.h>
@import LLZShareLib;

@interface LLZShareQQHandler ()<TencentSessionDelegate, QQApiInterfaceDelegate>

@property (nonatomic, strong) LLZShareObject *shareObject;

@property (nonatomic, copy) ShareSuccessBlock successBlock;
@property (nonatomic, copy) ShareCancelBlock cancelBlock;
@property (nonatomic, copy) ShareErrorBlock errorBlock;

@end

@serviceEX(LLZShareQQHandler, LLZShareChannelHandler)

@synthesize platformType = _platformType;
@synthesize shareTitle = _shareTitle;
@synthesize shareChannelType = _shareChannelType;
@synthesize platformConfig = _platformConfig;
@synthesize isRegistered = _isRegistered;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _platformType = LLZSharePlatformQQ;
        _shareTitle = QQShareChannelTitle;
    }
    return self;
}

- (BOOL)registerApp {
    if([[TencentOAuth alloc] initWithAppId:_platformConfig.appID andUniversalLink:_platformConfig.universalLink andDelegate:self]){
        _isRegistered = YES;
    }
    if(_isRegistered){
        NSLog(@"qq平台注册app成功, appid: %@, universallink: %@", _platformConfig.appID, _platformConfig.universalLink);
    } else {
        NSLog(@"qq平台注册app失败");
    }
    return _isRegistered;
}

- (BOOL)isInstalled {
    return [QQApiInterface isQQInstalled];
}

- (BOOL)isSupport {
    return [QQApiInterface isQQSupportApi];
}

- (void)shareWithObject:(nullable LLZShareObject *)object
     withViewController:(nullable UIViewController*)viewController
       withSuccessBlock:(ShareSuccessBlock)successHandler
        withCancelBlock:(ShareCancelBlock)cancelHandler
         withErrorBlock:(ShareErrorBlock)errorHandler {
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
    
    if(![self shareToQQ]){
        return;
    }
}

- (BOOL)isPreparedForSharing {
    if(![self isInstalled]){
        NSError *error = [[NSError alloc] initWithDomain:LLZShareErrorDomain code:LLZShareErrorType_NotInstall userInfo:@{NSLocalizedDescriptionKey:@"手机尚未安装QQ"}];
        if(self.errorBlock){
            self.errorBlock(self.shareTitle, error);
        }
        return NO;
    }
    if(![self isSupport]){
        NSError *error = [[NSError alloc] initWithDomain:LLZShareErrorDomain code:LLZShareErrorType_NotSupport userInfo:@{NSLocalizedDescriptionKey:@"QQ版本过低"}];
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

-(BOOL)shareToQQ {
    if([self.shareObject isKindOfClass:[LLZShareMessageObject class]]){
        return [self shareMessageToQQ];
    } else if([self.shareObject isKindOfClass:[LLZShareImageObject class]]){
        return [self shareImageToQQ];
    } else if([self.shareObject isKindOfClass:[LLZShareWebpageObject class]]){
        return [self shareWebPageToQQ];
    } else {
        if(self.errorBlock){
            NSError *error = [[NSError alloc] initWithDomain:LLZShareErrorDomain code:LLZShareErrorType_shareObjectTypeIllegal userInfo:@{NSLocalizedDescriptionKey: @"传入数据类型不支持，qq分享仅支持链接/图片/文字"}];
            self.errorBlock(self.shareTitle, error);
        }
        return NO;
    }
}

- (BOOL)shareMessageToQQ {
    LLZShareMessageObject *txtobject = (LLZShareMessageObject *)self.shareObject;
    QQApiSendResultCode sent = EQQAPISENDFAILD;
    // qq好友聊天分享
    if (LLZShareChannelTypeQQ == self.shareChannelType) {
        QQApiTextObject *txtObj = [QQApiTextObject objectWithText:txtobject.shareContent];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:txtObj];
        sent = [QQApiInterface sendReq:req];
    } else {
        // qq空间分享
        QQApiImageArrayForQZoneObject *obj = [QQApiImageArrayForQZoneObject
                                              objectWithimageDataArray:nil
                                              title:txtobject.shareContent
                                              extMap:nil];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:obj];
        sent = [QQApiInterface SendReqToQZone:req];
    }
    [self handleSendResult:sent];
    return YES;
}

- (BOOL)shareImageToQQ {
    LLZShareImageObject *object = (LLZShareImageObject *)self.shareObject;
    UIImage *thumbImage;
    if(object.thumbImage){
        thumbImage = [LLZShareImageUtils imageByScalingImage:object.thumbImage proportionallyToSize:CGSizeMake(100, 100)];
    } else {
        thumbImage = [LLZShareImageUtils imageByScalingImage:object.shareImage proportionallyToSize:CGSizeMake(100, 100)];
    }
    NSData *thumbImgData = [LLZShareImageUtils imageDataFromImage:thumbImage isPNG:object.isPNG];
    NSData *imgData =  [LLZShareImageUtils imageDataFromImage:object.shareImage isPNG:object.isPNG];
    QQApiSendResultCode sent = EQQAPISENDFAILD;

    if (self.shareChannelType == LLZShareChannelTypeQQ) {
        // qq好友聊天分享
        QQApiImageObject *imgObj = [QQApiImageObject objectWithData:imgData
                                                   previewImageData:thumbImgData
                                                              title:object.shareTitle
                                                        description:object.shareContent];
        
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:imgObj];
        sent = [QQApiInterface sendReq:req];
    } else {
        // qq空间分享
        QQApiImageArrayForQZoneObject *img = [QQApiImageArrayForQZoneObject
                                              objectWithimageDataArray:@[imgData]
                                              title:object.shareTitle
                                              extMap:nil];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:img];
        sent = [QQApiInterface SendReqToQZone:req];
    }
    [self handleSendResult:sent];
    return YES;
}

- (NSData *)formattedImageData {
    LLZShareImageObject *object = (LLZShareImageObject *)self.shareObject;
    if(object.isPNG){
        NSData *pngData = UIImagePNGRepresentation(object.shareImage);
        if(pngData){
            return pngData;
        }
    }
    NSData *imageData = UIImageJPEGRepresentation(object.shareImage, 1.0);
    return imageData;
}

- (BOOL)shareWebPageToQQ {
    LLZShareWebpageObject *object = (LLZShareWebpageObject *)self.shareObject;
    if(object.shareTitle == nil || object.shareTitle.length <= 0){
        if(self.errorBlock){
            self.errorBlock(self.shareTitle, [NSError errorWithDomain:LLZShareErrorDomain code:LLZShareErrorType_shareObjectIncomplete userInfo:@{NSLocalizedDescriptionKey:@"网页分享title为空"}]);
        }
        return NO;
    }
    //分享跳转URL
    NSString *url = object.webpageUrl;
    
    QQApiNewsObject *sharedLink = nil;
    if (object.thumbImage){
        NSData *imageData = [LLZShareImageUtils imageDataByCompressImage:object.thumbImage toLength:1000];
        sharedLink = [QQApiNewsObject objectWithURL:[NSURL URLWithString:url]
                                              title:object.shareTitle
                                        description:object.shareContent
                                   previewImageData:imageData];
    } else {
        sharedLink = [QQApiNewsObject objectWithURL:[NSURL URLWithString:url]
                                              title:object.shareTitle
                                        description:object.shareContent
                                    previewImageURL:[NSURL URLWithString:object.thumbImageUrl]];
    }
    
    // qq好友聊天分享
    if (self.shareChannelType == LLZShareChannelTypeQzone) {
        // qq空间分享
        [sharedLink setTitle:object.shareTitle];
        [sharedLink setCflag:kQQAPICtrlFlagQZoneShareOnStart]; // qqZone flag设置
    }
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:sharedLink];

    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
    return YES;
}

- (void)handleSendResult:(QQApiSendResultCode)sendResult {
    NSError *error;
    switch (sendResult) {
        case EQQAPISENDSUCESS:{
            return;
        }
        case EQQAPI_THIRD_APP_GROUP_ERROR_APP_NOT_AUTHORIZIED:{
            error = [[NSError alloc] initWithDomain:LLZShareErrorDomain code:LLZShareErrorType_ShareFailed userInfo:@{NSLocalizedDescriptionKey:@"app未获得授权"}];
            break;
        }
        case EQQAPISHAREDESTUNKNOWN:{
            error = [[NSError alloc] initWithDomain:LLZShareErrorDomain code:LLZShareErrorType_ShareFailed userInfo:@{NSLocalizedDescriptionKey:@"未指定分享到QQ或TIM"}];
            break;
        }
        case EQQAPIAPPNOTREGISTED: {
            error = [[NSError alloc] initWithDomain:LLZShareErrorDomain code:LLZShareErrorType_NotRegistered userInfo:@{NSLocalizedDescriptionKey:@"App未注册"}];
            break;
        }
        case EQQAPI_INCOMING_PARAM_ERROR:
        case EQQAPIMESSAGE_MINI_CONTENTNULL:
        case EQQAPIMESSAGEARKCONTENTNULL:
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL: {
            error = [[NSError alloc] initWithDomain:LLZShareErrorDomain code:LLZShareErrorType_shareObjectIncomplete userInfo:@{NSLocalizedDescriptionKey:@"发送参数错误"}];
            break;
        }
        case EQQAPIQZONENOTSUPPORTIMAGE:{
            error = [[NSError alloc] initWithDomain:LLZShareErrorDomain code:LLZShareErrorType_shareObjectTypeIllegal userInfo:@{NSLocalizedDescriptionKey:@"qzone分享不支持image类型分享"}];
            break;
        }
        case EQQAPIQZONENOTSUPPORTTEXT: {
            error = [[NSError alloc] initWithDomain:LLZShareErrorDomain code:LLZShareErrorType_shareObjectTypeIllegal userInfo:@{NSLocalizedDescriptionKey:@"qzone分享不支持text类型分享"}];
            break;
        }
        case EQQAPIMESSAGETYPEINVALID: {
            error = [[NSError alloc] initWithDomain:LLZShareErrorDomain code:LLZShareErrorType_shareObjectTypeIllegal userInfo:@{NSLocalizedDescriptionKey:@"发送参数类型错误"}];
            break;
        }
        case EQQAPIQQNOTINSTALLED:{
            error = [[NSError alloc] initWithDomain:LLZShareErrorDomain code:LLZShareErrorType_NotInstall userInfo:@{NSLocalizedDescriptionKey:@"未安装QQ"}];
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI_WITH_ERRORSHOW:
        case EQQAPIQQNOTSUPPORTAPI: {
            error = [[NSError alloc] initWithDomain:LLZShareErrorDomain code:LLZShareErrorType_NotSupport userInfo:@{NSLocalizedDescriptionKey:@"API接口不支持"}];
            break;
        }
        case EQQAPITIMSENDFAILD:
        case EQQAPIAPPSHAREASYNC:
        case EQQAPISENDFAILD: {
            error = [[NSError alloc] initWithDomain:LLZShareErrorDomain code:LLZShareErrorType_ShareFailed userInfo:@{NSLocalizedDescriptionKey:@"发送失败"}];
            break;
        }
        case EQQAPIVERSIONNEEDUPDATE: {
            error = [[NSError alloc] initWithDomain:LLZShareErrorDomain code:LLZShareErrorType_NotSupport userInfo:@{NSLocalizedDescriptionKey:@"QQ版本太低"}];
            break;
        }
        default:
            break;
    }
    if(self.errorBlock){
        self.errorBlock(self.shareTitle, error);
    }
}

- (void)onResp:(QQBaseResp *)resp {
    if (![resp isKindOfClass:[SendMessageToQQResp class]]){
        return;
    }
    if(resp.type != ESENDMESSAGETOQQRESPTYPE) {
        return;
    }
    SendMessageToQQResp *sendResp = (SendMessageToQQResp *)resp;
    if ([sendResp.result isEqualToString:@"0"]) {
        if (self.successBlock) {
            self.successBlock(self.shareTitle, @"QQ分享成功");
        }
    }
    else if ([sendResp.result isEqualToString:@"-4"]) {
        if (self.cancelBlock) {
            self.cancelBlock(self.shareTitle, @"QQ分享取消");
        }
    }
    else {
        if (self.errorBlock) {
            NSError *error = [NSError errorWithDomain:LLZShareErrorDomain code:LLZShareErrorType_ShareFailed userInfo:@{NSLocalizedDescriptionKey: sendResp.errorDescription ?: @"QQ分享失败"}];
            self.errorBlock(self.shareTitle, error);
        }
    }
    
    [self shareInfoReset];
}

- (void)shareInfoReset {
    self.shareObject = nil;
    self.successBlock = nil;
    self.errorBlock = nil;
    self.cancelBlock = nil;
}

- (void)isOnlineResponse:(NSDictionary *)response {
    
}


- (void)onReq:(QQBaseReq *)req {
}



- (BOOL)share_application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    if(_platformConfig.isCrossAppCallbackDelegate){
        return [QQApiInterface handleOpenURL:url delegate:self];
    }
    return NO;
}

- (BOOL)share_application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    if(_platformConfig.isCrossAppCallbackDelegate){
        NSURL *url = userActivity.webpageURL;
        if (url && [TencentOAuth CanHandleUniversalLink:url]) {
            [QQApiInterface handleOpenURL:url delegate:self];
            [QQApiInterface handleOpenUniversallink:url delegate:self];
            return [TencentOAuth HandleUniversalLink:url];
        }
    }
    return NO;
}


#pragma mark - TencentSessionDelegate
- (void)tencentDidLogin {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccessed" object:self];
}

- (void)tencentDidNotLogin:(BOOL)cancelled {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginCancelled" object:self];
}

- (void)tencentDidNotNetWork {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginFailed" object:self];
}


- (SupportShareObjectOptions)supportSharingObjectOptions {
    return SupportShareObjectImage | SupportShareObjectMessage | SupportShareObjectWebpage;
}

- (NSArray *)supportShareChannels {
    return @[@(LLZShareChannelTypeQQ), @(LLZShareChannelTypeQzone)];
}


@end
