//
//  LLZShareEventTracker.m
//  LLZShareLib
//
//  Created by Lizhao on 2022/10/31.
//

#import "LLZShareEventTracker.h"
@import LLZShareService;

@implementation LLZShareEventTracker

+ (void)shareResultTrackWithShareChannel:(LLZShareChannelType)channelType shareResult:(BOOL)isSucceed shareContext:(LLZShareContextModel *)contextModel {
    
    if(!contextModel) return;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@(channelType) forKey:@"shareChannel"];
    [dic setObject: (isSucceed ? @(1) : @(0)) forKey:@"share_result"];
    NSString *sceneName;
    if(contextModel.shareSceneName && contextModel.shareSceneName.length > 0){
        sceneName = contextModel.shareSceneName;
    }
    if(contextModel.otherParams && contextModel.otherParams.count > 0){
        [dic addEntriesFromDictionary:contextModel.otherParams];
    }
    if(sceneName){
        [dic setObject:sceneName forKey:@"share_scene"];
    }
//    [LLZDoctorUtil viewWithPage:@"tiga_share" referPage:nil region:@"Result" elementId:@"share_result" referSPM:nil extra:dic context:nil];
}


+ (void)addJournalForShareChannel:(LLZShareChannelType)channelType WithShareResult:(BOOL)isSucceed WithContextModel:(LLZShareContextModel *)contextModel {
    if(!contextModel) return;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@"yes" forKey:@"useNewShareLib"];
    [dic setObject:[self shareChannelString:channelType] forKey:@"channel"];
    [dic setObject: (isSucceed ? @(1) : @(0)) forKey:@"result"];
    NSString *sceneName;
    if(contextModel.shareSceneName && contextModel.shareSceneName.length > 0){
        sceneName = contextModel.shareSceneName;
    } else {
        sceneName = @"";
    }
//    [LLZDoctorUtil viewWithPage:@"share" referPage:nil elementId:sceneName extra:dic context:nil];
}

+ (NSString *)shareChannelString:(LLZShareChannelType)channelType {
    switch (channelType) {
        case LLZShareChannelTypeSaveVideo:
            return @"saveVideo";
        case LLZShareChannelTypeSaveImage:
            return @"saveImgModel";
        case LLZShareChannelTypePhone:
            return @"phone";
        case LLZShareChannelTypeSMS:
            return @"sms";
        case LLZShareChannelTypeQQ:
            return @"qq";
        case LLZShareChannelTypeQzone:
            return @"qZone";
        case LLZShareChannelTypeWechatSession:
            return @"wechat";
        case LLZShareChannelTypeWechatTimeline:
            return @"wechatFriend";
        case LLZShareChannelTypeDY:
            return @"dy";
        case LLZShareChannelTypeKS:
            return @"ks";
        default:
            return nil;
    }
}



@end

