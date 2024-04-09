//
//  LLZShareUIConfig.h
//  LLZShareService
//
//  Created by Lizhao on 2022/11/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class LLZShareMenuLinkBtnModel;
/// 分享菜单样式配置类
@interface LLZShareUIConfig : NSObject

// 预览内容数据
@property (nonatomic, strong) UIImage *previewImage;              // 预览图片
@property (nonatomic, copy) NSString *preImageUrl;                // 预览图片网络url

@property (nonatomic, strong) UIView *headerView;                 // 头部卡片视图
@property (nonatomic, strong) UIView *bottomView;                 // 底部卡片视图

@property (nonatomic, copy) NSString *shareMenuTitle;             // 主标题
@property (nonatomic, copy) NSString *shareMenuSubTitle;          // 副标题
@property (nonatomic, strong) LLZShareMenuLinkBtnModel *linkBtn;   // 链接跳转按钮

+ (instancetype)defaultShareUIConfig;

@end

/// 分享菜单链接按钮model
@interface LLZShareMenuLinkBtnModel : NSObject

@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *scheme;

@end


NS_ASSUME_NONNULL_END
