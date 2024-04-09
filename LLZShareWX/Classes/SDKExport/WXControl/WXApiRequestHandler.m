//
//  WXApiManager.m
//  SDKSample
//
//  Created by Jeason on 15/7/14.
//
//
#import <WechatOpenSDK/WXApi.h>
#import "WXApiRequestHandler.h"
#import "WXApiManager.h"
#import "SendMessageToWXReq+requestWithTextOrMediaMessage.h"
#import "WXMediaMessage+messageConstruct.h"
#import "WXApiRequestSender.h"

@implementation WXApiRequestHandler

#pragma mark - Public Methods
+ (void)sendText:(NSString *)text
         InScene:(enum WXScene)scene {
    SendMessageToWXReq *req = [SendMessageToWXReq requestWithText:text
                                                   OrMediaMessage:nil
                                                            bText:YES
                                                          InScene:scene];
//    [WXApi sendReq:req completion:nil];
    [WXApiRequestSender sendReq:req completion:nil];
}

+ (void)sendImageData:(NSData *)imageData
              TagName:(NSString *)tagName
           MessageExt:(NSString *)messageExt
               Action:(NSString *)action
           ThumbImage:(UIImage *)thumbImage
              InScene:(enum WXScene)scene {
    WXImageObject *ext = [WXImageObject object];
    ext.imageData = imageData;
    
    WXMediaMessage *message = [WXMediaMessage messageWithTitle:nil
                                                   Description:nil
                                                        Object:ext
                                                    MessageExt:messageExt
                                                 MessageAction:action
                                                    ThumbImage:thumbImage
                                                      MediaTag:tagName];
    
    SendMessageToWXReq* req = [SendMessageToWXReq requestWithText:nil
                                                   OrMediaMessage:message
                                                            bText:NO
                                                          InScene:scene];
    
//    [WXApi sendReq:req completion:nil];
    [WXApiRequestSender sendReq:req completion:nil];
}

+ (void)sendLinkURL:(NSString *)urlString
            TagName:(NSString *)tagName
              Title:(NSString *)title
        Description:(NSString *)description
         ThumbImage:(UIImage *)thumbImage
            InScene:(enum WXScene)scene {
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = urlString;

    WXMediaMessage *message = [WXMediaMessage messageWithTitle:title
                                                   Description:description
                                                        Object:ext
                                                    MessageExt:nil
                                                 MessageAction:nil
                                                    ThumbImage:thumbImage
                                                      MediaTag:tagName];
    
    SendMessageToWXReq* req = [SendMessageToWXReq requestWithText:nil
                                                   OrMediaMessage:message
                                                            bText:NO
                                                          InScene:scene];
    [WXApiRequestSender sendReq:req completion:nil];
}

+ (void)sendMusicURL:(NSString *)musicURL
             dataURL:(NSString *)dataURL
               Title:(NSString *)title
         Description:(NSString *)description
          ThumbImage:(UIImage *)thumbImage
             InScene:(enum WXScene)scene {
    WXMusicObject *ext = [WXMusicObject object];
    ext.musicUrl = musicURL;
    ext.musicDataUrl = dataURL;

    WXMediaMessage *message = [WXMediaMessage messageWithTitle:title
                                                   Description:description
                                                        Object:ext
                                                    MessageExt:nil
                                                 MessageAction:nil
                                                    ThumbImage:thumbImage
                                                      MediaTag:nil];
    
    SendMessageToWXReq* req = [SendMessageToWXReq requestWithText:nil
                                                   OrMediaMessage:message
                                                            bText:NO
                                                          InScene:scene];
    
    [WXApiRequestSender sendReq:req completion:nil];
}

+ (void)sendVideoURL:(NSString *)videoURL
               Title:(NSString *)title
         Description:(NSString *)description
          ThumbImage:(UIImage *)thumbImage
             InScene:(enum WXScene)scene {
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = description;
    [message setThumbImage:thumbImage];
    
    WXVideoObject *ext = [WXVideoObject object];
    ext.videoUrl = videoURL;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [SendMessageToWXReq requestWithText:nil
                                                   OrMediaMessage:message
                                                            bText:NO
                                                          InScene:scene];
    [WXApi sendReq:req completion:nil];
}

+ (void)sendEmotionData:(NSData *)emotionData
             ThumbImage:(UIImage *)thumbImage
                InScene:(enum WXScene)scene {
    WXMediaMessage *message = [WXMediaMessage message];
    [message setThumbImage:thumbImage];
    
    WXEmoticonObject *ext = [WXEmoticonObject object];
    ext.emoticonData = emotionData;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [SendMessageToWXReq requestWithText:nil
                                                   OrMediaMessage:message
                                                            bText:NO
                                                          InScene:scene];
    [WXApi sendReq:req completion:nil];
}

