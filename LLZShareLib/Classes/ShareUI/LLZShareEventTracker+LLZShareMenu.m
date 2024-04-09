//
//  LLZShareEventTracker+LLZShareMenu.m
//  LLZShareLib-ShareUI
//
//  Created by Lizhao on 2022/11/2.
//

#import "LLZShareEventTracker+LLZShareMenu.h"
#import <sys/time.h>
//@import LLZDoctorService;
@import LLZShareService;

@implementation LLZShareEventTracker (LLZShareMenu)


// 分享菜单弹起打点
+ (void)shareMenuViewTrackWithShareContext:(LLZShareContextModel *)contextModel trackStategy:(LLZShareEventTrackStrategy)shareTrackStrategy {
    if(shareTrackStrategy == LLZShareEventTrackStrategyV1){
        [self shareMenuViewV1TrackWithShareContext:contextModel trackStategy:shareTrackStrategy];
    } else if(shareTrackStrategy == LLZShareEventTrackStrategyV2){
        [self shareMenuViewV2TrackWithShareContext:contextModel trackStategy:shareTrackStrategy];
    }
}


// 用户选择渠道打点
+ (void)shareMenuClickTrackWithShareChannel:(LLZShareChannelType)channelType shareContext:(LLZShareContextModel *)contextModel trackStategy:(LLZShareEventTrackStrategy)shareTrackStrategy {
    if(shareTrackStrategy == LLZShareEventTrackStrategyV1){
        [self shareMenuClickV1TrackWithShareChannel:channelType shareContext:contextModel trackStategy:shareTrackStrategy];
    } else if(shareTrackStrategy == LLZShareEventTrackStrategyV2){
        [self shareMenuClickV2TrackWithShareChannel:channelType shareContext:contextModel trackStategy:shareTrackStrategy];
    }
}


#pragma mark - 新分享埋点

// 分享菜单被取消打点
+ (void)shareMenuCancelTrackWithShareContext:(LLZShareContextModel *)contextModel trackStategy:(LLZShareEventTrackStrategy)shareTrackStrategy {
    if(shareTrackStrategy == LLZShareEventTrackStrategyV2){
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        NSString *sceneName;
        if(contextModel.shareSceneName && contextModel.shareSceneName.length > 0){
            sceneName = contextModel.shareSceneName;
        } else  {
            sceneName = @"";
        }
        if(sceneName){
            [dic setObject:sceneName forKey:@"share_scene"];
        }
        if(contextModel.otherParams && contextModel.otherParams.count > 0){
            [dic addEntriesFromDictionary:contextModel.otherParams];
        }
//        [LLZDoctorUtil tapWithPage:@"tiga_share" referPage:nil region:@"Main" elementId:@"share_menu_close" extra:dic context:nil];
    }
}

// 分享菜单消失打点
+ (void)shareMenuViewDurationTrackWithShareContext:(LLZShareContextModel *)contextModel trackStategy:(LLZShareEventTrackStrategy)shareTrackStrategy {
    if(shareTrackStrategy == LLZShareEventTrackStrategyV2){
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        NSString *sceneName;
        if(contextModel.shareSceneName && contextModel.shareSceneName.length > 0){
            sceneName = contextModel.shareSceneName;
        } else {
            sceneName = @"";
        }
        if(sceneName){
            [dic setObject:sceneName forKey:@"share_scene"];
        }
        if(contextModel.otherParams && contextModel.otherParams.count > 0){
            [dic addEntriesFromDictionary:contextModel.otherParams];
        }
//        [LLZDoctorUtil viewWithPage:@"tiga_share" referPage:nil region:@"Main" elementId:@"pageview_stay_duration" referSPM:nil extra:dic context:nil];
    }
}

+ (void)shareMenuViewV2TrackWithShareContext:(LLZShareContextModel *)contextModel trackStategy:(LLZShareEventTrackStrategy)shareTrackStrategy {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSString *sceneName;
    if(contextModel.shareSceneName && contextModel.shareSceneName.length > 0){
        sceneName = contextModel.shareSceneName;
    } else {
        sceneName = @"";
    }
    if(sceneName){
        [dic setObject:sceneName forKey:@"share_scene"];
    }
    if(contextModel.otherParams && contextModel.otherParams.count > 0){
        [dic addEntriesFromDictionary:contextModel.otherParams];
    }
//    [LLZDoctorUtil viewWithPage:@"tiga_share" referPage:nil region:@"Main" elementId:@"pageview" referSPM:nil extra:dic context:nil];
}

+ (void)shareMenuClickV2TrackWithShareChannel:(LLZShareChannelType)channelType shareContext:(LLZShareContextModel *)contextModel trackStategy:(LLZShareEventTrackStrategy)shareTrackStrategy {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSString *sceneName;
    if(contextModel.shareSceneName && contextModel.shareSceneName.length > 0){
        sceneName = contextModel.shareSceneName;
    } else {
        sceneName = @"";
    }
    if(sceneName){
        [dic setObject:sceneName forKey:@"share_scene"];
    }
    if(contextModel.otherParams && contextModel.otherParams.count > 0){
        [dic addEntriesFromDictionary:contextModel.otherParams];
    }
    [dic setObject:@(channelType) forKey:@"shareChannel"];
//    [LLZDoctorUtil tapWithPage:@"tiga_share" referPage:nil region:@"Main" elementId:@"share_menu_click" extra:dic context:nil];
}

#pragma mark - 旧分享埋点

+ (void)shareMenuViewV1TrackWithShareContext:(LLZShareContextModel *)contextModel trackStategy:(LLZShareEventTrackStrategy)shareTrackStrategy {
    //场景字段 shareScene 必须有,业务ID businessId 选填
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    if(contextModel.otherParams && contextModel.otherParams.count > 0){
        [dic addEntriesFromDictionary:contextModel.otherParams];
    }
    
    NSString *sceneName;
    if(contextModel.shareSceneName && contextModel.shareSceneName.length > 0){
        sceneName = contextModel.shareSceneName;
    } else {
        sceneName =  @"";
    }
    
//    [LLZDoctorUtil viewWithPage:@"share" referPage:nil elementId:sceneName extra:dic context:nil];
}


+ (void)shareMenuClickV1TrackWithShareChannel:(LLZShareChannelType)channelType shareContext:(LLZShareContextModel *)contextModel trackStategy:(LLZShareEventTrackStrategy)shareTrackStrategy {
    //场景字段 shareScene 必须有,业务ID businessId 选填
    //点击分享的item时候记录的打点
    if(!contextModel) return;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@"yes" forKey:@"useNewShareLib"];
    [dic setObject:[self shareChannelString:channelType] forKey:@"channel"];
    if(contextModel.otherParams && contextModel.otherParams.count > 0){
        [dic addEntriesFromDictionary:contextModel.otherParams];
    }
    NSString *sceneName;
    if(contextModel.shareSceneName && contextModel.shareSceneName.length > 0){
        sceneName = contextModel.shareSceneName;
    } else {
        sceneName = @"";
    }
     
    // 抛出埋点方法
//    [LLZDoctorUtil tapWithPage:@"share" referPage:nil elementId:sceneName extra:dic context:nil];
}

@end
