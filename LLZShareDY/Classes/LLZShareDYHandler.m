//
//  LLZShareDYHandler.m
//  LLZShareLib
//
//  Created by Lizhao on 2022/10/19.
//

#import "LLZShareDYHandler.h"
#import <UIKit/UIApplication.h>
@import LLZShareLib;
@import DouyinOpenSDK;
#import <Photos/Photos.h>


@interface LLZShareDYHandler ()

@property (nonatomic, strong) LLZShareVideoObject *shareObject;

@property (nonatomic, copy) ShareSuccessBlock successBlock;
@property (nonatomic, copy) ShareCancelBlock cancelBlock;
@property (nonatomic, copy) ShareErrorBlock errorBlock;

@property (nonatomic, strong) NSString *videoSavePath;

@end

@serviceEX(LLZShareDYHandler, LLZShareChannelHandler)
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
        _platformType = LLZSharePlatformDY;
        _shareTitle = DouYinShareChannelTitle;
    }
    return self;
}

- (BOOL)registerApp {
    _isRegistered = [[DouyinOpenSDKApplicationDelegate sharedInstance] registerAppId:_platformConfig.appID];
    if(_isRegistered){
        NSLog(@"抖音平台注册app成功");
    } else {
        NSLog(@"抖音平台注册app失败");
    }
    return _isRegistered;
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
            NSError *error = [NSError errorWithDomain:LLZShareErrorDomain code:LLZShareErrorType_NotInstall userInfo:@{NSLocalizedDescriptionKey:@"手机尚未安装抖音"}];
            self.errorBlock(self.shareTitle, error);
        }
        return NO;
    }
    return YES;
}

- (BOOL)isInstalled {
    return [[DouyinOpenSDKApplicationDelegate sharedInstance] isAppInstalled];
}


- (BOOL)share_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions {
    [[DouyinOpenSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    return YES;
}

- (BOOL)share_application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    if(_platformConfig.isCrossAppCallbackDelegate){
        return [[DouyinOpenSDKApplicationDelegate sharedInstance] application:app openURL:url sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey] annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
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
            self.successBlock(self.shareTitle, @"下载成功");
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


/// 读取缓存视频并分享给抖音平台
- (void)shareLocalVideoWithVideoID: (NSString *)videoID {
    DouyinOpenSDKShareRequest *req = [[DouyinOpenSDKShareRequest alloc] init];
    req.localIdentifiers = @[videoID];
    req.mediaType = DouyinOpenSDKShareMediaTypeVideo;
    req.landedPageType = DouyinOpenSDKLandedPagePublish;
    [req sendShareRequestWithCompleteBlock:^(DouyinOpenSDKShareResponse * _Nonnull Response) {
        if (Response.shareState == DouyinOpenSDKShareRespStateSuccess) { //成功
            if(self.successBlock){
                self.successBlock(self.shareTitle, @"分享成功");
            }
        } else if (Response.shareState == DouyinOpenSDKShareRespStateCancel){
            if(self.cancelBlock){
                self.cancelBlock(self.shareTitle, @"用户点击了取消");
            }
        } else {
            NSError *error;
            switch (Response.shareState) {
                case DouyinOpenSDKShareRespStateUserNotLogin:
                    error = [NSError errorWithDomain:LLZShareErrorDomain code:LLZShareErrorType_ShareFailed userInfo:@{NSLocalizedDescriptionKey:@"用户未登录"}];
                    break;
                case DouyinOpenSDKShareRespStateHaveUploadingTask:
                    error = [NSError errorWithDomain:LLZShareErrorDomain code:LLZShareErrorType_ShareFailed userInfo:@{NSLocalizedDescriptionKey:@"另一个视频正在上传"}];
                default:
                    error = [NSError errorWithDomain:LLZShareErrorDomain code:LLZShareErrorType_ShareFailed userInfo:@{NSLocalizedDescriptionKey: Response.state ?: @"分享失败"}];
                    break;
            }
            if(self.errorBlock){
                self.errorBlock(self.shareTitle, error);
            }
        }
    }];
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
    return @[@(LLZShareChannelTypeDY)];
}

@end
