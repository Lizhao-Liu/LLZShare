//
//  LLZShareUtils.m
//  LLZShareLib
//
//  Created by Lizhao on 2022/10/19.
//

#import "LLZShareUtils.h"
#import "NSString+LLZShareLib.h"
#import <Photos/PHPhotoLibrary.h>
#import "UIViewController+Utils.h"

#ifndef mb_dispatch_queue_async_safe
#define mb_dispatch_queue_async_safe(queue, block)\
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(queue)) == 0) {\
        block();\
    } else {\
        dispatch_async(queue, block);\
    }
#endif

#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block) mb_dispatch_queue_async_safe(dispatch_get_main_queue(), block)
#endif


@implementation LLZShareMediaResourceManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static LLZShareMediaResourceManager  *instance;
    dispatch_once(&onceToken, ^{
        instance = [[LLZShareMediaResourceManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        _VideoCachePool = @{}.mutableCopy;
    }
    return self;
}

- (nullable NSString *)videoIdFromCacheForUrl: (NSString *)videoUrl{
    NSString *videoID = [self.VideoCachePool objectForKey:videoUrl];
    if(videoID && videoID.length > 0){
        return videoID;
    }
    return nil;
}

@end

@interface LLZShareVideoUtils ()

@property (strong, nonatomic) NSString *videoSavePath;
@property (strong, nonatomic) NSString *downloadUrl;
@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *fileSize;
@property (assign, nonatomic) BOOL useCache;
@property (copy, nonatomic) VideoHandleFailBlock failBlock;
@property (copy, nonatomic) VideoHandleCancelBlock cancelBlock;
@property (copy, nonatomic) VideoHandleSuccessBlock successBlock;

@property (assign, nonatomic) BOOL isLocalFile;

@end

@implementation LLZShareVideoUtils

- (void)saveVideoWithUrl:(NSString *)downloadUrl
                fileName:(NSString *)fileName
                fileSize:(NSString *)fileSize
               readCache:(BOOL)useCache
          successHandler:(VideoHandleSuccessBlock)successBlock
           cancelHandler:(VideoHandleCancelBlock)cancelBlock
             failHandler:(VideoHandleFailBlock)failBlock {
    self.downloadUrl = downloadUrl;
    self.fileName = fileName;
    self.fileSize = fileSize;
    self.failBlock = failBlock;
    self.cancelBlock = cancelBlock;
    self.successBlock = successBlock;
    self.useCache = useCache;
    self.isLocalFile = NO;
    [self requestPhotoLibraryAccess];
}

- (void)saveVideoWithLocalPath:(NSString *)localPath
                successHandler:(VideoHandleSuccessBlock)successBlock
                 cancelHandler:(VideoHandleCancelBlock)cancelBlock
                   failHandler:(VideoHandleFailBlock)failBlock{
    self.downloadUrl = nil;
    self.fileName = nil;
    self.fileSize = nil;
    self.failBlock = failBlock;
    self.cancelBlock = cancelBlock;
    self.successBlock = successBlock;
    self.useCache = NO;
    self.videoSavePath = localPath;
    self.isLocalFile = YES;
    [self requestPhotoLibraryAccess];
}

#pragma mark - 相册权限检查
/// 检查相册访问权限
- (void)requestPhotoLibraryAccess {
    if (@available(iOS 14, *)) {
        [PHPhotoLibrary requestAuthorizationForAccessLevel:(PHAccessLevelReadWrite) handler:^(PHAuthorizationStatus status) {
            switch (status) {
                case PHAuthorizationStatusNotDetermined:
                    dispatch_main_async_safe(^{
                        [self noPermission];
                    });
                    break;
                case PHAuthorizationStatusRestricted:
                    dispatch_main_async_safe(^{
                        [self showAlertView];
                    });
                    break;
                case PHAuthorizationStatusDenied:
                    dispatch_main_async_safe(^{
                        [self showAlertView];
                    });
                    break;
                case PHAuthorizationStatusAuthorized:
                    dispatch_main_async_safe(^{
                        [self saveToAlbum];
                    });
                    break;
                case PHAuthorizationStatusLimited:
                    dispatch_main_async_safe(^{
                        [self saveToAlbum];
                    });
                    break;
            }
        }];
    } else {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            switch (status) {
                case PHAuthorizationStatusNotDetermined:
                    dispatch_main_async_safe(^{
                        [self noPermission];
                    });
                    break;
                case PHAuthorizationStatusRestricted:
                    dispatch_main_async_safe(^{
                        [self showAlertView];
                    });
                    break;
                case PHAuthorizationStatusDenied:
                    dispatch_main_async_safe(^{
                        [self showAlertView];
                    });
                    break;
                case PHAuthorizationStatusAuthorized:
                    dispatch_main_async_safe(^{
                        [self saveToAlbum];
                    });
                    break;
                default:
                    break;
                
            }
        }];
    }
}

