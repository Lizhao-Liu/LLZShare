//
//  NSString+LLZShareLib.m
//  LLZShareLib
//
//  Created by Lizhao on 2023/4/4.
//

#import "NSString+LLZShareLib.h"

@implementation NSString (LLZShareLib)

- (BOOL)containsChinese {
    NSRegularExpression *regularexpression = [[NSRegularExpression alloc] initWithPattern:@"[\u4e00-\u9fa5]" options:NSRegularExpressionCaseInsensitive error:nil];
    return ([regularexpression numberOfMatchesInString:self options:NSMatchingReportProgress range:NSMakeRange(0, self.length)] > 0);
}

- (BOOL)isEmpty {
    if (self && self.length > 0) {
        return NO;
    }
    return YES;
}

@end
