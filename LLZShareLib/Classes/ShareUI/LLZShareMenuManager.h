//
//  LLZShareMenuManager.h
//  LLZShareLib
//
//  Created by Lizhao on 2022/10/30.
//

#import <Foundation/Foundation.h>
@import LLZShareService;

NS_ASSUME_NONNULL_BEGIN


@interface LLZShareMenuManager : NSObject

// 分享弹窗是否正在展示分享弹窗
@property (nonatomic, assign, readonly) BOOL isShowingShareView;
@property(nonatomic, assign) BOOL needEventTrack;


+ (instancetype)defaultManager;

// 添加新方法：弹出分享弹窗，并将选择的分享渠道作为参数返回，使用者可以根据分享渠道调用LLZShareManager的直接分享方法进行分享；
// 需手动关闭分享弹窗
// 传入的平台必须是合法并且是core模块已经检测到的已经存在的平台，不然会被过滤
- (void)showShareMenuViewWithShareChannels:(nullable NSArray*)channels
                         withConfiguration:(nullable LLZShareUIConfig *)config
                        withViewController:(nullable UIViewController *)viewController
                          withShareContext:(LLZShareContextModel *)context
                     withShowMenuFailBlock:(ShowMenuFailBlock)failBlock
                     withStateChangedBlock:(StateChangedBlock)stateChangedBlock;

- (void)showShareMenuViewWithShareChannels:(nullable NSArray*)channels
                         withConfiguration:(nullable LLZShareUIConfig *)config
                        withViewController:(nullable UIViewController *)viewController
                          withShareContext:(LLZShareContextModel *)context
                     withShowMenuFailBlock:(ShowMenuFailBlock)failBlock
                     withStateChangedBlock:(StateChangedBlock)stateChangedBlock
                    withShareTrackStrategy:(LLZShareEventTrackStrategy)strategy;

- (void)dismissShareMenu;


// 兼容老方法，实现一步分享，不同平台分享同样内容 (传入一个共用的 model)
// 传入的平台必须是合法并且是core模块已经检测到的已经存在的平台，不然会被过滤
- (void)shareWithObject:(LLZShareObject *)object
          withChannels:(nullable NSArray*)channels
     withConfiguration:(nullable LLZShareUIConfig *)config
    withViewController:(nullable UIViewController *)viewController
       withShareContext:(LLZShareContextModel *)context
      withSuccessBlock:(MenuShareSuccessBlock)successBlock
       withCancelBlock:(MenuShareCancelBlock)cancelBlock
        withErrorBlock:(MenuShareErrorBlock)errorBlock;


// 兼容老方法，实现一步分享，不同平台分享不同内容 (传入一个wrapper(channel+object)数组)
// 传入的分享渠道必须是合法并且是core模块已经检测到的已安装支持分享的渠道，不然会被过滤，如果传入渠道皆不可分享则返回错误
- (void)shareWithChannelCustomObjects:(NSArray <LLZShareChannelObjectWrapper *> *)channelCustomWrappers
                   withConfiguration:(nullable LLZShareUIConfig *)config
                  withViewController:(nullable UIViewController *)viewController
                     withShareContext:(LLZShareContextModel *)context
                    withSuccessBlock:(MenuShareSuccessBlock)successBlock
                     withCancelBlock:(MenuShareCancelBlock)cancelBlock
                      withErrorBlock:(MenuShareErrorBlock)errorBlock;


// 获取分享弹框高度
- (CGFloat)shareSheetHeight;
@end

NS_ASSUME_NONNULL_END