- (void)noPermission {
    if(self.failBlock){
        NSError *error = [[NSError alloc] initWithDomain:LLZShareErrorDomain code:LLZShareErrorType_PermissionDenied userInfo:@{NSLocalizedDescriptionKey: @"无相册权限"}];
        self.failBlock(error);
    }
}

- (void)showAlertView {
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    NSString *message = [NSString stringWithFormat:@"%@申请您照片权限，确保照片的正常使用，请在iPhone的\"设置-隐私-照片\"选项进行设置", appName];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法使用相册" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL* url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }];
    
    [alert addAction:cancel];
    [alert addAction:ok];
    [[UIViewController currentViewController] presentViewController:alert animated:YES completion:nil];
}
    


- (PHAuthorizationStatus )authorizationPhotoStatusAuthorized {
    if (@available(iOS 14, *)) {
        return [PHPhotoLibrary authorizationStatusForAccessLevel:(PHAccessLevelReadWrite)];
    } else {
        return [PHPhotoLibrary authorizationStatus];
    }
}

#pragma mark - 保存视频

///// 方法一：视频保存到相册并更新缓存：适用于抖音 快手保存视频场景
//- (void)saveToAlbumWithCache {
//    __block NSString *curLocalIdentifier = @"";
//    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
//        PHAssetChangeRequest *rRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL URLWithString:self.videoSavePath]];
//        curLocalIdentifier = rRequest.placeholderForCreatedAsset.localIdentifier;
//    } completionHandler:^(BOOL success, NSError * _Nullable error) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (success) {
//                // 更新缓存
//                [[LLZShareMediaResourceManager sharedInstance].VideoCachePool setObject:curLocalIdentifier ?: @"" forKey:self.downloadUrl];
//                // 保存视频成功
//                self.successBlock();
//            } else {
//                self.failBlock([[NSError alloc] initWithDomain:LLZShareErrorDomain code:LLZShareErrorType_DownloadFail userInfo:@{NSLocalizedDescriptionKey: @"视频保存失败"}]);
//                LLZDoctorEventError *eventError = [[LLZDoctorEventError alloc] initWithPlatform:LLZDoctorPlatformHubble];
//                eventError.tag = @"share";
//                eventError.feature = @"save_video";
//                NSString *errorDetailStr =[NSString stringWithFormat:@"Fail to save video with error: %@", error.localizedDescription];
//                eventError.errorDetail = errorDetailStr;
//                id<LLZDoctorServiceProtocol> doctorService = BIND_SERVICE(LLZDoctorContext.new, LLZDoctorServiceProtocol);
//                [doctorService doctor:eventError];
//            }
//        });
//    }];
//}


