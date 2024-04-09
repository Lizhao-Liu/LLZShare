//
//  WXApiRequestSender.m
//
//  Created by Lizhao on 2023/3/27.
//

#import "WXApiRequestSender.h"
#import <WechatOpenSDK/WXApi.h>
#import "WXApiRequestHandler.h"
#import "WXApiManager.h"
#import "SendMessageToWXReq+requestWithTextOrMediaMessage.h"
#import "WXMediaMessage+messageConstruct.h"
//@import LLZDoctorService;
@import YYModel;

@implementation WXApiRequestSender

+ (void)sendReq:(BaseReq *)req completion:(void (^ __nullable)(BOOL success))completion {
    [WXApi sendReq:req completion:^(BOOL success) {
        if(!success){
//            LLZDoctorEventError *error = [[LLZDoctorEventError alloc] initWithPlatform:LLZDoctorPlatformHubble];
//            error.feature = @"share_wx";
//            error.tag = @"share";
//            NSString *shareReqStr = [req yy_modelToJSONString];
//            NSString *errorDetailStr =[NSString stringWithFormat:@"The request to send to WeChat has encountered an error. Request details: %@", shareReqStr];
//            error.errorDetail = errorDetailStr;
//            id<LLZDoctorServiceProtocol> doctorService = BIND_SERVICE(LLZDoctorContext.new, LLZDoctorServiceProtocol);
//            [doctorService doctor:error];
            if(completion){
                completion(success);
            }
        }
    }];
}


@end
