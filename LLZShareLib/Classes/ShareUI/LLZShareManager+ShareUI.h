//
//  LLZShareManager+ShareUI.h
//  LLZShareLib
//
//  Created by Lizhao on 2022/10/26.
//

#import "LLZShareManager.h"

NS_ASSUME_NONNULL_BEGIN

@class LLZShareUIConfig;
@class LLZShareObject;
@class LLZShareChannelObjectWrapper;
@class LLZShareContextModel;

@interface LLZShareManager (ShareUI)

#pragma mark - 弹出分享菜单并分享 （不同分享渠道分享同样内容）
/// 弹出分享菜单并分享 （不同分享渠道分享同样内容）
/// @param channels channels 开发者预定义显示在分享菜单上的分享渠道类型@see LLZShareChannelType 数组, 非必填, 传入nil默认显示当前设备所有可分享渠道
/// @note channels 传入的分享渠道需要是core模块已经检测到的当前用户设备支持分享的渠道，不然会被过滤
/// @param object 分享的内容 @see LLZShareObject
/// @param config 分享菜单视图样式配置类，@see LLZShareUIConfig, 非必填，传入nil显示默认样式
/// @param viewController 分享菜单需要嵌入展示的vc, 非必填, 传入nil默认嵌入到当前window
/// @param context 分享行为发生的context，@see LLZShareContextModel 用于上报埋点使用
/// @param successBlock 通过菜单分享成功返回的block
/// @param cancelBlock 通过菜单分享取消返回的block
/// @param errorBlock 通过菜单分享失败返回的block
+ (void)shareToChannels:(nullable NSArray*)channels
        withShareObject:(LLZShareObject *)object
      withConfiguration:(nullable LLZShareUIConfig *)config
     withViewController:(nullable UIViewController *)viewController
       withShareContext:(LLZShareContextModel *)context
       withSuccessBlock:(MenuShareSuccessBlock)successBlock
        withCancelBlock:(MenuShareCancelBlock)cancelBlock
         withErrorBlock:(MenuShareErrorBlock)errorBlock;


#pragma mark - 弹出分享菜单并分享 （渠道不同，分享的内容不同）
/// 弹出分享菜单并分享 （渠道不同，分享的内容不同）
/// @param channelObjectWrappers 分享渠道与内容绑定的wrapper数组 @see LLZShareChannelObjectWrapper， 开发者预定义显示在分享菜单上的分享渠道类型和渠道对应的分享内容
/// @param config 分享菜单视图样式配置类，@see LLZShareUIConfig, 非必填，传入nil显示默认样式
/// @param viewController 分享菜单需要嵌入展示的vc, 非必填, 传入nil默认嵌入到当前window
/// @param context 分享行为发生的context，@see LLZShareContextModel 用于上报埋点使用
/// @param successBlock 通过菜单分享成功返回的block
/// @param cancelBlock 通过菜单分享取消返回的block
/// @param errorBlock 通过菜单分享失败返回的block
+ (void)shareWithChannelObjectWrappers:(NSArray <LLZShareChannelObjectWrapper *> *)channelObjectWrappers
                     withConfiguration:(nullable LLZShareUIConfig *)config
                    withViewController:(nullable UIViewController *)viewController
                      withShareContext:(LLZShareContextModel *)context
                      withSuccessBlock:(MenuShareSuccessBlock)successBlock
                       withCancelBlock:(MenuShareCancelBlock)cancelBlock
                        withErrorBlock:(MenuShareErrorBlock)errorBlock;


#pragma mark - 显示分享菜单 (返回用户选择的渠道)
/// 显示分享菜单 返回用户选择渠道
/// @param channels 开发者预定义显示在分享菜单上的分享渠道类型@see LLZShareChannelType 数组, 非必填, 传入nil默认显示当前设备所有可分享渠道
/// @note channels 传入的分享渠道需要是core模块已经检测到的当前用户设备支持分享的渠道，不然会被过滤
/// @param config 分享菜单视图样式配置类，@see LLZShareUIConfig, 非必填，传入nil显示默认样式
/// @param viewController 分享菜单需要嵌入展示的vc, 非必填, 传入nil默认嵌入到当前window
/// @param context 分享行为发生的context @see LLZShareContextModel, 用于上报埋点使用
/// @param failBlock 分享菜单弹出错误block，一般发生于传入的分享渠道当前用户设备没有安装或版本太旧
/// @param stateChangedBlock 分享弹窗状态变更回调
///
+ (void)showShareMenuViewWithShareChannels:(nullable NSArray*)channels
                         withConfiguration:(nullable LLZShareUIConfig *)config
                        withViewController:(nullable UIViewController *)viewController
                          withShareContext:(LLZShareContextModel *)context
                     withShowMenuFailBlock:(ShowMenuFailBlock)failBlock
                     withStateChangedBlock:(StateChangedBlock)stateChangedBlock;


+ (void)showShareMenuViewWithShareChannels:(nullable NSArray*)channels
                         withConfiguration:(nullable LLZShareUIConfig *)config
                        withViewController:(nullable UIViewController *)viewController
                          withShareContext:(LLZShareContextModel *)context
                     withShowMenuFailBlock:(ShowMenuFailBlock)failBlock
                     withStateChangedBlock:(StateChangedBlock)stateChangedBlock
                    withShareTrackStrategy:(LLZShareEventTrackStrategy)strategy;



// 关闭分享弹窗
+ (void)dismissShareMenu;

// 是否正在显示分享弹窗
+ (BOOL)isShowingShareView;

// 获取分享弹框高度，如果当前没有正在展示的分享菜单返回菜单默认高度
+ (CGFloat)shareSheetHeight;

#pragma mark - 配置 默认开启
// 设置开启菜单展示埋点
- (void)setTrackShareMenuEventOn:(BOOL)isOn;

@end

NS_ASSUME_NONNULL_END
