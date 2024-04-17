//
//  LLZShareDebugViewController.m
//  LLZShareModule
//
//  Created by Lizhao on 2022/11/9.
//

#import "LLZShareMenuDemoViewController.h"
#import "LLZShareDebugViewCell.h"
@import LLZShareService;
@import LLZShareLib;

#define Scale(x) (x*UIScreen.mainScreen.bounds.size.width/375.f)
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

@interface LLZShareMenuDemoViewController () <UICollectionViewDelegate,UICollectionViewDataSource,UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate>
@property (nonatomic, strong, nullable) UICollectionView *collectionView;
@property (nonatomic, strong, nullable) NSArray *datas;

@property (strong, nonatomic) LLZShareObject *selectedShareObject;

@property (strong, nonatomic) LLZShareImageObject *imageModel;
@property (strong, nonatomic) LLZShareMessageObject *messageModel;
@property (strong, nonatomic) LLZShareVideoObject *videoModel;
@property (strong, nonatomic) LLZShareWebpageObject *webpageModel;
@property (strong, nonatomic) LLZShareMiniProgramObject *miniAppModel;
@property (strong, nonatomic) LLZShareAutoTypeObject *autoModel;

@property (strong, nonatomic) LLZShareContextModel *testContext;

@end

@implementation LLZShareMenuDemoViewController

- (void)viewWillAppear:(BOOL)animated{
//    [self someTests];
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = false;
    self.navigationController.navigationBar.translucent = false;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)someTests {

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpModels];
    [self initView];
}

- (void)initView{
    self.title = @"分享内容";
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];

    self.view.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    
    UILabel *desLabel = [[UILabel alloc] init];
    desLabel.frame = CGRectMake(Scale(0),Scale(1),SCREEN_WIDTH,Scale(60));
    desLabel.text = @"    请选择需要分享的类别";
    desLabel.textColor = [UIColor colorWithRed:55/255.0 green:67/255.0 blue:92/255.0 alpha:1.0];
    desLabel.font = [UIFont systemFontOfSize:14.0];
    desLabel.numberOfLines = 0;
    desLabel.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:desLabel];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    //设置CollectionView的属性
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, Scale(46), self.view.bounds.size.width, self.view.bounds.size.height - Scale(46)) collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.scrollEnabled = YES;
    [self.view addSubview:self.collectionView];
    
    //注册Cell
    [self.collectionView registerClass:[LLZShareDebugViewCell class] forCellWithReuseIdentifier:@"shareCell"];
    
    //初始化数据
    self.datas = @[
        @{
            @"title": @"纯文本",
            @"image": @"text",
        },
        @{
            @"title": @"本地图片",
            @"image": @"localimage",
        },
        @{
            @"title": @"视频",
            @"image": @"video",
        },
        @{
            @"title": @"链接",
            @"image": @"link",
        },
        @{
            @"title": @"小程序分享",
            @"image": @"minappshare",
        },
        @{
            @"title": @"AutoType",
            @"image": @"question",
        },
    ];
}

#pragma mark  设置CollectionView的组数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

#pragma mark  设置CollectionView每组所包含的个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.datas.count;
}

#pragma mark  设置CollectionCell的内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"shareCell";
    LLZShareDebugViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    NSDictionary *content = self.datas[indexPath.row];
    cell.icon.image = [UIImage imageNamed:content[@"image"]];
    cell.label.text = content[@"title"];
    
    [cell updateLineWithCellIndex:indexPath.row%3];

    if (indexPath.row/3 >= 2) {
        [cell hiddeBottomLine:YES];
    }
    
    return cell;
}

#pragma mark  定义每个UICollectionView的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return  CGSizeMake(SCREEN_WIDTH/3,SCREEN_WIDTH/3);
}


#pragma mark  定义每个UICollectionView的横向间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return Scale(0.0);
}

#pragma mark  定义每个UICollectionView的纵向间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return Scale(0);
}

#pragma mark  点击CollectionView触发事件
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LLZShareObject *targetObject;
    switch (indexPath.row) {
        case 0:
            targetObject = self.messageModel;
            break;
        case 1:
            targetObject = self.imageModel;
            break;
        case 2:
            targetObject = self.videoModel;
            break;
        case 3:
            targetObject = self.webpageModel;
            break;
        case 4:
            targetObject = self.miniAppModel;
            break;
        case 5:
            targetObject = self.autoModel;
        default:
            break;
    }
    [self showShareMenuWithPreparedObject: targetObject];
}

