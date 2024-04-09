//
//  LLZShareEventTracker.h
//  LLZShareLib
//
//  Created by Lizhao on 2022/10/31.
//

#import <Foundation/Foundation.h>
@import LLZShareService;

NS_ASSUME_NONNULL_BEGIN

@interface LLZShareEventTracker : NSObject

+ (void)shareResultTrackWithShareChannel:(LLZShareChannelType)channelType shareResult:(BOOL)isSucceed shareContext:(LLZShareContextModel *)contextModel;

// v1策略埋点使用分享渠道字符串
+ (NSString *)shareChannelString:(LLZShareChannelType)channelType;


@end

NS_ASSUME_NONNULL_END
