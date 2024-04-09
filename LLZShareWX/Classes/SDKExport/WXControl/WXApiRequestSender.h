//
//  WXApiRequestSender.h
//
//  Created by Lizhao on 2023/3/27.
//

#import <Foundation/Foundation.h>
#import <WechatOpenSDK/WXApiObject.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXApiRequestSender : NSObject

+ (void)sendReq:(BaseReq *)req completion:(void (^ __nullable)(BOOL success))completion;

@end

NS_ASSUME_NONNULL_END
