//
//  LLZShareContextModel.h
//  LLZShareService
//
//  Created by Lizhao on 2022/11/13.
//

#import <Foundation/Foundation.h>
#import "LLZShareDefine.h"

NS_ASSUME_NONNULL_BEGIN

// 满帮分享埋点数据model
@interface LLZShareContextModel : NSObject
/** 业务id */
@property (strong, nonatomic) NSString *businessId;
/** 分享场景名称（打点的 elementId 字段） */
@property (strong, nonatomic) NSString *shareSceneName;

/** 业务埋点参数  */
@property (nonatomic, strong) NSDictionary *otherParams;

@end


NS_ASSUME_NONNULL_END
