//
//  LLZShareContextModel.m
//  LLZShareService
//
//  Created by Lizhao on 2022/11/13.
//

#import "LLZShareContextModel.h"

#ifndef EMPTYSTRING
#define EMPTYSTRING(A) ({__typeof(A) __a = (A);__a == nil ? @"" : [NSString stringWithFormat:@"%@",__a];})
#endif

@implementation  LLZShareContextModel
- (void)setShareSceneName:(NSString *)shareSceneName {
    _shareSceneName = EMPTYSTRING(shareSceneName);
}

- (void)setBusinessId:(NSString *)businessId {
    _businessId = EMPTYSTRING(businessId);
}

@end
