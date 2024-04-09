//
//  LLZShareEventTracker+LLZShareMenu.h
//  LLZShareLib-ShareUI
//
//  Created by Lizhao on 2022/11/2.
//

#import "LLZShareEventTracker.h"

NS_ASSUME_NONNULL_BEGIN

@interface LLZShareEventTracker (LLZShareMenu)

// 分享菜单弹起打点
+ (void)shareMenuViewTrackWithShareContext:(LLZShareContextModel *)contextModel trackStategy:(LLZShareEventTrackStrategy)shareTrackStrategy;


// 用户选择渠道打点
+ (void)shareMenuClickTrackWithShareChannel:(LLZShareChannelType)channelType shareContext:(LLZShareContextModel *)contextModel trackStategy:(LLZShareEventTrackStrategy)shareTrackStrategy;


// 分享菜单被取消打点
+ (void)shareMenuCancelTrackWithShareContext:(LLZShareContextModel *)contextModel trackStategy:(LLZShareEventTrackStrategy)shareTrackStrategy;


// 分享菜单消失打点
+ (void)shareMenuViewDurationTrackWithShareContext:(LLZShareContextModel *)contextModel trackStategy:(LLZShareEventTrackStrategy)shareTrackStrategy;

@end

NS_ASSUME_NONNULL_END
