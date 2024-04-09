//
//  LLZShareObject.h
//  LLZShareModule
//
//  Created by Lizhao on 2022/11/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 分享内容父类
@interface LLZShareObject : NSObject

/**
 * 标题
 * @note 标题的长度依各个平台的要求而定
 */
@property (copy,nonatomic) NSString *shareTitle;

/**
 * 描述
 * @note 描述内容的长度依各个平台的要求而定
 */
@property (copy,nonatomic) NSString *shareContent;

@end

/// 分享文本类
@interface LLZShareMessageObject : LLZShareObject

/**
 * 使用父类shareContent属性 文本内容 必填
 */
//@property (copy,nonatomic) NSString *shareContent;

@end


/// 分享图片类
@interface LLZShareImageObject : LLZShareObject

//分享图片地址 (与分享图片二选一即可）
@property (copy,nonatomic) NSString *shareImageUrl;

//分享图片(与分享图片地址二选一即可）
@property (strong,nonatomic) UIImage *shareImage;

@property (nonatomic, assign) BOOL isPNG;

//缩略图，非必填，如果不填默认压缩分享图片展示
@property (nonatomic, strong) UIImage *thumbImage;

@end


/// 分享视频类
@interface LLZShareVideoObject : LLZShareObject

// 视频本地存放路径，本地链接必填
@property (copy, nonatomic) NSString *localPath;

/// 视频下载地址 远程链接必填
@property (copy, nonatomic) NSString *downloadUrl;

/// 视频文件大小 远程链接必填
@property (copy, nonatomic) NSString *fileSize;

/// 视频下载失败转入链接 远程链接选填
@property (copy, nonatomic) NSString *failActionUrl;

/// 视频下载成功转入链接 远程链接选填
@property (copy, nonatomic) NSString *successActionUrl;

/// 视频文件名称 远程链接选填
@property (copy, nonatomic) NSString *fileName;

@end


/// 分享链接类 （页面跳转类）
@interface LLZShareWebpageObject : LLZShareObject

/** 网页的url地址 必填
 * @note 不能为空且长度不能超过10K
 */
@property (nonatomic, retain) NSString *webpageUrl;

// 链接分享缩略图 非必填 默认显示app图标
@property (nonatomic, strong) UIImage *thumbImage;
// 链接分享缩略图地址 非必填 默认显示app图标
@property (nonatomic, strong) NSString *thumbImageUrl;

@end

typedef NSString *LLZShareMiniProgramType NS_STRING_ENUM;
FOUNDATION_EXPORT LLZShareMiniProgramType const LLZShareMiniProgramTypeRelease;
FOUNDATION_EXPORT LLZShareMiniProgramType const LLZShareMiniProgramTypeTest;
FOUNDATION_EXPORT LLZShareMiniProgramType const LLZShareMiniProgramTypePreview;


/// 分享小程序类
@interface LLZShareMiniProgramObject : LLZShareObject
/**
 小程序username 必填
 */
@property (nonatomic, strong) NSString *userName;

/**
 小程序页面的路径
 */
@property (nonatomic, strong) NSString *path;

/**
 小程序新版本的预览图 128k  制大小不超过128KB(shareLib内部会压缩)，自定义图片建议长宽比是 5:4 预览图
 */
@property (nonatomic, strong) UIImage *hdImage;

/**
 小程序版本类型
 - 正式版 @"release"
 - 测试/开发版 @"test"
 - 预览版 @"preview"
 非必填，默认线上环境分享正式版小程序，测试环境分享体验版小程序
 */
@property (nonatomic, assign) LLZShareMiniProgramType type;

/**
 低版本微信网页链接
 */
@property (nonatomic, strong) NSString *sharePageUrl;

@end


// 分享自动匹配类型类（为兼容旧版本分享库设置，与原LLZShareInfoModel数据结构相似，可直接转换）
@interface LLZShareAutoTypeObject : LLZShareObject

//分享图片地址
@property (copy,nonatomic) NSString *shareImageUrl;
//分享页面地址
@property (copy,nonatomic) NSString *sharePageUrl;
//分享图片
@property (strong,nonatomic) UIImage *shareImage;

/* 以下为小程序特有字段 */
@property (copy,nonatomic) NSString *path;          // 小程序页面路径
@property (copy,nonatomic) NSString *userName;      // 小程序原始id
@property (strong,nonatomic) UIImage *miniAppImage; // 小程序自定义图片 使用该字段!!! 限制大小不超过128KB(shareLib内部会压缩)，自定义图片建议长宽比是 5:4。
@property (assign, nonatomic) LLZShareMiniProgramType miniProgramType; //小程序版本类型

/* 以下为下载视频特有字段 */
@property (copy, nonatomic) NSString *downloadUrl;  // 视频下载地址 必填
@property (copy, nonatomic) NSString *fileSize;     // 视频文件大小 必填
@property (copy, nonatomic) NSString *failActionUrl;
@property (copy, nonatomic) NSString *successActionUrl;
@property (copy, nonatomic) NSString *fileName;

@end

NS_ASSUME_NONNULL_END
