//
//  LLZShareMenuItem.m
//  LLZShareLib
//
//  Created by Lizhao on 2022/10/26.
//

#import "LLZShareMenuItem.h"
#import "LLZShareChannelManager.h"
#import "LLZShareChannelHandler.h"

#ifndef EMPTYSTRING
#define EMPTYSTRING(A) ({__typeof(A) __a = (A);__a == nil ? @"" : [NSString stringWithFormat:@"%@",__a];})
#endif

const CGFloat kShareItemWidth = 50.0;
const CGFloat kShareEdgeInsetHeight = 12.;
const CGFloat kShareItemHeight = kShareItemWidth + 2 * kShareEdgeInsetHeight; //包括上下边距

@interface LLZShareMenuItem ()

@property (nonatomic, readwrite) LLZShareChannelType channelType;

@end

@implementation LLZShareMenuItem

+ (instancetype)itemWithShareChannelType:(LLZShareChannelType)channelType {
    id<LLZShareChannelHandler> handler = [[LLZShareChannelManager defaultManager] shareHandlerWithChannelType:channelType];
    LLZShareMenuItem *item = [super buttonWithType:UIButtonTypeCustom];
    if (item) {
        item.channelType = channelType;
        if([handler respondsToSelector:@selector(shareChannelName)] && handler.shareChannelName){
            item.name = handler.shareChannelName;
        } else {
            item.name = [self defaultNameForChannel:channelType];
        }
        if([handler respondsToSelector:@selector(shareChannelIcon)] && handler.shareChannelIcon){
            item.icon = handler.shareChannelIcon;
        } else {
            item.icon = [self defaultIconForChannel:channelType];
        }
    
        [item setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [item setTitle:EMPTYSTRING(item.name) forState:UIControlStateNormal];
        [item.titleLabel setFont:[UIFont systemFontOfSize:12.0]];
        [item.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [item setImage:item.icon forState:UIControlStateNormal];
        
        CGFloat tempWidth = kShareItemWidth;
        CGFloat tempHeight = kShareItemWidth;

        [item setFrame:CGRectMake(0, 0, tempWidth, tempHeight)];
        [item setTitleEdgeInsets:UIEdgeInsetsMake(kShareItemHeight, -tempWidth, 0, 0)];
    }
    return item;
}


+ (UIImage *)defaultIconForChannel:(LLZShareChannelType)channelType {
    NSString *iconName;
    switch (channelType) {
        case LLZShareChannelTypeSaveVideo:
            iconName = @"icon_download";
            break;
        case LLZShareChannelTypeSaveImage:
            iconName = @"saveimg";
            break;
        case LLZShareChannelTypePhone:
            iconName = @"icon_phone";
            break;
        case LLZShareChannelTypeSMS:
            iconName = @"dx";
            break;
        case LLZShareChannelTypeQQ:
            iconName = @"icon_share_qq";
            break;
        case LLZShareChannelTypeQzone:
            iconName = @"icon_share_qzone";
            break;
        case LLZShareChannelTypeWechatSession:
            iconName = @"wx";
            break;
        case LLZShareChannelTypeWechatTimeline:
            iconName = @"pyq";
            break;
        case LLZShareChannelTypeDY:
            iconName = @"icon_douyin";
            break;
        case LLZShareChannelTypeKS:
            iconName = @"icon_kuaishou";
            break;
        default:
            NSLog(@"自定义channel需要提前设置icon 图片");
            return nil;
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ShareUI" ofType:@"bundle"];
    UIImage *icon = [UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:iconName]];
    
    return icon;
}

+ (NSString *)defaultNameForChannel:(LLZShareChannelType)channelType {
    switch (channelType) {
        case LLZShareChannelTypeSaveVideo:
            return @"保存视频";
        case LLZShareChannelTypeSaveImage:
            return @"保存图片";
        case LLZShareChannelTypePhone:
            return @"电话通知";
        case LLZShareChannelTypeSMS:
            return @"短信";
        case LLZShareChannelTypeQQ:
            return @"QQ";
        case LLZShareChannelTypeQzone:
            return @"QQ空间";
        case LLZShareChannelTypeWechatSession:
            return @"微信好友";
        case LLZShareChannelTypeWechatTimeline:
            return @"朋友圈";
        case LLZShareChannelTypeDY:
            return @"抖音分享";
        case LLZShareChannelTypeKS:
            return @"快手分享";
        default:
            return nil;
    }
}


@end
