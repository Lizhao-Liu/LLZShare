//
//  LLZShareMenuItem.h
//  LLZShareLib
//
//  Created by Lizhao on 2022/10/26.
//

#import <UIKit/UIKit.h>
@import LLZShareService;

NS_ASSUME_NONNULL_BEGIN

extern const CGFloat kShareItemWidth;
extern const CGFloat kShareItemHeight;
extern const CGFloat kShareEdgeInsetHeight;

@interface LLZShareMenuItem : UIButton

+ (instancetype)itemWithShareChannelType:(LLZShareChannelType)channelType;

@property (nonatomic, readonly) LLZShareChannelType channelType;

@property (strong, nonatomic)  UIImage *icon;
@property (strong, nonatomic)  NSString *name;

@end

NS_ASSUME_NONNULL_END
