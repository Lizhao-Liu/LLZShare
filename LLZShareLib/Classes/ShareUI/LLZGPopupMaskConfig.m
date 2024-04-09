//
//  LLZGPopupMaskConfig.m
//  LLZShareLib-ShareUI
//
//  Created by zhaozhao on 2024/4/8.
//

#import "LLZGPopupMaskConfig.h"

@implementation LLZGPopupMaskConfig


-(instancetype)init {
    self = [super init];
    if (self) {
        self.maskColor = [UIColor clearColor];
        self.superView = nil;
        self.offsetInsets = UIEdgeInsetsZero;
        self.tapToDismiss = NO;
        self.animationDuration = .2f;
        self.completion = nil;
        self.dismiss = nil;
    }
    return self;
}

+ (UIColor *)mainTint {
    if (@available(iOS 15.0, *)) {
        return [UIColor tintColor];
    } else {
        return [UIColor blackColor];
    }
}

@end
