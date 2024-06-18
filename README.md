# LLZShare 接入指南

## 第三方平台配置

### 配置SSO白名单

如果你的应用使用了如SSO授权登录或跳转到第三方分享功能，在iOS9/10下就需要增加一个可跳转的白名单，即`LSApplicationQueriesSchemes`，否则将在SDK判断是否跳转时用到的canOpenURL时返回NO，进而只进行webview授权或授权/分享失败。

在项目中的info.plist中加入应用白名单:

![LSApplicationQueriesSchemes](https://image.ymm56.com/ymmfile/ps-temporary/1eb3ch2n6.png)


### 配置URL Scheme

- URL Scheme是通过系统找到并跳转对应app的一类设置，通过向项目中的info.plist文件中加入`URL types`可使用第三方平台所注册的appkey信息向系统注册你的app，当跳转到第三方应用授权或分享后，可直接跳转回你的app。
- 添加URL Types可工程设置面板设置

![URL Scheme配置](https://image.ymm56.com/ymmfile/ps-temporary/1eb3ch2n0.png)

### 权限配置

分享的图片通过相册进行跨进程共享手段，还需要填相册访问权限，在 info 标签栏中添加 Privacy - Photo Library Usage Description

---

### 微信相关配置：

如果需要接入微信分享/微信支付等功能，需要配置Universal Link

##### 1. 配置universal link文件

对Universal Links配置要求
a）Universal Links必须支持https
b）Universal Links配置的paths不能带query参数
c）微信使用Universal Links拉起第三方App时，会在Universal Links末尾拼接路径和参数，因此App配置的paths必须加上通配符/*

示例：

```json
{
    "applinks": {
        "apps": [],
        "details": [
        	{ 
				"appID": "RE8QQ53ZV2.com.xiwei.yunmanman",
				"paths": ["/ymmdriver/*"]
			},
			{ 
				"appID": "RE8QQ53ZV2.com.xiwei.ymmshipper",
				"paths": ["/ymmshipper/*"]
			}
        ]
    }
}
```



##### 2. AppId能力配置

![identifier配置](https://image.ymm56.com/ymmfile/ps-temporary/1eb3ch2n3.png)

##### 3. Unlink工程配置

![工程配置unlink](https://image.ymm56.com/ymmfile/ps-temporary/1eb3ch2n2.png)

##### 4. LSApplicationQueriesSchemes

![LSApplicationQueriesSchemes](https://image.ymm56.com/ymmfile/ps-temporary/1eb3ch2n6.png)

##### 5. 微信开放平台配置

到对应的开发者应用进行设置 [微信开放平台](https://open.weixin.qq.com/)

![开放平台应用配置](https://image.ymm56.com/ymmfile/ps-temporary/1eb3ch2n4.png)


---

## 初始化设置

### 初始化LLZShareLib

app启动的时候，需在application:didFinishLaunchingWithOptions:中完成LLZShareLib分享功能的初始化工作

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // 完成LLZShareLib内部初始化工作
  [LLZShareManager sharelib_application:application didFinishLaunchingWithOptions:launchOptions];
}
```



### 初始化第三方平台

以下是第三方平台初始化工作，通常都是启动的时候在 application:didFinishLaunchingWithOptions:中添加初始化方法，也可注册在分享的业务执行之前

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // 以qq平台初始化为例
  LLZShareChannelConfig *qqConfig = [LLZShareChannelConfig qqConfigWithAppID:YOUR_APP_ID 
                                                             universalLink:YOUR_APP_UNIVERSALLINK  
                                                isCrossAppMessageResponder:YES]; // 是否作为其他app返回响应信息的接收者

[LLZShareManager registerPlatform:LLZSharePlatformQQ withConfiguration:qqConfig];
  
}
```



## 设置系统回调

### 设置openUrl系统回调

```objc
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    if([LLZShareManager sharelib_application:app openURL:url options:options]){
        return YES;
    }
    ...
    return result;
}
```

### 设置Universal Links系统回调

```objc
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    if([LLZShareManager sharelib_application:application continueUserActivity:userActivity restorationHandler:restorationHandler]){
        return YES;
    }
    ... 
    return result;
}
```





# 依赖配置

### 通过sdk集成

在业务模块自身的podspec文件中添加依赖

```objc
s.dependency 'LLZShareLib'
```

头文件引入

```objc
@import LLZShareLib;
```

调用`LLZShareManager`暴露类方法，实现分享

# 分享设置

## 分享库支持分享渠道与内容设置

|     渠道     | 纯文本 | 图片 | web 链接 | 视频 | 小程序 |
| :----------: | :----: | :--: | :------: | :--: | :----: |
|     短信     |   √    |  ×   |    ×     |  ×   |   ×    |
|     电话     |   √    |  ×   |    ×     |  ×   |   ×    |
| 本地保存图片 |   ×    |  √   |    ×     |  ×   |   ×    |
| 本地保存视频 |   ×    |  ×   |    ×     |  √   |   ×    |
|   微信聊天   |   √    |  √   |    √     |  ×   |   √    |
|  微信朋友圈  |   √    |  √   |    √     |  ×   |   ×    |
|    qq聊天    |   √    |  √   |    √     |  ×   |   ×    |
|   qq朋友圈   |   √    |  √   |    √     |  ×   |   ×    |
|     抖音     |   ×    |  ×   |    ×     |  √   |   ×    |
|     快手     |   ×    |  ×   |    ×     |  √   |   ×    |

### 分享渠道枚举值

```objc
// 分享渠道枚举
typedef NS_ENUM(NSUInteger, LLZShareChannelType) {

  LLZShareChannelTypeNoShareChannel   = -1,

  LLZShareChannelTypeSaveImage       = 1,  // 保存图片

  LLZShareChannelTypeSaveVideo        = 2,  // 保存视频

  LLZShareChannelTypeSMS             = 3,  // 短信

  LLZShareChannelTypePhone           = 4,  // 电话

  LLZShareChannelTypeWechatSession    = 5,  // 微信聊天

  LLZShareChannelTypeWechatTimeline   = 6,  // 微信朋友圈

  LLZShareChannelTypeQQ              = 7,  // qq聊天

  LLZShareChannelTypeQzone           = 8,  // qq朋友圈

  LLZShareChannelTypeDY               = 10, // 抖音

  LLZShareChannelTypeKS               = 11, // 快手

};
```



### 分享内容数据模型

#### 1. 分享内容基类

不同分享内容共用属性

```objc
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
```



#### 2. 分享文本类

```objc
/// 分享文本类
@interface LLZShareMessageObject : LLZShareObject

/// 继承父类属性，shareContent表示文本内容 必填

@end
```



#### 3. 分享图片类

```objc
/// 分享图片类
@interface LLZShareImageObject : LLZShareObject

//分享图片地址 (与分享图片二选一即可）
@property (copy,nonatomic) NSString *shareImageUrl;

//分享图片(与分享图片地址二选一即可）
@property (strong,nonatomic) UIImage *shareImage;

//缩略图，非必填，如果不填默认压缩分享图片展示
@property (nonatomic, strong) UIImage *thumbImage;

@end
```



#### 4. 分享视频类

```objc
/// 分享视频类
@interface LLZShareVideoObject : LLZShareObject

/// 视频下载地址 必填
@property (copy, nonatomic) NSString *downloadUrl;

/// 视频文件大小 必填
@property (copy, nonatomic) NSString *fileSize;

/// 视频下载失败转入链接
@property (copy, nonatomic) NSString *failActionUrl;

/// 视频下载成功转入链接
@property (copy, nonatomic) NSString *successActionUrl;

/// 视频文件名称
@property (copy, nonatomic) NSString *fileName;

@end
```

#### 5. 分享链接类/页面跳转类

```objc
/// 分享链接类 （页面跳转类）
@interface LLZShareWebpageObject : LLZShareObject

/** 网页的url地址 必填 如果分享渠道是LLZShareChannelTypeMotorcade，即表示路由地址
 * @note 不能为空且长度不能超过10K
 */
@property (nonatomic, retain) NSString *webpageUrl;

// 链接分享缩略图 非必填 默认显示app图标
@property (nonatomic, strong) UIImage *thumbImage;
// 链接分享缩略图地址 非必填 默认显示app图标
@property (nonatomic, strong) NSString *thumbImageUrl;

@end
```



#### 6. 分享小程序类

```objc
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
 低版本微信网页链接
 */
@property (nonatomic, strong) NSString *sharePageUrl;

@end
```



#### 7. 自动识别分享内容类

根据传入的属性自动判断类型，判断优先级：

1. userName不为空判断为小程序类型
2. sharePageUrl不为空判断为链接类型
3. shareImageUrl / shareImage不为空判断为图片分类型
4. shareContent 不为空判断为文字类型

```objc
// 分享自动匹配类型类（为兼容旧版本分享库设置，与原LLZShareInfoModel数据结构一致，可自动转换）
@interface LLZShareAutoTypeObject : LLZShareObject

//分享内容
@property (copy,nonatomic) NSString *shareContent;
//分享图片地址
@property (copy,nonatomic) NSString *shareImageUrl;
//分享页面地址，如果分享渠道是LLZShareChannelTypeMotorcade，sharePageUrl表示路由地址
@property (copy,nonatomic) NSString *sharePageUrl;
//分享图片
@property (strong,nonatomic) UIImage *shareImage;

/* 以下为小程序特有字段 */
@property (copy,nonatomic) NSString *path;          // 小程序页面路径
@property (copy,nonatomic) NSString *userName;      // 小程序原始id
@property (strong,nonatomic) UIImage *miniAppImage; // 小程序自定义图片 使用该字段 限制大小不超过128KB(shareLib内部会压缩)，自定义图片建议长宽比是 5:4。

/* 以下为下载视频特有字段 */
@property (copy, nonatomic) NSString *downloadUrl;  // 视频下载地址 必填
@property (copy, nonatomic) NSString *fileSize;     // 视频文件大小 必填
@property (copy, nonatomic) NSString *failActionUrl;
@property (copy, nonatomic) NSString *successActionUrl;
@property (copy, nonatomic) NSString *fileName;

@end
```



## 基础分享功能

### 1. 直接分享（分享给指定渠道）

```objc
/// 直接分享
/// @param shareChannelType 目标分享渠道 渠道类型 @see LLZShareChannelType
/// @param shareObject 分享的内容 @see LLZShareObject
/// @note shareObject 电话分享场景则不需要传入分享内容object
/// @param currentViewController 只针对sms,motorcade等需要传入viewcontroller的渠道, 非必填, 默认使用当前正在展示的vc
/// @param context 分享的context信息, 用于埋点上报使用 @see LLZShareContextModel
/// @param successBlock 分享成功的回调
/// @param cancelBlock 分享取消的回调
/// @param errorBlock 分享失败的回调
+ (void)shareToChannel:(LLZShareChannelType)shareChannelType
       withShareObject:(nullable LLZShareObject *)shareObject
 currentViewController:(nullable UIViewController *)currentViewController
      withShareContext:(LLZShareContextModel *)context
      withSuccessBlock:(ShareSuccessBlock)successBlock
       withCancelBlock:(ShareCancelBlock)cancelBlock
        withErrorBlock:(ShareErrorBlock)errorBlock;
```



结果回调

```objc
// title: 返回分享渠道标题 @see LLZShareResponseTitle
// msg: 分享结果提示信息
typedef void (^ShareSuccessBlock) (LLZShareResponseTitle title, NSString *msg);
typedef void (^ShareCancelBlock) (LLZShareResponseTitle title, NSString *msg);

// title: 返回分享渠道标题 @see LLZShareResponseTitle 
// error: 返回分享错误，错误码@see LLZShareErrorCode
typedef void (^ShareErrorBlock) (LLZShareResponseTitle title, NSError *error);
```



示例代码

（以集成LLZShareLib SDK为例）

```objc
// 1. 设置分享内容object
LLZShareImageObject *imageObj = [[LLZShareImageObject alloc] init];
imageObj.shareImage = [UIImage imageNamed:@"shareImage.png"];
imageObj.shareTitle = @"share image";

// 2. 调用分享接口
[LLZShareManager shareToChannel:LLZShareChannelTypeWechatSession
               withShareObject:imageObj
              withShareContext:nil
              withSuccessBlock:^(LLZShareResponseTitle  _Nonnull title, NSString * _Nonnull msg) {
    NSLog(@"%@ %@", title, msg);
}
               withCancelBlock:^(LLZShareResponseTitle  _Nonnull title, NSString * _Nonnull msg) {
    NSLog(@"%@ %@", title, msg);
}
                withErrorBlock:^(LLZShareResponseTitle  _Nonnull title, NSError * _Nonnull error) {
    NSLog(@"%@ %@", title, error.localizedDescription)
}];
```

### 2. 弹出分享菜单并分享

执行逻辑：弹出分享弹窗+根据用户点击渠道自动进行分享
区分 **不同渠道分享相同内容** 与 **不同渠道分享不同内容** 两种形式

#### 不同渠道分享内容一致

```objc
/// 弹出分享菜单并分享 （不同分享渠道分享同样内容）
/// @param channels channels 开发者预定义显示在分享菜单上的分享渠道类型@see LLZShareChannelType 数组, 非必填, 传入nil默认显示当前设备所有可分享渠道
/// @note channels 传入的分享渠道需要是core模块已经检测到的当前用户设备支持分享的渠道，不然会被过滤
/// @param object 分享的内容 @see LLZShareObject
/// @param config 分享菜单视图样式配置类，@see LLZShareUIConfig, 非必填，传入nil显示默认样式
/// @param viewController 分享菜单需要嵌入展示的vc, 非必填, 传入nil默认嵌入到当前window
/// @param context 分享行为发生的context，@see LLZShareContextModel 用于上报埋点使用
/// @param successBlock 通过菜单分享成功返回的block
/// @param cancelBlock 通过菜单分享取消返回的block
/// @param errorBlock 通过菜单分享失败返回的block
+ (void)shareToChannels:(NSArray*)channels
        withShareObject:(LLZShareObject *)object
      withConfiguration:(nullable LLZShareUIConfig *)config
     withViewController:(nullable UIViewController *)viewController
       withShareContext:(nullable LLZShareContextModel *)context
       withSuccessBlock:(MenuShareSuccessBlock)successBlock
        withCancelBlock:(MenuShareCancelBlock)cancelBlock
         withErrorBlock:(MenuShareErrorBlock)errorBlock;
```



示例代码

```objc
    LLZShareMessageObject *messageObject = [[LLZShareMessageObject alloc] init];
    messageObject.shareTitle = @"Test Title";
    messageObject.shareTitle = @"Test Content";
    
    LLZShareContextModel *testContext =  [[LLZShareContextModel alloc] init];
    testContext.shareSceneValue = ShareSceneShipperAuth;
    
    NSArray *shareChannels = @[@(LLZShareChannelTypeQQ),@(LLZShareChannelTypeWechatSession),@(LLZShareChannelTypeWechatTimeline)];
    
    [LLZShareManager shareToChannels:shareChannels
                    withShareObject:messageObject
                  withConfiguration:nil
                 withViewController:[UIViewController LLZ_currentViewController]
                   withShareContext:testContext
                   withSuccessBlock:^(LLZShareResponseChannelStr  _Nonnull selectedChannelTypeStr, LLZShareResponseTitle  _Nonnull title, NSString * _Nonnull msg) {
        [self showAlertWithTitle: title withMessage:msg];
    }
                    withCancelBlock:^(LLZShareResponseChannelStr  _Nonnull selectedChannelTypeStr, LLZShareResponseTitle  _Nonnull title, NSString * _Nonnull msg) {
        [self showAlertWithTitle: title withMessage:msg];
    }
                     withErrorBlock:^(LLZShareResponseChannelStr  _Nonnull selectedChannelTypeStr, LLZShareResponseTitle  _Nonnull title, NSError * _Nonnull error) {
        [self showAlertWithTitle: title withMessage:error.localizedDescription];
    }];
```



#### 不同渠道分享内容不同

```objc
/// 弹出分享菜单并分享 （渠道不同，分享的内容不同）
/// @param channelObjectWrappers 分享渠道与内容绑定的wrapper数组 @see LLZShareChannelObjectWrapper， 开发者预定义显示在分享菜单上的分享渠道类型和渠道对应的分享内容
/// @param config 分享菜单视图样式配置类，@see LLZShareUIConfig, 非必填，传入nil显示默认样式
/// @param viewController 分享菜单需要嵌入展示的vc, 非必填, 传入nil默认嵌入到当前window
/// @param context 分享行为发生的context，@see LLZShareContextModel 用于上报埋点使用
/// @param successBlock 通过菜单分享成功返回的block
/// @param cancelBlock 通过菜单分享取消返回的block
/// @param errorBlock 通过菜单分享失败返回的block
+ (void)shareWithChannelObjectWrappers:(NSArray <LLZShareChannelObjectWrapper *> *)channelObjectWrappers
                     withConfiguration:(nullable LLZShareUIConfig *)config
                    withViewController:(nullable UIViewController *)viewController
                      withShareContext:(LLZShareContextModel *)context
                      withSuccessBlock:(MenuShareSuccessBlock)successBlock
                       withCancelBlock:(MenuShareCancelBlock)cancelBlock
                        withErrorBlock:(MenuShareErrorBlock)errorBlock;

//  LLZShareChannelObjectWrapper
@interface LLZShareChannelObjectWrapper : NSObject
/// 需要绑定的分享渠道
@property (nonatomic, assign) LLZShareChannelType targetShareChannel;
/// 需要绑定的分享内容
@property (nonatomic, strong) LLZShareObject *targetShareObject;
+ (instancetype)shareWrapperWithChannel:(LLZShareChannelType)channel shareObject:(LLZShareObject *)object;
@end
```



示例代码

```objc
    LLZShareChannelObjectWrapper *ks = [LLZShareChannelObjectWrapper shareWrapperWithChannel:LLZShareChannelTypeKS shareObject:videoModel];
    LLZShareChannelObjectWrapper *wechat = [LLZShareChannelObjectWrapper shareWrapperWithChannel:LLZShareChannelTypeWechatSession shareObject:miniAppModel];
    LLZShareChannelObjectWrapper *wechatTimeline = [LLZShareChannelObjectWrapper shareWrapperWithChannel:LLZShareChannelTypeWechatTimeline shareObject:messageModel];
    LLZShareChannelObjectWrapper *qq = [LLZShareChannelObjectWrapper shareWrapperWithChannel:LLZShareChannelTypeQQ shareObject:imageModel];
    LLZShareChannelObjectWrapper *qqZone = [LLZShareChannelObjectWrapper shareWrapperWithChannel:LLZShareChannelTypeQzone shareObject:messageModel];
    LLZShareChannelObjectWrapper *dy = [LLZShareChannelObjectWrapper shareWrapperWithChannel:LLZShareChannelTypeDY shareObject:videoModel];
    
    [LLZShareManager shareWithChannelObjectWrappers:@[ks, wechat, wechatTimeline, qq, qqZone, dy]
                                 withConfiguration:nil
                                withViewController:[UIViewController currentViewController]
                                  withShareContext:testContext
                                  withSuccessBlock:^(LLZShareResponseChannelStr  _Nonnull selectedChannelTypeStr, LLZShareResponseTitle  _Nonnull title, NSString * _Nonnull msg) {
        [self showAlertWithTitle: title withMessage:msg];
    }
                                   withCancelBlock:^LLZShareResponseChannelStr  _Nonnull selectedChannelTypeStr, LLZShareResponseTitle  _Nonnull title, NSString * _Nonnull msg) {
        [self showAlertWithTitle: title withMessage:msg];
    }
                                    withErrorBlock:^(LLZShareResponseChannelStr  _Nonnull selectedChannelTypeStr, LLZShareResponseTitle  _Nonnull title, NSError * _Nonnull error) {
        [self showAlertWithTitle: title withMessage:error.localizedDescription];
    }];
 
```



#### 结果回调

```objc
// selectedChannelTypeStr: @see LLZShareResponseChannelStr 返回用户选择的分享渠道（字符串）
// title: @see LLZShareResponseTitle 分享渠道类目标题
// msg: 分享结果提示信息
typedef void (^MenuShareSuccessBlock) (LLZShareResponseChannelStr selectedChannelTypeStr, LLZShareResponseTitle title, NSString *msg);
typedef void (^MenuShareCancelBlock) (LLZShareResponseChannelStr selectedChannelTypeStr, LLZShareResponseTitle title, NSString *msg);

// selectedChannelTypeStr: @see LLZShareResponseChannelStr 返回用户选择的分享渠道（字符串）
// title: @see LLZShareResponseTitle 返回分享渠道类目标题
// error: 返回分享错误，错误码详见@see LLZShareErrorCode
typedef void (^MenuShareErrorBlock) (LLZShareResponseChannelStr selectedChannelTypeStr, LLZShareResponseTitle title, NSError *error);
```



### 3. 弹出分享菜单（不自动执行分享）

执行逻辑：

弹出分享弹窗，返回用户点击的渠道，不自动执行后续分享行为

开发者根据渠道在回调block内自定义后续分享行为，此时分享菜单仍在显示

```objc
/// 显示分享菜单
/// @param channels 开发者预定义显示在分享菜单上的分享渠道类型@see LLZShareChannelType 数组, 非必填, 传入nil默认显示当前设备所有可分享渠道
/// @note channels 传入的分享渠道需要是core模块已经检测到的当前用户设备支持分享的渠道，不然会被过滤
/// @param config 分享菜单视图样式配置类，@see LLZShareUIConfig, 非必填，传入nil显示默认样式
/// @param viewController 分享菜单需要嵌入展示的vc, 非必填, 传入nil默认嵌入到当前window
/// @param context 分享行为发生的context @see LLZShareContextModel, 用于上报埋点使用
/// @param failBlock 分享菜单弹出错误block，一般发生于传入的分享渠道当前用户设备没有安装或版本太旧
/// @param stateChangedBlock 分享弹窗状态变更回调
+ (void)showShareMenuViewWithShareChannels:(nullable NSArray*)channels
                         withConfiguration:(nullable LLZShareUIConfig *)config
                        withViewController:(nullable UIViewController *)viewController
                          withShareContext:(LLZShareContextModel *)context
                     withShowMenuFailBlock:(ShowMenuFailBlock)failBlock
                     withStateChangedBlock:(StateChangedBlock)stateChangedBlock;

/// 关闭分享弹窗
+ (void)dismissShareMenu;
```



结果回调

```objc
// 分段式分享回调
// 分段式菜单显示失败回调
typedef void (^ShowMenuFailBlock) (NSError *error);
// 分段式菜单状态变更回调
typedef void (^StateChangedBlock) (LLZShareMenuState state, LLZShareChannelType selectedChannel);

// 分段式回调状态
typedef NS_ENUM(NSInteger, LLZShareMenuState){
    ShareMenuCancelled = 0, //用户关闭了分享弹窗
    ShareChannelSelected = 1 //用户点击了分享渠道
};
```



示例代码：

```objc
// 设置分享内容
LLZShareImageObject *imageObj = [[LLZShareImageObject alloc] init];
imageObj.shareImage = [UIImage imageNamed:@"shareImage.png"];
imageObj.shareTitle = @"share image";

// 设置分享渠道
NSArray *shareChannels = @[@(LLZShareChannelTypeQQ),@(LLZShareChannelTypeWechatSession),@(LLZShareChannelTypeWechatTimeline)];

UIViewController *currentVC = [UIViewController currentViewController];
[LLZShareManager showShareMenuViewWithShareChannels:shareChannels
                                 withConfiguration:nil
                                withViewController:currentVC
                                  withShareContext:testContext
                             withShowMenuFailBlock:^(NSError * _Nonnull error) {
    [self showAlertWithTitle:@"分享失败" withMessage:error.localizedDescription];
}
                            withStateChangedBlock:^(LLZShareMenuState state,LLZShareChannelType selectedChannel) { 
    if(state == ShareMenuCancelled){
        // 用户关闭了分享菜单
        [self showAlertWithTitle:@"取消分享" withMessage:@"分享弹窗被取消"];
    } else {
         // 可根据所选渠道进行一些定制化行为
         [self didSelectChannel:selectedChannel];
         // 执行分享，分享给用户所选渠道
        [LLZShareManager shareToChannel:selectedChannel
                       withShareObject:imageObj
                      withShareContext:testContext
                      withSuccessBlock:^(LLZShareResponseTitle  _Nonnull title, NSString * _Nonnull msg) {
    NSLog(@"%@ %@", title, msg);
}
                       withCancelBlock:^(LLZShareResponseTitle  _Nonnull title, NSString * _Nonnull msg) {
    NSLog(@"%@ %@", title, msg);
}
                        withErrorBlock:^(LLZShareResponseTitle  _Nonnull title, NSError * _Nonnull error) {
    NSLog(@"%@ %@", title, error.localizedDescription)
}];
        // 关闭分享弹窗
        [LLZShareManager dismissShareMenu];
    }
}];
```

### 4. 判断是否安装客户端

```objc
+ (BOOL)isQQInstalled;
+ (BOOL)isWXAppInstalled;
+ (BOOL)isKSAppInstalled;
+ (BOOL)isDYAppInstalled;
+ (BOOL)isInstalled:(LLZShareChannelType)channelType;

+ (NSArray *)allAvailableShareChannels; //返回当前设备所有已安装且支持分享的渠道number类型数组
```



## 附录

### 分享失败返回error错误码：

```objc
  // 错误码:
  typedef NS_ENUM(NSInteger, LLZShareErrorCode) {
    // 分享渠道错误
    LLZShareErrorType_NotInstall = 2000,  // 相关分享平台未安装
    LLZShareErrorType_NotSupport = 2001,  // 相关分享平台版本不支持 或设备不支持
    LLZShareErrorType_NotRegistered = 2002,  // 未向相关平台注册app
    LLZShareErrorType_NoGetShareChannel  = 2003,  // 未发现对应渠道

    //分享内容错误
    LLZShareErrorType_shareObjectIncomplete = 2004,  // 分享内容object不完整
    LLZShareErrorType_shareObjectNil = 2005,  // 分享内容object未传入
    LLZShareErrorType_shareObjectTypeIllegal = 2006,  // 分享内容object类型不匹配

    //视频、图片保存错误
    LLZShareErrorType_PermissionDenied = 2007,  // 无相关权限
    LLZShareErrorType_DownloadFail = 2008,  // 下载失败(视频)

    //分享请求已发送，第三方返回错误
    LLZShareErrorType_ShareFailed  = 2009,  // 分享请求已发送，第三方分享平台返回分享错误信息
    //服务器错误
    LLZShareErrorType_NoNetwork = 2011,
  };
```



### 分享信息埋点类数据结构:

```objc
@interface LLZShareContextModel : NSObject
/** 业务id */
@property (strong, nonatomic) NSString *businessId;
/** 分享场景名称（打点的 elementId 字段） */
@property (strong, nonatomic) NSString *shareSceneName;
/** 分享场景枚举  */
@property (assign, nonatomic) LLZShareSceneType shareSceneValue;
/** 业务埋点参数  */
@property (nonatomic, strong) NSDictionary *otherParams;

@end
```



### 分享菜单样式配置类数据结构

```objc
@interface LLZShareUIConfig : NSObject

// 预览内容数据
@property (nonatomic, strong) UIImage *previewImage;              // 预览图片
@property (nonatomic, copy) NSString *preImageUrl;                // 预览图片网络url

@property (nonatomic, strong) UIView *headerView;                 // 头部卡片视图
@property (nonatomic, strong) UIView *bottomView;                 // 底部卡片视图

// 即YMMShareHomeModel shareTitle
@property (nonatomic, copy) NSString *shareMenuTitle;             // 主标题
// 即YMMShareHomeModel content
@property (nonatomic, copy) NSString *shareMenuSubTitle;          // 副标题
// 即原YMMShareHomeModel btn
@property (nonatomic, strong) LLZShareMenuLinkBtnModel *linkBtn;       // 链接跳转按钮

+ (instancetype)defaultShareUIConfig;

@end
  
  
/// 分享菜单链接按钮model
@interface LLZShareMenuLinkBtnModel : NSObject

@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *scheme;

@end
```
