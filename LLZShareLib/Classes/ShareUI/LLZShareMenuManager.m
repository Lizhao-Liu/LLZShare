//
//  LLZShareMenuManager.m
//  LLZShareLib
//
//  Created by Lizhao on 2022/10/30.
//

#import "LLZShareMenuManager.h"
#import "LLZShareChannelManager.h"
#import "LLZShareMenuItem.h"
#import "LLZShareMenuView.h"
#import "LLZShareEventTracker+LLZShareMenu.h"


@interface LLZShareMenuManager ()<LLZShareMenuViewDelegate>

@property (nonatomic, strong) NSMutableArray *shareChannels;
@property (nonatomic, strong) NSMutableArray<LLZShareMenuItem *> *shareItems;

@property (nonatomic, strong) NSMutableDictionary *shareObjectDictionary;
@property (nonatomic, strong) LLZShareObject *shareObject;
@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, strong) LLZShareMenuView *shareMenuView;

@property (nonatomic, copy) MenuShareSuccessBlock successBlock;
@property (nonatomic, copy) MenuShareCancelBlock cancelBlock;
@property (nonatomic, copy) MenuShareErrorBlock errorBlock;

@property (nonatomic, copy) StateChangedBlock stateChangedBlock;
@property (nonatomic, copy) ShowMenuFailBlock showFailBlock;

@property(nonatomic, strong) LLZShareContextModel *context;
@property(nonatomic, strong) NSArray *orderedChannels;

@property (nonatomic, assign) LLZShareEventTrackStrategy trackStrategy;

@end

@implementation LLZShareMenuManager

