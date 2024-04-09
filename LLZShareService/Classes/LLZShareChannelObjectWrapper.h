//
//  LLZShareChannelObjectWrapper.h
//
//  Created by Lizhao on 2022/11/2.
//

#import <Foundation/Foundation.h>
#import "LLZShareDefine.h"
#import "LLZShareObject.h"

NS_ASSUME_NONNULL_BEGIN

@class LLZShareObject;

@interface LLZShareChannelObjectWrapper : NSObject

/// 需要绑定的分享渠道
@property (nonatomic, assign) LLZShareChannelType targetShareChannel;
/// 需要绑定的分享内容
@property (nonatomic, strong) LLZShareObject *targetShareObject;

+ (instancetype)shareWrapperWithChannel:(LLZShareChannelType)channel shareObject:(LLZShareObject *)object;

@end

NS_ASSUME_NONNULL_END
