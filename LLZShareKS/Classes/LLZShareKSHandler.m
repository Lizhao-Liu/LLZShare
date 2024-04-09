//
//  LLZShareKSHandler.m
//  LLZShareLib
//
//  Created by Lizhao on 2022/10/19.
//

#import "LLZShareKSHandler.h"
#import "KSApi.h"
@import LLZShareLib;
#import <Photos/Photos.h>

@interface LLZShareKSHandler ()<KSApiDelegate>

@property (nonatomic, strong) LLZShareVideoObject *shareObject;

@property (nonatomic, copy) ShareSuccessBlock successBlock;
@property (nonatomic, copy) ShareCancelBlock cancelBlock;
@property (nonatomic, copy) ShareErrorBlock errorBlock;

@property (nonatomic, strong) NSString *videoSavePath;

@end

@serviceEX(LLZShareKSHandler, LLZShareChannelHandler)
@synthesize platformType = _platformType;
@synthesize shareTitle = _shareTitle;
@synthesize shareChannelType = _shareChannelType;
@synthesize platformConfig = _platformConfig;
@synthesize isRegistered = _isRegistered;
@synthesize pushBlock = _pushBlock;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _platformType = LLZSharePlatformKS;
        _shareTitle = KuaiShouShareChannelTitle;
    }
    return self;
}

- (BOOL)registerApp {
    _isRegistered = [KSApi registerApp:_platformConfig.appID universalLink:_platformConfig.universalLink delegate:self];
    if(_isRegistered){
        NSLog(@"快手平台注册app成功");
    } else {
        NSLog(@"快手平台注册app失败");
    }
    return _isRegistered;
}

- (BOOL)isInstalled {
    return [KSApi isAppInstalledFor:(KSApiApplication_Kwai)];
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
    
    [self shareVideo];
}

- (BOOL)isPreparedForSharing {
    if(![self isInstalled]){
        if(self.errorBlock){
            NSError *error = [NSError errorWithDomain:LLZShareErrorDomain code:LLZShareErrorType_NotInstall userInfo:@{NSLocalizedDescriptionKey:@"手机尚未安装快手"}];
            self.errorBlock(self.shareTitle, error);
        }
        return NO;
    }
    return YES;
}

- (BOOL)share_application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler{
    if(_platformConfig.isCrossAppCallbackDelegate){
        return [KSApi handleOpenUniversalLink:userActivity];
    }
    return NO;
}
- (BOOL)share_application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    if(_platformConfig.isCrossAppCallbackDelegate){
        return [KSApi handleOpenURL:url];
    }
    return NO;
}

#pragma mark - private methods

- (BOOL)setUpshareObject:(LLZShareObject *)shareObject{
    if(shareObject == nil) {
        if(self.errorBlock){
            NSError *error = [NSError errorWithDomain:LLZShareErrorDomain code:LLZShareErrorType_shareObjectNil userInfo:@{NSLocalizedDescriptionKey: @"未传入分享内容"}];
            self.errorBlock(self.shareTitle, error);
        }
        return NO;
    }
    if([shareObject isKindOfClass:[LLZShareAutoTypeObject class]]){
        shareObject = [(LLZShareAutoTypeObject *)shareObject convertToVideoObject];
    }
    if(![shareObject isKindOfClass:[LLZShareVideoObject class]]){
        if(self.errorBlock){
            NSError *error = [NSError errorWithDomain:LLZShareErrorDomain code:LLZShareErrorType_shareObjectTypeIllegal userInfo:@{NSLocalizedDescriptionKey: @"传入数据类型错误"}];
            self.errorBlock(self.shareTitle, error);
        }
        return NO;
    }
    NSError *error;
    LLZShareVideoObject *object = (LLZShareVideoObject *)shareObject;
    [object buildValidshareObjectWithError:&error];
    if(error){
        if(self.errorBlock){
            self.errorBlock(self.shareTitle, error);
        }
        return NO;
    }
    self.shareObject = object;
    return YES;
}

- (void)shareVideo {
    if(self.shareObject.localPath && self.shareObject.localPath.length > 0){
        [self shareLocalVideo];
    } else {
        NSString *videoLocalIdentifier = [[LLZShareMediaResourceManager sharedInstance] videoIdFromCacheForUrl:self.shareObject.downloadUrl];
        if(videoLocalIdentifier){
            [self shareLocalVideoWithVideoID:videoLocalIdentifier];
        } else {
            [self saveVideoToAlbum];
        }
    }
}

- (void)shareLocalVideo {
    __block NSString *curLocalIdentifier;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *rRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL URLWithString:self.shareObject.localPath]];
        curLocalIdentifier = rRequest.placeholderForCreatedAsset.localIdentifier;
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [self shareLocalVideoWithVideoID:curLocalIdentifier];
            } else {
                NSError *error = [NSError errorWithDomain:LLZShareErrorDomain code:LLZShareErrorType_ShareFailed userInfo:@{NSLocalizedDescriptionKey: @"分享失败, 文件异常"}];
                if(self.errorBlock){
                    self.errorBlock(self.shareTitle, error);
                }

            }
        });
    }];
}