+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    static LLZShareMenuManager  *instance;
    dispatch_once(&onceToken, ^{
        instance = [[LLZShareMenuManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if(self){
        _isShowingShareView = NO;
        _needEventTrack = YES;
        _trackStrategy = LLZShareEventTrackStrategyV1;
        _orderedChannels = @[@(LLZShareChannelTypeWechatSession),@(LLZShareChannelTypeWechatTimeline),@(LLZShareChannelTypeSMS),@(LLZShareChannelTypeQQ),@(LLZShareChannelTypeQzone),@(LLZShareChannelTypeSaveImage),@(LLZShareChannelTypePhone),@(LLZShareChannelTypeSaveVideo),@(LLZShareChannelTypeKS),@(LLZShareChannelTypeDY)];
    }
    return self;
}

#pragma mark - Public Methods

- (void)showShareMenuViewWithShareChannels:(NSArray*)channels
                         withConfiguration:(LLZShareUIConfig *)config
                        withViewController:(UIViewController *)viewController
                          withShareContext:(LLZShareContextModel *)context
                     withShowMenuFailBlock:(ShowMenuFailBlock)failBlock
                     withStateChangedBlock:(StateChangedBlock)stateChangedBlock {
    [self showShareMenuViewWithShareChannels:channels withConfiguration:config withViewController:viewController withShareContext:context withShowMenuFailBlock:failBlock withStateChangedBlock:stateChangedBlock withShareTrackStrategy:LLZShareEventTrackStrategyV1];
}

- (void)showShareMenuViewWithShareChannels:(NSArray*)channels
                         withConfiguration:(LLZShareUIConfig *)config
                        withViewController:(UIViewController *)viewController
                          withShareContext:(LLZShareContextModel *)context
                     withShowMenuFailBlock:(ShowMenuFailBlock)failBlock
                     withStateChangedBlock:(StateChangedBlock)stateChangedBlock
                    withShareTrackStrategy:(LLZShareEventTrackStrategy)trackStrategy {
    // 1. 重置信息
    [self resetInfo];
    // 2. 设置分享回调方法
    self.stateChangedBlock = stateChangedBlock;
    self.showFailBlock = failBlock;
    self.context = context;
    self.trackStrategy = trackStrategy;
    // 3. 设置显示的分享渠道
    if(![self setUpShareItems:channels]) {
        return;
    }
    for(LLZShareMenuItem *item in self.shareItems){
        [item addTarget:self action:@selector(channelSelected:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if(viewController){
        // 4. 设置展示分享弹窗所在的vc
        self.currentViewController = viewController;
        // 5. 创建分享菜单
        self.shareMenuView = [[LLZShareMenuView alloc] initWithConfig:config shareMenuItems:self.shareItems presentingVC:self.currentViewController];
    } else {
        // 5. 创建分享菜单
        self.shareMenuView = [[LLZShareMenuView alloc] initWithConfig:config shareMenuItems:self.shareItems];
    }
    
    self.shareMenuView.delegate = self;
    // 6. 显示分享菜单
    [self showShareMenu];
}

- (void)shareWithObject:(LLZShareObject *)object
          withChannels:(NSArray*)channels
     withConfiguration:(LLZShareUIConfig *)config
    withViewController:(UIViewController *)viewController
       withShareContext:(LLZShareContextModel *)context
      withSuccessBlock:(MenuShareSuccessBlock)successBlock
       withCancelBlock:(MenuShareCancelBlock)cancelBlock
        withErrorBlock:(MenuShareErrorBlock)errorBlock {
    // 1. 重置信息
    [self resetInfo];
    // 2. 设置分享回调方法
    self.successBlock = successBlock;
    self.cancelBlock = cancelBlock;
    self.errorBlock = errorBlock;
    self.context = context;
    self.shareObject = object;
    // 3. 设置显示的分享渠道和分享数据model
    if(![self setUpShareItems:channels]) {
        return;
    }
    for(LLZShareMenuItem *item in self.shareItems){
        [item addTarget:self action:@selector(shareToChannel:) forControlEvents:UIControlEventTouchUpInside];
    }
    if(viewController){
        // 4. 设置展示分享弹窗所在的vc
        self.currentViewController = viewController;
        // 5. 创建分享菜单
        self.shareMenuView = [[LLZShareMenuView alloc] initWithConfig:config shareMenuItems:self.shareItems presentingVC:self.currentViewController];
    } else {
        // 5. 创建分享菜单
        self.shareMenuView = [[LLZShareMenuView alloc] initWithConfig:config shareMenuItems:self.shareItems];
    }
    
    // 6. 显示分享菜单
    self.shareMenuView.delegate = self;
    [self showShareMenu];
}

- (void)shareWithChannelCustomObjects:(NSArray<LLZShareChannelObjectWrapper *> *)channelCustomWrappers
                   withConfiguration:(LLZShareUIConfig *)config
                  withViewController:(UIViewController *)viewController
                    withShareContext:(LLZShareContextModel *)context
                    withSuccessBlock:(MenuShareSuccessBlock)successBlock
                     withCancelBlock:(MenuShareCancelBlock)cancelBlock
                      withErrorBlock:(MenuShareErrorBlock)errorBlock {
    // 1. 重置信息
    [self resetInfo];
    // 2. 设置分享回调方法
    self.successBlock = successBlock;
    self.cancelBlock = cancelBlock;
    self.errorBlock = errorBlock;
    self.context = context;
    // 3. 设置显示的分享渠道
    if(!(channelCustomWrappers && channelCustomWrappers.count >= 1)){
        if(self.errorBlock){
            self.errorBlock(NoShareChannel, DefaultShareChannelTitle, [NSError errorWithDomain:LLZShareErrorDomain code:LLZShareErrorType_ShareFailed userInfo:@{NSLocalizedDescriptionKey:@"未传入分享内容"}]);
        }
        [self resetInfo];
        return;
    }
    NSMutableArray *channels = @[].mutableCopy;
    for(LLZShareChannelObjectWrapper *wrapper in channelCustomWrappers){
        [channels addObject:@(wrapper.targetShareChannel)];
    }
    
    if(![self setUpShareItems:channels]) {
        return;
    }
    [self setUpShareChannelModelDict:channelCustomWrappers];
    for(LLZShareMenuItem *item in self.shareItems){
        [item addTarget:self action:@selector(shareToChannel:) forControlEvents:UIControlEventTouchUpInside];
    }
    if(viewController){
        // 4. 设置展示分享弹窗所在的vc
        self.currentViewController = viewController;
        // 5. 创建分享菜单
        self.shareMenuView = [[LLZShareMenuView alloc] initWithConfig:config shareMenuItems:self.shareItems presentingVC:self.currentViewController];
    } else {
        // 5. 创建分享菜单
        self.shareMenuView = [[LLZShareMenuView alloc] initWithConfig:config shareMenuItems:self.shareItems];
    }
    // 6. 显示分享菜单
    self.shareMenuView.delegate = self;
    [self showShareMenu];
}

- (void)dismissShareMenu {
    [self.shareMenuView dismissShareView];
    self.shareMenuView = nil;
}

- (CGFloat)shareSheetHeight {
    if(self.shareMenuView){
        return self.shareMenuView.frame.size.height;
    }
    // 返回预计分享菜单默认最小高度
    return 172. + [self bottomSafeHeight];
}


- (CGFloat)bottomSafeHeight {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0f) {
        if (@available(iOS 11.0, *)) {
            return [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom;
        }
    }
    return 0;
}


#pragma mark - Gesture Methods

- (void)channelSelected:(LLZShareMenuItem *)sender {
    LLZShareChannelType selectedChannel = sender.channelType;
    if(_needEventTrack){
        [LLZShareEventTracker shareMenuClickTrackWithShareChannel:selectedChannel shareContext:self.context trackStategy:self.trackStrategy];
    }
    self.stateChangedBlock(ShareChannelSelected, selectedChannel);
}


- (void)shareToChannel:(LLZShareMenuItem *)sender {
    LLZShareChannelType selectedChannel = sender.channelType;
    if(_needEventTrack){
        [LLZShareEventTracker shareMenuClickTrackWithShareChannel:selectedChannel shareContext:self.context trackStategy:self.trackStrategy];
    }
    LLZShareObject *object;
    if(self.shareObjectDictionary && self.shareObjectDictionary.count > 0){
        object = [self.shareObjectDictionary objectForKey:@(selectedChannel)];
    } else {
        object = self.shareObject;
    }
    [[LLZShareChannelManager defaultManager] shareToChannel:selectedChannel
                                           withShareObject:object
                                     currentViewController:self.currentViewController
                                          withShareContext:self.context
                                          withSuccessBlock:^(LLZShareResponseTitle title, NSString *msg) {
        if(self.successBlock){
            self.successBlock([[LLZShareChannelManager defaultManager] shareChannelStr:(selectedChannel)], title, msg);
        }
    }
                                           withCancelBlock:^(LLZShareResponseTitle title, NSString *msg) {
        if(self.cancelBlock){
            self.cancelBlock([[LLZShareChannelManager defaultManager] shareChannelStr:(selectedChannel)], title, msg);
        }
    }
                                            withErrorBlock:^(LLZShareResponseTitle title, NSError *error) {
        if(self.errorBlock){
            self.errorBlock([[LLZShareChannelManager defaultManager] shareChannelStr:(selectedChannel)], title, error);
        }
    }];
    
    [self dismissShareMenu];
}

#pragma mark - LLZShareMenuViewDelegate

- (void)shareMenuViewClickedCancel {
    if(_needEventTrack){
        [LLZShareEventTracker shareMenuCancelTrackWithShareContext:self.context trackStategy:self.trackStrategy];
    }
    if(self.stateChangedBlock){
        self.stateChangedBlock(ShareMenuCancelled, LLZShareChannelTypeNoShareChannel);
        return;
    }
    if(self.cancelBlock){
        self.cancelBlock(NoShareChannel, DefaultShareChannelTitle, @"用户关闭了分享弹窗");
    }
}

- (void)shareMenuItemDidAppear {
    _isShowingShareView = YES;
    if(_needEventTrack){
        [LLZShareEventTracker shareMenuViewTrackWithShareContext:self.context trackStategy:self.trackStrategy];
    }
}

- (void)shareMenuItemDidDisappear {
    _isShowingShareView = NO;
    if(_needEventTrack){
        [LLZShareEventTracker shareMenuViewDurationTrackWithShareContext:self.context trackStategy:self.trackStrategy];
    }
}

#pragma mark - Private Methods

- (BOOL)setUpShareItems:(NSArray*)channels {
    NSMutableArray *filteredChannels;
    NSMutableArray *tempChannels;
    if(!channels || channels.count <= 0){
        filteredChannels = [LLZShareChannelManager defaultManager].allRegisteredShareChannels.mutableCopy;
        tempChannels = filteredChannels.mutableCopy;
    } else {
        filteredChannels = [channels mutableCopy];
        tempChannels = [channels mutableCopy];
        NSArray *allRegisteredShareChannels = [LLZShareChannelManager defaultManager].allRegisteredShareChannels;
        // 过滤一遍未注册的分享平台
        for(id channel in tempChannels){
            LLZShareChannelType channelType = [channel integerValue];
            if(![allRegisteredShareChannels  containsObject:@(channelType)]){
                [filteredChannels removeObject:@(channelType)];
            }
        }
        if(filteredChannels.count <= 0){
            if (self.showFailBlock) {
                self.showFailBlock([NSError errorWithDomain:LLZShareErrorDomain code:LLZShareErrorType_NotRegistered userInfo:@{NSLocalizedDescriptionKey:@"未向相关分享平台注册app"}]);
            } else if(self.errorBlock) {
                self.errorBlock(NoShareChannel, DefaultShareChannelTitle, [NSError errorWithDomain:LLZShareErrorDomain code:LLZShareErrorType_NotRegistered userInfo:@{NSLocalizedDescriptionKey:@"未向相关分享平台注册app"}]);
            }
            return NO;
        }
        tempChannels = filteredChannels.mutableCopy;
    }
    
    // 过滤一遍未安装的分享平台
    for(id channel in tempChannels){
        LLZShareChannelType channelType = [channel integerValue];
        if(![[LLZShareChannelManager defaultManager] isInstalled:channelType]){
            [filteredChannels removeObject:@(channelType)];
        }
    }
    if(filteredChannels.count <= 0){
        if (self.showFailBlock) {
            self.showFailBlock([NSError errorWithDomain:LLZShareErrorDomain code:LLZShareErrorType_NotInstall userInfo:@{NSLocalizedDescriptionKey:@"未安装相关应用，无法分享"}]);
        } else if(self.errorBlock) {
            self.errorBlock(NoShareChannel, DefaultShareChannelTitle, [NSError errorWithDomain:LLZShareErrorDomain code:LLZShareErrorType_NotInstall userInfo:@{NSLocalizedDescriptionKey:@"未安装相关应用，无法分享"}]);
        }
        return NO;
    }
    tempChannels = filteredChannels.mutableCopy;
    
    // 过滤一遍目前不支持分享的渠道
    for(id channel in tempChannels){
        LLZShareChannelType channelType = [channel integerValue];
        if(![[LLZShareChannelManager defaultManager] isSupportSharing:channelType]){
            [filteredChannels removeObject:@(channelType)];
        }
    }
    if(filteredChannels.count <= 0){
        if (self.showFailBlock) {
            self.showFailBlock([NSError errorWithDomain:LLZShareErrorDomain code:LLZShareErrorType_NotSupport userInfo:@{NSLocalizedDescriptionKey:@"相关应用版本过低，无法分享"}]);
        } else if(self.errorBlock) {
            self.errorBlock(NoShareChannel, DefaultShareChannelTitle, [NSError errorWithDomain:LLZShareErrorDomain code:LLZShareErrorType_NotSupport userInfo:@{NSLocalizedDescriptionKey:@"相关应用版本过低，无法分享"}]);
        }
        return NO;
    }
    tempChannels = filteredChannels.mutableCopy;
    
    // 如果仅传入一个共用的shareobject，过滤一遍不支持该分享内容类型的平台
    if(self.shareObject){
        for(id channel in tempChannels){
            LLZShareChannelType channelType = [channel integerValue];
            if(![[LLZShareChannelManager defaultManager] isChannel:channelType SupportSharingWithObject:self.shareObject]){
                [filteredChannels removeObject:@(channelType)];
            }
        }
        if(filteredChannels.count <= 0){
            if (self.showFailBlock) {
                self.showFailBlock([NSError errorWithDomain:LLZShareErrorDomain code:LLZShareErrorType_NotSupport userInfo:@{NSLocalizedDescriptionKey:@"未找到当前设备支持此分享类型的平台，无法分享"}]);
            } else if(self.errorBlock) {
                self.errorBlock(NoShareChannel, DefaultShareChannelTitle, [NSError errorWithDomain:LLZShareErrorDomain code:LLZShareErrorType_NotSupport userInfo:@{NSLocalizedDescriptionKey:@"未找到当前设备支持此分享类型的平台，无法分享"}]);
            }
            return NO;
        }
    }
    
    NSArray *sortedChannels = [self sortShareChannels:filteredChannels];
    // 只显示支持分享的分享渠道在分享弹窗上
    for(id channel in sortedChannels){
        LLZShareChannelType channelType = [channel integerValue];
        LLZShareMenuItem *item = [LLZShareMenuItem itemWithShareChannelType:channelType];
        [self.shareItems addObject:item];
    }
    return YES;
}

- (NSArray *)sortShareChannels:(NSArray *)inputChannels {
    NSMutableArray *shareItems = @[].mutableCopy;
    for(id channel in self.orderedChannels){
        if([inputChannels containsObject:channel]){
            [shareItems addObject:channel];
        }
    }
    return shareItems.copy;
}

- (void)setUpShareChannelModelDict: (NSArray *)channelObjectWrappers {
    for (LLZShareChannelObjectWrapper *wrapper in channelObjectWrappers){
        [self.shareObjectDictionary setObject:wrapper.targetShareObject forKey:@(wrapper.targetShareChannel)];
    }
}

- (void)showShareMenu {
    [self.shareMenuView showShareMenu];
}

- (void)resetInfo {
    self.shareItems = @[].mutableCopy;
    self.currentViewController = nil;
    self.successBlock = nil;
    self.cancelBlock = nil;
    self.errorBlock = nil;
    self.shareObjectDictionary = @{}.mutableCopy;
    self.shareObject = nil;
    self.shareMenuView = nil;
    self.stateChangedBlock = nil;
    self.context = nil;
    self.trackStrategy = LLZShareEventTrackStrategyV1;
}

@end