/// 方法二：视频保存到相册，无须缓存
- (void)saveToAlbum {
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.videoSavePath)) {
        UISaveVideoAtPathToSavedPhotosAlbum(self.videoSavePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    } else {
        if(self.failBlock){
            self.failBlock([[NSError alloc] initWithDomain:LLZShareErrorDomain code:LLZShareErrorType_DownloadFail userInfo:@{NSLocalizedDescriptionKey: @"视频保存失败, 视频格式无法保存"}]);
        }
//        LLZDoctorEventError *error = [[LLZDoctorEventError alloc] initWithPlatform:LLZDoctorPlatformHubble];
//        error.tag = @"share";
//        error.feature = @"save_video";
//        NSString *errorDetailStr =[NSString stringWithFormat:@"Fail to save video as the video is not valid"];
//        error.errorDetail = errorDetailStr;
//        id<LLZDoctorServiceProtocol> doctorService = BIND_SERVICE(LLZDoctorContext.new, LLZDoctorServiceProtocol);
//        [doctorService doctor:error];
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
//        LLZDoctorEventError *eventError = [[LLZDoctorEventError alloc] initWithPlatform:LLZDoctorPlatformHubble];
//        eventError.tag = @"share";
//        eventError.feature = @"save_video";
//        NSString *errorDetailStr =[NSString stringWithFormat:@"Fail to save video with error: %@", error.localizedDescription];
//        eventError.errorDetail = errorDetailStr;
//        id<LLZDoctorServiceProtocol> doctorService = BIND_SERVICE(LLZDoctorContext.new, LLZDoctorServiceProtocol);
//        [doctorService doctor:eventError];
        if(self.failBlock){
            self.failBlock([[NSError alloc] initWithDomain:LLZShareErrorDomain code:LLZShareErrorType_DownloadFail userInfo:@{NSLocalizedDescriptionKey: @"视频保存失败"}]);
        }
    } else {
        if(self.successBlock){
            self.successBlock();
        }
    }
}

@end

@interface LLZShareImageUtils ()

@end

@implementation LLZShareImageUtils

#pragma mark - 图片缩放
+ (UIImage *)imageByScalingImage:(UIImage*)image proportionallyToSize:(CGSize)targetSize {
    if (image.size.width <= targetSize.width && image.size.height <= targetSize.height) {
        return image;
    }
    
    CGSize thumbSize;
    if (image.size.width / image.size.height > targetSize.width / targetSize.height) {
        thumbSize.width = targetSize.width;
        thumbSize.height = targetSize.width / image.size.width * image.size.height;
    }
    else {
        thumbSize.height = targetSize.height;
        thumbSize.width = targetSize.height / image.size.height * image.size.width;
    }
    
    UIGraphicsBeginImageContext(thumbSize);
    [image drawInRect:(CGRect){CGPointZero,thumbSize}];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

#pragma mark - 图片压缩
+ (NSData *)imageDataByCompressImage:(UIImage*)image toLength:(CGFloat)targetLength {
    NSData *data = nil;
    @autoreleasepool {
        CGFloat limit = targetLength;
        CGFloat quality = 1.0;
        do {
            data = UIImageJPEGRepresentation(image, quality);
            quality -= 0.1;
        } while (data.length > limit * 1024 && quality >= 0.3);
    }
    return data;
}

#pragma mark - 图片下载
+ (UIImage *)imageFromUrlStr:(NSString *)url{
//    if([url containsChinese]){ //如果链接中存在中文，进行一次兜底encode
//        url = url.mb_encodeURI;
//    }
    NSURL *imageUrl = nil;
    if([url hasPrefix:@"http"] || [url hasPrefix:@"https"]){
        imageUrl = [NSURL URLWithString:url];
    } else {
        imageUrl = [NSURL fileURLWithPath:url];
    }
    UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
    if(img){
        return img;
    }else {
//        LLZDoctorEventError *error = [[LLZDoctorEventError alloc] initWithPlatform:LLZDoctorPlatformHubble];
//        error.tag = @"share";
//        error.feature = @"download_image";
//        NSString *errorDetailStr =[NSString stringWithFormat:@"Fail to download image from url: %@", url];
//        error.errorDetail = errorDetailStr;
//        id<LLZDoctorServiceProtocol> doctorService = BIND_SERVICE(LLZDoctorContext.new, LLZDoctorServiceProtocol);
//        [doctorService doctor:error];
//        return nil;
    }
    return nil;
}

+ (NSData *)imageDataFromImage:(UIImage *)image isPNG:(BOOL)isPNG {
    if(isPNG){
        NSData *imageData = UIImagePNGRepresentation(image);
        if(imageData){
            return imageData;
        }
    }
    return UIImageJPEGRepresentation(image, 1.0);
}

@end
