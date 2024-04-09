//
//  LLZShareDefine.h
//  LLZShareModule
//
//  Created by Lizhao on 2022/11/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 分享渠道
// 满帮分享渠道
typedef NS_ENUM(NSUInteger, LLZShareChannelType) {
    LLZShareChannelTypeNoShareChannel      = -1,
    
    LLZShareChannelTypePredefine_Begin     = -0,
    LLZShareChannelTypeSaveImage           = 1,   // 保存图片
    LLZShareChannelTypeSaveVideo           = 2,   // 保存视频
    LLZShareChannelTypeSMS                 = 3,   // 短信
    LLZShareChannelTypePhone               = 4,   // 电话
    LLZShareChannelTypeWechatSession       = 5,   // 微信聊天
    LLZShareChannelTypeWechatTimeline      = 6,   // 微信朋友圈
    LLZShareChannelTypeQQ                  = 7,   // qq聊天
    LLZShareChannelTypeQzone               = 8,   // qq朋友圈
    LLZShareChannelTypeDY                  = 10,  // 抖音
    LLZShareChannelTypeKS                  = 11,  // 快手
    LLZShareChannelTypePredefine_End       = 99,
    
    LLZShareChannelTypeUserDefine_Begin     = 100,
    LLZShareChannelTypeUserDefine_End       = 200,
};

#pragma mark - 分享回调相关

// 分享结果返回title string
typedef NSString *LLZShareResponseTitle NS_STRING_ENUM;
extern LLZShareResponseTitle const DefaultShareChannelTitle;
extern LLZShareResponseTitle const WechatShareChannelTitle;
extern LLZShareResponseTitle const QQShareChannelTitle;
extern LLZShareResponseTitle const KuaiShouShareChannelTitle;
extern LLZShareResponseTitle const DouYinShareChannelTitle;
extern LLZShareResponseTitle const SaveImageShareChannelTitle;
extern LLZShareResponseTitle const SaveVideoShareChannelTitle;
extern LLZShareResponseTitle const PhoneShareChannelTitle;
extern LLZShareResponseTitle const SMSShareChannelTitle;

// 分享结果返回channel string
typedef NSString *LLZShareResponseChannelStr NS_STRING_ENUM;
extern LLZShareResponseChannelStr const WechatSession;
extern LLZShareResponseChannelStr const WechatTimeLine;
extern LLZShareResponseChannelStr const QQ;
extern LLZShareResponseChannelStr const QZone;
extern LLZShareResponseChannelStr const KuaiShou;
extern LLZShareResponseChannelStr const DouYin;
extern LLZShareResponseChannelStr const SaveImage;
extern LLZShareResponseChannelStr const SaveVideo;
extern LLZShareResponseChannelStr const Phone;
extern LLZShareResponseChannelStr const SMS;
extern LLZShareResponseChannelStr const NoShareChannel;

// 分享结果返回错误domain
extern NSString* const LLZShareErrorDomain;

// 分享结果返回错误码
typedef NS_ENUM(NSInteger, LLZShareErrorCode) {
    // 分享渠道错误
    LLZShareErrorType_NotInstall = 2000,  // 相关分享平台未安装
    LLZShareErrorType_NotSupport = 2001,  // 相关分享平台版本不支持 或设备不支持分享
    LLZShareErrorType_NotRegistered = 2002,  // 未向相关平台注册app
    LLZShareErrorType_NoGetShareChannel  = 2003,  // 未发现对应渠道

    //分享内容错误
    LLZShareErrorType_shareObjectIncomplete = 2004,  // 分享内容object不完整
    LLZShareErrorType_shareObjectNil = 2005,  // 分享内容object未传入
    LLZShareErrorType_shareObjectTypeIllegal = 2006,  // 分享内容object类型不匹配

    //视频、图片保存错误
    LLZShareErrorType_PermissionDenied = 2007,  // 无相关权限
    LLZShareErrorType_DownloadFail = 2008,  // 下载失败

    //分享请求发送，第三方返回错误
    LLZShareErrorType_ShareFailed  = 2009,  // 第三方分享平台返回分享错误信息
    
    //自定义分享渠道错误
    LLZShareErrorType_ProtocolNotOverride = 2010,  // 对应的LLZShareHandler的方法没有实现
    //服务器错误
    LLZShareErrorType_NoNetwork = 2011,

};

// 分享回调block
// 1. 无ui分享回调
typedef void (^ShareSuccessBlock) (LLZShareResponseTitle title, NSString *msg);
typedef void (^ShareCancelBlock) (LLZShareResponseTitle title, NSString *msg);
typedef void (^ShareErrorBlock) (LLZShareResponseTitle title, NSError *error);

// 2. 菜单分享回调
typedef void (^MenuShareSuccessBlock) (LLZShareResponseChannelStr selectedChannelTypeStr, LLZShareResponseTitle title, NSString *msg);
typedef void (^MenuShareCancelBlock) (LLZShareResponseChannelStr selectedChannelTypeStr, LLZShareResponseTitle title, NSString *msg);
typedef void (^MenuShareErrorBlock) (LLZShareResponseChannelStr selectedChannelTypeStr, LLZShareResponseTitle title, NSError *error);

// 3. 分段式分享回调
// 分段式菜单显示失败回调
typedef void (^ShowMenuFailBlock) (NSError *error);
// 分段式回调状态
typedef NS_ENUM(NSInteger, LLZShareMenuState){
    ShareMenuCancelled = 0,
    ShareChannelSelected = 1
};
// 分段式菜单状态变更回调
typedef void (^StateChangedBlock) (LLZShareMenuState state, LLZShareChannelType selectedChannel);


# pragma mark - 注册平台相关
// LLZShareLib 默认分享第三方平台
typedef NS_ENUM(NSUInteger, LLZSharePredefinedPlatformType) {
    LLZSharePlatformWechat     = 1,
    LLZSharePlatformQQ         = 2,
    LLZSharePlatformDY         = 3,
    LLZSharePlatformKS         = 4,
};

# pragma mark - 其它

// 触发 push, 目前只有本地 push
typedef void(^LLZSharePushBlock)(NSDictionary *pushInfo);

typedef NS_ENUM(NSInteger, LLZShareEventTrackStrategy) {
    LLZShareEventTrackStrategyV1 = 0,
    LLZShareEventTrackStrategyV2 = 1,
};

NS_ASSUME_NONNULL_END
