//
//  LLZShareSMSHandler.m
//  LLZShareLib
//
//  Created by Lizhao on 2022/10/18.
//

#import "LLZShareSMSHandler.h"
#import <MessageUI/MessageUI.h>
#import "LLZShareObject+LLZShareLib.h"
#import "UIViewController+Utils.h"

@interface LLZShareSMSHandler ()<MFMessageComposeViewControllerDelegate>

@property (nonatomic, strong) LLZShareMessageObject *shareObject;

@property (nonatomic, weak) UIViewController *currentViewController;

@property (nonatomic, copy) ShareSuccessBlock successBlock;
@property (nonatomic, copy) ShareCancelBlock cancelBlock;
@property (nonatomic, copy) ShareErrorBlock errorBlock;

@end

@implementation LLZShareSMSHandler
@synthesize shareChannelType = _shareChannelType;
@synthesize shareTitle = _shareTitle;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _shareChannelType = LLZShareChannelTypeSMS;
        _shareTitle = SMSShareChannelTitle;
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
    
    if(![self isPreparedForSharing]){
        return;
    }
    if(![self setUpshareObject:object]){
        return;
    }
    if(viewController){
        self.currentViewController = viewController;
    } else {
        self.currentViewController = [UIViewController currentViewController];
    }
    // 分享文本
    [self shareText];
}

- (BOOL)isPreparedForSharing {
    // 检查设备是否支持短信分享
    if(![self isSupport]){
        NSError *error = [[NSError alloc] initWithDomain:LLZShareErrorDomain code:LLZShareErrorType_NotSupport userInfo:@{NSLocalizedDescriptionKey: @"该设备不支持短信功能"}];
        if(self.errorBlock){
            self.errorBlock(self.shareTitle, error);
        }
        return NO;
    }
    return YES;
}

- (BOOL)setUpshareObject:(LLZShareObject *)object{
    if(object == nil) {
        if(self.errorBlock){
            NSError *error = [NSError errorWithDomain:LLZShareErrorDomain code:LLZShareErrorType_shareObjectNil userInfo:@{NSLocalizedDescriptionKey: @"未传入分享内容"}];
            self.errorBlock(self.shareTitle, error);
        }
        return NO;
    }
    if([object isKindOfClass:[LLZShareAutoTypeObject class]]){
        object = [(LLZShareAutoTypeObject *)object convertToMessageObject];
    }
    if(![object isKindOfClass:[LLZShareMessageObject class]]){
        if(self.errorBlock){
            NSError *error = [NSError errorWithDomain:LLZShareErrorDomain code:LLZShareErrorType_shareObjectTypeIllegal userInfo:@{NSLocalizedDescriptionKey: @"传入数据类型错误"}];
            self.errorBlock(self.shareTitle, error);
        }
        return NO;
    }
    NSError *error;
    [(LLZShareMessageObject *)object buildValidshareObjectWithError:&error];
    self.shareObject = (LLZShareMessageObject *)object;
    if(error){
        if(self.errorBlock){
            self.errorBlock(self.shareTitle, error);
        }
        return NO;
    }
    return YES;
}

- (void)shareText {
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText]) {
        controller.body = self.shareObject.shareContent;
        controller.messageComposeDelegate = self;
        [self.currentViewController presentViewController:controller animated:YES completion:nil];
    }
}

- (BOOL)isSupport{
    NSString* deviceType = [UIDevice currentDevice].model;
    NSRange range = [deviceType rangeOfString:@"iPhone"];
    if( [MFMessageComposeViewController canSendText] && range.location != NSNotFound) {
        return YES;
    }
    return NO;
}

#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(nonnull MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    __weak typeof(self) weakSelf = self;
    [controller dismissViewControllerAnimated:YES completion:^{
        __strong typeof(self) strongSelf = weakSelf;
        NSString *str;
        switch (result) {
            case MessageComposeResultSent:
                str = @"信息传送成功";
                if(strongSelf.successBlock){
                    strongSelf.successBlock(strongSelf.shareTitle, str);
                }
                return;
            case MessageComposeResultFailed:
                str = @"信息传送失败";
                if(strongSelf.errorBlock){
                    NSError *error = [NSError errorWithDomain:LLZShareErrorDomain code:LLZShareErrorType_ShareFailed userInfo:@{NSLocalizedDescriptionKey: str}];
                    strongSelf.errorBlock(strongSelf.shareTitle, error);
                }
                return;
            case MessageComposeResultCancelled:
                str = @"取消发送";
                if(strongSelf.cancelBlock){
                    strongSelf.cancelBlock(strongSelf.shareTitle, str);
                }
                return;
        }
        
    }];
}

- (void)shareInfoReset {
    self.shareObject = nil;
    self.successBlock = nil;
    self.errorBlock = nil;
    self.cancelBlock = nil;
    self.currentViewController = nil;
}

- (SupportShareObjectOptions) supportSharingObjectOptions {
    return  SupportShareObjectMessage;
}



@end
