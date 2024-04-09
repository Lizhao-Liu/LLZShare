//
//  LLZShareWechatHandler.h
//  LLZShareLib
//
//  Created by Lizhao on 2022/10/18.
//

#import <Foundation/Foundation.h>
@import LLZShareLib;

NS_ASSUME_NONNULL_BEGIN
@class BaseResp;

@interface LLZShareWechatHandler : NSObject<LLZShareChannelHandler>

@property(nonatomic, assign) BOOL needLogFromWX;


- (void)sendMiniProgramUsername:(NSString *)userName
                              path:(NSString *)path
                              type:(NSInteger )type
                        completion:(void (^)(BOOL success))completion;
@end

NS_ASSUME_NONNULL_END
