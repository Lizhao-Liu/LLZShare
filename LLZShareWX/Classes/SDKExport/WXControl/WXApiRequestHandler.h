//
//  WXApiManager.h
//  SDKSample
//
//  Created by Jeason on 15/7/14.
//
//

#import <Foundation/Foundation.h>
#import <WechatOpenSDK/WXApiObject.h>

@interface WXApiRequestHandler : NSObject

+ (void)sendText:(NSString *)text
         InScene:(enum WXScene)scene;

+ (void)sendImageData:(NSData *)imageData
              TagName:(NSString *)tagName
           MessageExt:(NSString *)messageExt
               Action:(NSString *)action
           ThumbImage:(UIImage *)thumbImage
              InScene:(enum WXScene)scene;

+ (void)sendLinkURL:(NSString *)urlString
            TagName:(NSString *)tagName
              Title:(NSString *)title
        Description:(NSString *)description
         ThumbImage:(UIImage *)thumbImage
            InScene:(enum WXScene)scene;

+ (void)sendMusicURL:(NSString *)musicURL
             dataURL:(NSString *)dataURL
               Title:(NSString *)title
         Description:(NSString *)description
          ThumbImage:(UIImage *)thumbImage
             InScene:(enum WXScene)scene;

+ (void)sendVideoURL:(NSString *)videoURL
               Title:(NSString *)title
         Description:(NSString *)description
          ThumbImage:(UIImage *)thumbImage
             InScene:(enum WXScene)scene;

+ (void)sendEmotionData:(NSData *)emotionData
             ThumbImage:(UIImage *)thumbImage
                InScene:(enum WXScene)scene;

+ (void)sendFileData:(NSData *)fileData
       fileExtension:(NSString *)extension
               Title:(NSString *)title
         Description:(NSString *)description
          ThumbImage:(UIImage *)thumbImage
             InScene:(enum WXScene)scene;

+ (void)sendAppContentData:(NSData *)data
                   ExtInfo:(NSString *)info
                    ExtURL:(NSString *)url
                     Title:(NSString *)title
               Description:(NSString *)description
                MessageExt:(NSString *)messageExt
             MessageAction:(NSString *)action
                ThumbImage:(UIImage *)thumbImage
                   InScene:(enum WXScene)scene;

+ (void)addCardsToCardPackage:(NSArray *)cardIds;

+ (void)sendAuthRequestScope:(NSString *)scope
                       State:(NSString *)state
                      OpenID:(NSString *)openID
            InViewController:(UIViewController *)viewController;

//分享小程序
+ (void)sendMiniProgram:(NSString *)webpageUrl
               userName:(NSString *)userName
                   path:(NSString *)path
            hdImageData:(NSData *)hdImageData
                  title:(NSString *)title
            description:(NSString *)description
               miniType:(WXMiniProgramType)type;

/// 打开微信小程序
/// @param userName 拉起的小程序的username
/// @param path 拉起小程序页面的可带参路径，不填默认拉起小程序首页，对于小游戏，可以只传入 query 部分，来实现传参效果，如：传入 "?foo=bar"。
/// @param type 拉起小程序的类型 0：正式版（默认） 1：测试版 2：预览版
+ (void)sendMiniProgramUsername:(NSString *)userName
                           path:(NSString *)path
                           type:(NSInteger )type
                     completion:(void (^)(BOOL success))completion;

@end