+ (void)sendFileData:(NSData *)fileData
       fileExtension:(NSString *)extension
               Title:(NSString *)title
         Description:(NSString *)description
          ThumbImage:(UIImage *)thumbImage
             InScene:(enum WXScene)scene {
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = description;
    [message setThumbImage:thumbImage];
    
    WXFileObject *ext = [WXFileObject object];
    ext.fileExtension = @"pdf";
    ext.fileData = fileData;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [SendMessageToWXReq requestWithText:nil
                                                   OrMediaMessage:message
                                                            bText:NO
                                                          InScene:scene];
    [WXApi sendReq:req completion:nil];
}

+ (void)sendAppContentData:(NSData *)data
                   ExtInfo:(NSString *)info
                    ExtURL:(NSString *)url
                     Title:(NSString *)title
               Description:(NSString *)description
                MessageExt:(NSString *)messageExt
             MessageAction:(NSString *)action
                ThumbImage:(UIImage *)thumbImage
                   InScene:(enum WXScene)scene {
    WXAppExtendObject *ext = [WXAppExtendObject object];
    ext.extInfo = info;
    ext.url = url;
    ext.fileData = data;

    WXMediaMessage *message = [WXMediaMessage messageWithTitle:title
                                                   Description:description
                                                        Object:ext
                                                    MessageExt:messageExt
                                                 MessageAction:action
                                                    ThumbImage:thumbImage
                                                      MediaTag:nil];
    
    SendMessageToWXReq* req = [SendMessageToWXReq requestWithText:nil
                                                   OrMediaMessage:message
                                                            bText:NO
                                                          InScene:scene];
    [WXApi sendReq:req completion:nil];

}

+ (void)addCardsToCardPackage:(NSArray *)cardItems {
    AddCardToWXCardPackageReq *req = [[AddCardToWXCardPackageReq alloc] init];
    req.cardAry = cardItems;
    [WXApi sendReq:req completion:nil];
}

+ (void)sendAuthRequestScope:(NSString *)scope
                       State:(NSString *)state
                      OpenID:(NSString *)openID
            InViewController:(UIViewController *)viewController {
    SendAuthReq* req = [[SendAuthReq alloc] init];
    req.scope = scope; // @"post_timeline,sns"
    req.state = state;
    req.openID = openID;
    
    [WXApi sendAuthReq:req
        viewController:viewController
              delegate:[WXApiManager sharedManager]
            completion:nil];
}

+ (void)sendMiniProgram:(NSString *)webpageUrl
                userName:(NSString *)userName
                    path:(NSString *)path
             hdImageData:(NSData *)hdImageData
                   title:(NSString *)title
             description:(NSString *)description
               miniType:(WXMiniProgramType)type {
    WXMiniProgramObject *wxMiniObject = [WXMiniProgramObject object];
    wxMiniObject.webpageUrl = webpageUrl;//兼容低版本的网页链接
    wxMiniObject.userName = userName;//小程序的原始id
    wxMiniObject.path = path;//小程序的页面路径
    wxMiniObject.hdImageData = hdImageData;//小程序节点高清大图,小于128K
    wxMiniObject.withShareTicket = YES;

    wxMiniObject.miniProgramType = type;

    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;//小程序标题
    message.description = description;//小程序描述
    message.mediaObject = wxMiniObject;
    // del by changxm 不再支持更古老微信版本(2016年版本) 防止由于图片大小问题分享失败
    //message.thumbData = hdImageData;//兼容旧版本节点的图片,小于32K,新版本优先
    //使用WXMiniProgramObject的hdImageData属性
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.message = message;
    req.scene = WXSceneSession;//目前只支持会话
    
//    [WXApi sendReq:req completion:nil];
    [WXApiRequestSender sendReq:req completion:nil];
}

+ (void)sendMiniProgramUsername:(NSString *)userName
                           path:(NSString *)path
                           type:(NSInteger )type 
                     completion:(void (^)(BOOL success))completion {
    WXLaunchMiniProgramReq *launchMiniProgramReq = [WXLaunchMiniProgramReq object];
    launchMiniProgramReq.userName = userName;
    launchMiniProgramReq.path = path;
    launchMiniProgramReq.miniProgramType = type;
    [WXApi sendReq:launchMiniProgramReq completion:completion];
}
@end