- (void)showShareMenuWithPreparedObject: (LLZShareObject *)object {
    
//    //1. 测试分段式分享
//    [LLZShareManager showShareMenuViewWithShareChannels:nil
//                                     withConfiguration:nil
//                                    withViewController:self
//                                      withShareContext:self.testContext
//                                 withShowMenuFailBlock:^(NSError * _Nonnull error) {
//        [self showAlertWithTitle:@"分享失败" withMessage:error.localizedDescription];
//    }
//                                withStateChangedBlock:^(LLZShareMenuState state, LLZShareChannelType selectedChannel) {
//        if(state == ShareMenuCancelled){
//            // 用户点击了关闭
//            [self showAlertWithTitle:@"取消分享" withMessage:@"分享弹窗被取消"];
//        } else {
//            // 用户选择了分享渠道
//            NSLog(@"%lu", (unsigned long)selectedChannel);
//            // 执行分享行为
//            [LLZShareManager shareToChannel:selectedChannel
//                           withShareObject:object
//                     currentViewController:nil
//                          withShareContext:self.testContext
//                          withSuccessBlock:^(NSString * _Nonnull title, NSString * _Nonnull msg) {
//                [self showAlertWithTitle: title withMessage:msg];
//            }
//                           withCancelBlock:^(NSString * _Nonnull title, NSString * _Nonnull msg) {
//                [self showAlertWithTitle: title withMessage:msg];
//            }
//                            withErrorBlock:^(NSString * _Nonnull title, NSError * _Nonnull error) {
//                [self showAlertWithTitle: title withMessage:error.localizedDescription];
//            }];
//            // 关闭分享弹窗
//            [LLZShareManager dismissShareMenu];
//        }
//    }];
    
//    2. 测试一步分享 不同分享渠道分享同样内容
    LLZShareUIConfig *config = [[LLZShareUIConfig alloc] init];
//    config.preImageUrl = @"https://upload-images.jianshu.io/upload_images/5809200-c12521fbde6c705b.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240";
    [LLZShareManager shareToChannels:nil
                    withShareObject:object
                  withConfiguration:config
                 withViewController:self
                   withShareContext:self.testContext
                   withSuccessBlock:^(LLZShareResponseChannelStr  _Nonnull selectedChannelTypeStr, LLZShareResponseTitle  _Nonnull title, NSString * _Nonnull msg) {
        [self showAlertWithTitle: title withMessage:msg];
    }
                    withCancelBlock:^(LLZShareResponseChannelStr  _Nonnull selectedChannelTypeStr, LLZShareResponseTitle  _Nonnull title, NSString * _Nonnull msg) {
        [self showAlertWithTitle: title withMessage:msg];
    }
                     withErrorBlock:^(LLZShareResponseChannelStr  _Nonnull selectedChannelTypeStr, LLZShareResponseTitle  _Nonnull title, NSError * _Nonnull error) {
        [self showAlertWithTitle: title withMessage:error.localizedDescription];
    }];
    
//    3. 测试一步分享，不同分享渠道分享不同内容
//    LLZShareChannelObjectWrapper *ks = [LLZShareChannelObjectWrapper shareWrapperWithChannel:LLZShareChannelTypeKS shareObject:self.videoModel];
//    LLZShareChannelObjectWrapper *wechat = [LLZShareChannelObjectWrapper shareWrapperWithChannel:LLZShareChannelTypeWechatSession shareObject:self.miniAppModel];
//    LLZShareChannelObjectWrapper *wechatTimeline = [LLZShareChannelObjectWrapper shareWrapperWithChannel:LLZShareChannelTypeWechatTimeline shareObject:self.messageModel];
//    LLZShareChannelObjectWrapper *qq = [LLZShareChannelObjectWrapper shareWrapperWithChannel:LLZShareChannelTypeQQ shareObject:self.imageModel];
//    LLZShareChannelObjectWrapper *qqZone = [LLZShareChannelObjectWrapper shareWrapperWithChannel:LLZShareChannelTypeQzone shareObject:self.messageModel];
//    LLZShareChannelObjectWrapper *dy = [LLZShareChannelObjectWrapper shareWrapperWithChannel:LLZShareChannelTypeDY shareObject:self.videoModel];
//    LLZShareChannelObjectWrapper *motorcade = [LLZShareChannelObjectWrapper shareWrapperWithChannel:LLZShareChannelTypeMotorcade shareObject:self.webpageModel];
//    LLZShareUIConfig *config = [[LLZShareUIConfig alloc] init];
//    config.preImageUrl = @"https://upload-images.jianshu.io/upload_images/5809200-c12521fbde6c705b.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240";
//    config.headerView =  [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 50)];
//    config.headerView.backgroundColor = [UIColor redColor];
//    config.bottomView =  [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 50)];
//    config.bottomView.backgroundColor = [UIColor blackColor];
//    [LLZShareManager shareWithChannelObjectWrappers:@[ks, wechat, wechatTimeline, qq, qqZone, dy, motorcade]
//                                 withConfiguration:config
//                                withViewController:self
//                                  withShareContext:self.testContext
//                                  withSuccessBlock:^(LLZShareResponseChannelStr  _Nonnull selectedChannelTypeStr, LLZShareResponseTitle  _Nonnull title, NSString * _Nonnull msg) {
//        [self showAlertWithTitle: title withMessage:msg];
//    }
//                                   withCancelBlock:^(LLZShareResponseChannelStr  _Nonnull selectedChannelTypeStr, LLZShareResponseTitle  _Nonnull title, NSString * _Nonnull msg) {
//        [self showAlertWithTitle: title withMessage:msg];
//    }
//                                    withErrorBlock:^(LLZShareResponseChannelStr  _Nonnull selectedChannelTypeStr, LLZShareResponseTitle  _Nonnull title, NSError * _Nonnull error) {
//        [self showAlertWithTitle: title withMessage:error.localizedDescription];
//    }];
}