/// 下载视频并保存到相册
- (void)saveVideoToAlbum {
    LLZShareVideoUtils *downloader = [[LLZShareVideoUtils alloc] init];
    [downloader saveVideoWithUrl:self.shareObject.downloadUrl
                        fileName:self.shareObject.fileName
                        fileSize:self.shareObject.fileSize
                       readCache:YES
                  successHandler:^{
        // 视频保存成功
        if(self.successBlock){
            self.successBlock(self.shareTitle, @"视频保存成功");
        }
        [self pushNotificationWithState:YES];
    }
                   cancelHandler:^(NSString *msg) {
        // 视频下载取消
        if(self.cancelBlock){
            self.cancelBlock(self.shareTitle, msg);
        }
    }
                     failHandler:^(NSError * _Nullable error) {
        // 视频保存失败
        if(self.errorBlock){
            self.errorBlock(self.shareTitle, error);
        }
        [self pushNotificationWithState:NO];
    }];
}


- (void)shareLocalVideoWithVideoID: (NSString *)videoID {
    
    KSShareMediaAsset *mediaAsset = [KSShareMediaAsset assetForPhotoLibrary:videoID isImage:NO];
    KSShareMediaObject *mediaObject = [[KSShareMediaObject alloc] init];
    mediaObject.multipartAssets = @[mediaAsset];
    KSShareMediaRequest *request = [[KSShareMediaRequest alloc] init];
    request.mediaFeature = KSShareMediaFeature_VideoPublish;
    request.mediaObject = mediaObject;
    [KSApi sendRequest:request completion:^(BOOL success) {
        NSLog(@"快手发送结果: %d", success);
    }];
}

#pragma mark - KSApiDelegate
/// 发送一个request后，收到快手终端的回应
/// @param response 具体的回应内容，回应类型详见KSApiObject.h
- (void)ksApiDidReceiveResponse:(__kindof KSBaseResponse *)response {
    if (response.error.code == KSErrorCodeSuccess) { //成功
        if(self.successBlock){
            self.successBlock(self.shareTitle, @"快手分享成功");
        }
    } else if(response.error.code == KSErrorCodeCancelled){
        if(self.cancelBlock){
            self.cancelBlock(self.shareTitle, @"用户取消分享");
        }
        
    } else {
        NSError *error;
        switch (response.error.code) {
            case KSErrorCodeKwaiAppNotInstalled:
                error = [NSError errorWithDomain:LLZShareErrorDomain code:LLZShareErrorType_NotInstall userInfo:@{NSLocalizedDescriptionKey:@"快手 App 尚未安装"}];
                break;
            case KSErrorCodeFeatureNotSupportedByKwaiApp:
                error = [NSError errorWithDomain:LLZShareErrorDomain code:LLZShareErrorType_NotSupport userInfo:@{NSLocalizedDescriptionKey:@"快手 App 版本过低"}];
                break;
            case KSErrorCodeActionBlockedForUserRelation:
                error = [NSError errorWithDomain:LLZShareErrorDomain code:LLZShareErrorType_ShareFailed userInfo:@{NSLocalizedDescriptionKey:@"当前用户关系不支持该操作"}];
                break;
            default:
                error = [NSError errorWithDomain:LLZShareErrorDomain code:LLZShareErrorType_ShareFailed userInfo:@{NSLocalizedDescriptionKey: response.error.localizedDescription ?:@"分享失败"}];
                break;
        }
        NSLog(@"%@", response.error);
        if(self.errorBlock){
            self.errorBlock(self.shareTitle, error);
        }
    }
}

- (void)pushNotificationWithState: (BOOL)isSucceed {
    NSString *pushMsg;
    NSString *url;
    
    if(isSucceed){
        pushMsg = @"您的视频已成功下载到相册，快去分享视频吧";
        url = self.shareObject.successActionUrl;
    } else {
        pushMsg = @"抱歉，您的视频下载失败，可进入活动页重新下载哦";
        url = self.shareObject.failActionUrl;
    }
    
    NSDictionary *pushInfo = @{
        @"time": @(1.0),
        @"title": @"提示",
        @"body": pushMsg,
        @"userInfo": @{@"type": @(1),
                       @"message": pushMsg,
                       @"title": @"提示",
                       @"view": url ?: @""}
    };

    if (self.pushBlock) {
        self.pushBlock(pushInfo);
    }
}

- (void)shareInfoReset {
    self.shareObject = nil;
    self.successBlock = nil;
    self.errorBlock = nil;
    self.cancelBlock = nil;
    self.videoSavePath = nil;
}

- (SupportShareObjectOptions)supportSharingObjectOptions {
    return SupportShareObjectVideo;
}

- (NSArray *)supportShareChannels {
    return @[@(LLZShareChannelTypeKS)];
}

@end
