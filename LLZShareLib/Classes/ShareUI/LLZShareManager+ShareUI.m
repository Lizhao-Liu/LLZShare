//
//  LLZShareManager+ShareUI.m
//  LLZShareLib
//
//  Created by Lizhao on 2022/10/26.
//

#import "LLZShareManager+ShareUI.h"
#import "LLZShareMenuManager.h"

@implementation LLZShareManager (ShareUI)

+ (void)showShareMenuViewWithShareChannels:(nullable NSArray*)channels
                         withConfiguration:(nullable LLZShareUIConfig *)config
                        withViewController:(nullable UIViewController *)viewController
                          withShareContext:(LLZShareContextModel *)context
                     withShowMenuFailBlock:(ShowMenuFailBlock)failBlock
                     withStateChangedBlock:(StateChangedBlock)stateChangedBlock {
    
    [[LLZShareMenuManager defaultManager] showShareMenuViewWithShareChannels:channels
                                                          withConfiguration:config
                                                         withViewController:viewController
                                                           withShareContext:context
                                                      withShowMenuFailBlock:failBlock
                                                      withStateChangedBlock:stateChangedBlock];
}

+ (void)showShareMenuViewWithShareChannels:(nullable NSArray*)channels
                         withConfiguration:(nullable LLZShareUIConfig *)config
                        withViewController:(nullable UIViewController *)viewController
                          withShareContext:(LLZShareContextModel *)context
                     withShowMenuFailBlock:(ShowMenuFailBlock)failBlock
                     withStateChangedBlock:(StateChangedBlock)stateChangedBlock
                    withShareTrackStrategy:(LLZShareEventTrackStrategy)strategy{
    [[LLZShareMenuManager defaultManager] showShareMenuViewWithShareChannels:channels
                                                          withConfiguration:config
                                                         withViewController:viewController
                                                           withShareContext:context
                                                      withShowMenuFailBlock:failBlock
                                                      withStateChangedBlock:stateChangedBlock
                                                     withShareTrackStrategy:LLZShareEventTrackStrategyV2];
}

+ (void)shareToChannels:(nullable NSArray*)channels
        withShareObject:(LLZShareObject *)object
      withConfiguration:(nullable LLZShareUIConfig *)config
     withViewController:(nullable UIViewController *)viewController
       withShareContext:(LLZShareContextModel *)context
       withSuccessBlock:(MenuShareSuccessBlock)successBlock
        withCancelBlock:(MenuShareCancelBlock)cancelBlock
         withErrorBlock:(MenuShareErrorBlock)errorBlock {
    
    [[LLZShareMenuManager defaultManager] shareWithObject:object
                                           withChannels:channels
                                      withConfiguration:config
                                     withViewController:viewController
                                        withShareContext:context
                                       withSuccessBlock:successBlock
                                        withCancelBlock:cancelBlock
                                         withErrorBlock:errorBlock];
}


+ (void)shareWithChannelObjectWrappers:(NSArray <LLZShareChannelObjectWrapper *> *)channelCustomWrappers
                   withConfiguration:(nullable LLZShareUIConfig *)config
                  withViewController:(nullable UIViewController *)viewController
                     withShareContext:(LLZShareContextModel *)context
                    withSuccessBlock:(MenuShareSuccessBlock)successBlock
                     withCancelBlock:(MenuShareCancelBlock)cancelBlock
                      withErrorBlock:(MenuShareErrorBlock)errorBlock {
    
    [[LLZShareMenuManager defaultManager] shareWithChannelCustomObjects:channelCustomWrappers
                                                    withConfiguration:config
                                                   withViewController:viewController
                                                      withShareContext:context
                                                     withSuccessBlock:successBlock
                                                      withCancelBlock:cancelBlock
                                                       withErrorBlock:errorBlock];
    
}

+ (BOOL)isShowingShareView {
    return [LLZShareMenuManager defaultManager].isShowingShareView;
}

+ (void)dismissShareMenu {
    [[LLZShareMenuManager defaultManager] dismissShareMenu];
}

+ (CGFloat)shareSheetHeight {
    return [[LLZShareMenuManager defaultManager] shareSheetHeight];
}

- (void)setTrackShareMenuEventOn:(BOOL)isOn {
    [LLZShareMenuManager defaultManager].needEventTrack = isOn;
}


@end