- (void)showAlertWithTitle:(NSString *)title withMessage:(NSString *)msg {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:cancel];
    [[UIViewController currentViewController] presentViewController:alert animated:YES completion:nil];
}

- (void)setUpModels {
    _imageModel = [[LLZShareImageObject alloc] init];
    _imageModel.shareTitle = @"图片分享";
    _imageModel.shareImage = [UIImage imageNamed: @"AppIcon"];
    _imageModel.shareImageUrl = @"https://upload-images.jianshu.io/upload_images/5809200-a99419bb94924e6d.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240";
    
    
    _messageModel = [[LLZShareMessageObject alloc] init];
    _messageModel.shareContent = @"test content";
    _messageModel.shareTitle = @"文字分享";
    
    
    _videoModel = [[LLZShareVideoObject alloc] init];
    _videoModel.shareTitle = @"视频保存";
    _videoModel.downloadUrl = @"https://ymm-maliang.oss-cn-hangzhou.aliyuncs.com/ymm-maliang/access/ymm1633921710166c44250.mp4";
    _videoModel.fileSize = @"18";
    _videoModel.successActionUrl = @"https://static.ymm56.com/microweb/vue.html#/mw-tview/index?key=ed3E27E815";
    _videoModel.failActionUrl = @"https://static.ymm56.com/microweb/vue.html#/mw-tview/index?key=ed3E27E815";
    
    _miniAppModel = [[LLZShareMiniProgramObject alloc] init];
    _miniAppModel.userName = @"gh_54e9dea35b85";
    
    
    _webpageModel = [[LLZShareWebpageObject alloc] init];
    _webpageModel.webpageUrl = @"https://home.amh-group.com/#/home";
    _webpageModel.shareTitle = @"链接分享";
    
    _testContext = [[LLZShareContextModel alloc] init];
    _testContext.shareSceneName = @"testLLZShareLib";
    
    _miniAppModel.userName = @"gh_54e9dea35b85";
    _miniAppModel.hdImage = [UIImage imageNamed: @"AppIcon"];
    
    _autoModel = [[LLZShareAutoTypeObject alloc] init];
    _autoModel.shareContent = @"test content";
    _autoModel.shareImageUrl =@"https://upload-images.jianshu.io/upload_images/5809200-a99419bb94924e6d.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240";
    _autoModel.sharePageUrl = @"https://www.jianshu.com/p/970e6dae641f";
    _autoModel.shareImage = [UIImage imageNamed: @"AppIcon"];
    _autoModel.userName = @"gh_54e9dea35b85";
//    _autoModel.miniAppImage = [UIImage imageNamed: @"AppIcon"];
    _autoModel.downloadUrl = @"https://ymm-maliang.oss-cn-hangzhou.aliyuncs.com/ymm-maliang/access/ymm1633921710166c44250.mp4";
    _autoModel.successActionUrl = @"https://static.ymm56.com/microweb/vue.html#/mw-tview/index?key=ed3E27E815";
    _autoModel.failActionUrl = @"https://static.ymm56.com/microweb/vue.html#/mw-tview/index?key=ed3E27E815";
    _autoModel.fileSize = @"18";
    _autoModel.shareTitle = @"test share";
}

#pragma mark  设置CollectionViewCell是否可以被点击
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
@end
