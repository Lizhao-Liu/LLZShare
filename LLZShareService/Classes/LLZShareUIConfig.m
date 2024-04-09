//
//  LLZShareUIConfig.m
//  LLZShareService
//
//  Created by Lizhao on 2022/11/13.
//

#import "LLZShareUIConfig.h"

#ifndef EMPTYSTRING
#define EMPTYSTRING(A) ({__typeof(A) __a = (A);__a == nil ? @"" : [NSString stringWithFormat:@"%@",__a];})
#endif

static NSString *const kShareDefaultTitle = @"分享到";

@implementation LLZShareUIConfig

- (void)setShareMenuTitle:(NSString *)shareMenuTitle{
    _shareMenuTitle = EMPTYSTRING(shareMenuTitle);
}

+ (instancetype)defaultShareUIConfig {
    LLZShareUIConfig *defaultConfig = [[LLZShareUIConfig alloc] init];
    defaultConfig.shareMenuTitle = kShareDefaultTitle;
    return defaultConfig;
}

- (void)setPreImageUrl:(NSString *)preImageUrl {
    if(!preImageUrl || EMPTYSTRING(preImageUrl).length == 0){
        _preImageUrl = nil;
    }
    _preImageUrl = EMPTYSTRING(preImageUrl);
}

@end

@implementation LLZShareMenuLinkBtnModel


@end
