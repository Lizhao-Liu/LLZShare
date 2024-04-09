//
//  LLZShareSaveImageHandler.m
//  LLZShareLib
//
//  Created by Lizhao on 2022/10/18.
//

#import "LLZShareSaveImageHandler.h"
#import "LLZShareObject+LLZShareLib.h"
#import "LLZShareUtils.h"

@interface LLZShareSaveImageHandler()

@property (nonatomic, strong) LLZShareImageObject *shareObject;

@property (nonatomic, weak) UIViewController *currentViewController;

@property (nonatomic, copy) ShareSuccessBlock successBlock;
@property (nonatomic, copy) ShareCancelBlock cancelBlock;
@property (nonatomic, copy) ShareErrorBlock errorBlock;

@end


@implementation LLZShareSaveImageHandler
@synthesize shareChannelType = _shareChannelType;
@synthesize shareTitle = _shareTitle;

- (instancetype)init {
    self = [super init];
    if(self){
        _shareChannelType = LLZShareChannelTypeSaveImage;
        _shareTitle = SaveImageShareChannelTitle;
    }
    return self;
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
    
    if(![self setUpshareObject:object]){
        return;
    }
    [self saveImage];
}

- (BOOL)setUpshareObject:(LLZShareObject *)shareObject{
    if(shareObject == nil) {
        if(self.errorBlock){
            NSError *error = [NSError errorWithDomain:LLZShareErrorDomain code:LLZShareErrorType_shareObjectNil userInfo:@{NSLocalizedDescriptionKey: @"未传入分享内容"}];
            self.errorBlock(self.shareTitle, error);
        }
        return NO;
    }
    LLZShareImageObject *object;
    if([shareObject isKindOfClass:[LLZShareAutoTypeObject class]]){
        shareObject = [(LLZShareAutoTypeObject *)shareObject convertToImageObject];
    }
    if(![shareObject isKindOfClass:[LLZShareImageObject class]]){
        if(self.errorBlock){
            NSError *error = [NSError errorWithDomain:LLZShareErrorDomain code:LLZShareErrorType_shareObjectTypeIllegal userInfo:@{NSLocalizedDescriptionKey: @"传入数据类型错误"}];
            self.errorBlock(self.shareTitle, error);
        }
        return NO;
    }

    object = (LLZShareImageObject *)shareObject;
    NSError *error;
    [shareObject buildValidshareObjectWithError:&error];
    if(error){
        if(self.errorBlock){
            self.errorBlock(self.shareTitle, error);
        }
        return NO;
    }
    self.shareObject = object;
    return YES;
}

// 保存图片渠道使用异步保存的方式
- (void)saveImage {
    LLZShareImageObject *object = (LLZShareImageObject *)self.shareObject;
    if(object.isPNG) {
        NSData *imageData = UIImagePNGRepresentation(object.shareImage);
        if (imageData != nil) {
            UIImage *pngImage = [UIImage imageWithData:imageData];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImageWriteToSavedPhotosAlbum(pngImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            });
            return;
        }
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImageWriteToSavedPhotosAlbum(self.shareObject.shareImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    });

}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if(error == nil){
        if(self.successBlock){
            self.successBlock(self.shareTitle, @"图片保存成功");
        }
    } else {
        if(self.errorBlock){
            NSError *error = [NSError errorWithDomain:LLZShareErrorDomain code:LLZShareErrorType_shareObjectIncomplete userInfo:@{NSLocalizedDescriptionKey: @"图片保存失败"}];
            self.errorBlock(self.shareTitle, error);
        }
    }
}

- (void)shareInfoReset {
    self.shareObject = nil;
    self.successBlock = nil;
    self.errorBlock = nil;
    self.cancelBlock = nil;
    self.currentViewController = nil;
}

- (SupportShareObjectOptions) supportSharingObjectOptions {
    return  SupportShareObjectImage;
}

@end
