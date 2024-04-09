//
//  LLZShareSaveVideoHandler.m
//  LLZShareLib
//
//  Created by Lizhao on 2022/10/18.
//

#import "LLZShareSaveVideoHandler.h"
#import "LLZShareObject+LLZShareLib.h"
#import "LLZShareUtils.h"

@interface LLZShareSaveVideoHandler()

@property (nonatomic, strong) LLZShareVideoObject *shareObject;

@property (nonatomic, weak) UIViewController *currentViewController;

@property (nonatomic, copy) ShareSuccessBlock successBlock;
@property (nonatomic, copy) ShareCancelBlock cancelBlock;
@property (nonatomic, copy) ShareErrorBlock errorBlock;


@end

@implementation LLZShareSaveVideoHandler
@synthesize shareChannelType = _shareChannelType;
@synthesize shareTitle = _shareTitle;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _shareChannelType = LLZShareChannelTypeSaveVideo;
        _shareTitle = SaveVideoShareChannelTitle;
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
    [self saveVideo];
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

- (void)saveVideo {
    if(self.shareObject.localPath && self.shareObject.localPath.length > 0){
        LLZShareVideoUtils *videoHandler = [[LLZShareVideoUtils alloc] init];
        [videoHandler saveVideoWithLocalPath:self.shareObject.localPath
                              successHandler:^{
            self.successBlock(self.shareTitle, @"视频保存成功");
        } cancelHandler:^(NSString * _Nonnull msg) {
            self.cancelBlock(self.shareTitle, msg);
        } failHandler:^(NSError * _Nullable error) {
            self.errorBlock(self.shareTitle, error);
        }];
    } else {
        LLZShareVideoUtils *downloader = [[LLZShareVideoUtils alloc] init];
        [downloader saveVideoWithUrl:self.shareObject.downloadUrl
                            fileName:self.shareObject.fileName
                            fileSize:self.shareObject.fileSize
                           readCache:NO
                      successHandler:^{
            if(self.successBlock){
                self.successBlock(self.shareTitle, @"视频保存成功");
            }
        }
                       cancelHandler:^(NSString * _Nonnull msg) {
            if(self.cancelBlock){
                self.cancelBlock(self.shareTitle, msg);
            }
        }
                         failHandler:^(NSError * _Nullable error) {
            if(self.errorBlock){
                self.errorBlock(self.shareTitle, error);
            }
        }];
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
    return  SupportShareObjectVideo;
}

@end
