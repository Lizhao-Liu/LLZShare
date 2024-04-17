//
//  LLZShareDirectDebugViewController.m
//  LLZShareDebug
//
//  Created by Lizhao on 2022/11/11.
//

#import "LLZShareDirectViewController.h"
@import LLZShareLib;
@import Masonry;
@import YYModel;

@interface LLZShareDirectViewController ()
@property (strong, nonatomic) LLZShareImageObject *imageModel;
@property (strong, nonatomic) LLZShareMessageObject *messageModel;
@property (strong, nonatomic) LLZShareVideoObject *videoModel;
@property (strong, nonatomic) LLZShareWebpageObject *webpageModel;
@property (strong, nonatomic) LLZShareMiniProgramObject *miniAppModel;
@property (strong, nonatomic) LLZShareAutoTypeObject *autoModel;

@end

@implementation LLZShareDirectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpBtns];
    
    [self setUpModels];
}

- (void)setUpBtns {
    UIButton *wxbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    wxbtn.backgroundColor = [UIColor whiteColor];
    [wxbtn setTitle:@"分享给微信" forState:UIControlStateNormal];
    [wxbtn setTitleColor: self.view.tintColor forState:UIControlStateNormal];
    [wxbtn addTarget:self action:@selector(shareToWechat) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:wxbtn];
    
    [wxbtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(100);
        make.left.mas_equalTo(20);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(40);
    }];
    
    UIButton *qqbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    qqbtn.backgroundColor = [UIColor whiteColor];
    [qqbtn setTitle:@"分享给qq" forState:UIControlStateNormal];
    [qqbtn setTitleColor: self.view.tintColor forState:UIControlStateNormal];
    [qqbtn addTarget:self action:@selector(shareToQQ) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:qqbtn];
    
    [qqbtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(150);
        make.left.mas_equalTo(20);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(40);
    }];
    
    
    UIButton *ksbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    ksbtn.backgroundColor = [UIColor whiteColor];
    [ksbtn setTitle:@"分享给快手" forState:UIControlStateNormal];
    [ksbtn setTitleColor: self.view.tintColor forState:UIControlStateNormal];
    [ksbtn addTarget:self action:@selector(shareToKS) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:ksbtn];
    
    [ksbtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(200);
        make.left.mas_equalTo(20);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(40);
    }];
    
    UIButton *dybtn = [UIButton buttonWithType:UIButtonTypeCustom];
    dybtn.backgroundColor = [UIColor whiteColor];
    [dybtn setTitle:@"分享给抖音" forState:UIControlStateNormal];
    [dybtn setTitleColor: self.view.tintColor forState:UIControlStateNormal];
    [dybtn addTarget:self action:@selector(shareToDY) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dybtn];
    
    [dybtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(250);
        make.left.mas_equalTo(20);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(40);
    }];
    
    
    UIButton *phonebtn = [UIButton buttonWithType:UIButtonTypeCustom];
    phonebtn.backgroundColor = [UIColor whiteColor];
    [phonebtn setTitle:@"电话分享" forState:UIControlStateNormal];
    [phonebtn setTitleColor: self.view.tintColor forState:UIControlStateNormal];
    [phonebtn addTarget:self action:@selector(shareToPHONE) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:phonebtn];
    [phonebtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(300);
        make.left.mas_equalTo(20);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(40);
    }];
    
    
    UIButton *smsbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    smsbtn.backgroundColor = [UIColor whiteColor];
    [smsbtn setTitle:@"短信分享" forState:UIControlStateNormal];
    [smsbtn setTitleColor: self.view.tintColor forState:UIControlStateNormal];
    [smsbtn addTarget:self action:@selector(shareToSMS) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:smsbtn];
    [smsbtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(350);
        make.left.mas_equalTo(20);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(40);
    }];
    
    UIButton *saveimagebtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveimagebtn.backgroundColor = [UIColor whiteColor];
    [saveimagebtn setTitle:@"保存图片" forState:UIControlStateNormal];
    [saveimagebtn setTitleColor: self.view.tintColor forState:UIControlStateNormal];
    [saveimagebtn addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveimagebtn];
    [saveimagebtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(400);
        make.left.mas_equalTo(20);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(40);
    }];
    
    UIButton *savevideobtn = [UIButton buttonWithType:UIButtonTypeCustom];
    savevideobtn.backgroundColor = [UIColor whiteColor];
    [savevideobtn setTitle:@"保存视频" forState:UIControlStateNormal];
    [savevideobtn setTitleColor: self.view.tintColor forState:UIControlStateNormal];
    [savevideobtn addTarget:self action:@selector(saveVideo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:savevideobtn];
    [savevideobtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(450);
        make.left.mas_equalTo(20);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(40);
    }];
}

- (void)setUpModels {
    _imageModel = [[LLZShareImageObject alloc] init];
    _imageModel.shareTitle = @"图片分享";
//    _imageModel.shareImageUrl = @"https://en.wikipedia.org/wiki/Image#/media/File:Image_created_with_a_mobile_phone.png";
    _imageModel.shareImageUrl = @"https://i.stack.imgur.com/KKhcS.png";
    _imageModel.shareImageUrl = @"https://img1.baidu.com/it/u=3009731526,373851691&fm=253&fmt=auto&app=138&f=JPEG?w=800&h=500";
//    _imageModel.shareImageUrl = @"http://download.sdk.mob.com/web/images/2019/06/20/10/1560998253715/635_635_42.62.png";
    
    
    LLZShareMessageObject *messageObj = [[LLZShareMessageObject alloc] init];
    messageObj.shareContent = @"test";
    
    LLZShareImageObject *imageObj = [[LLZShareImageObject alloc] init];
    imageObj.shareImage = [UIImage imageNamed:@"shareImage.png"];
    imageObj.shareTitle = @"share image";
    imageObj.shareContent = @"test share image with LLZShareLib";
    
    _messageModel = [[LLZShareMessageObject alloc] init];
    _messageModel.shareContent = @"test content";
    
    
    _videoModel = [[LLZShareVideoObject alloc] init];
    _videoModel.shareTitle = @"视频保存";
    _videoModel.downloadUrl = @"https://ymm-maliang.oss-cn-hangzhou.aliyuncs.com/ymm-maliang/access/ymm1633921710166c44250.mp4";
    _videoModel.fileSize = @"18";
    _videoModel.successActionUrl = @"https://static.ymm56.com/microweb/vue.html#/mw-tview/index?key=ed3E27E815";
    _videoModel.failActionUrl = @"https://static.ymm56.com/microweb/vue.html#/mw-tview/index?key=ed3E27E815";
    
    _miniAppModel = [[LLZShareMiniProgramObject alloc] init];
    _miniAppModel.userName = @"gh_54e9dea35b85";
}


- (void)shareToWechat{
    [LLZShareManager shareToChannel:LLZShareChannelTypeWechatSession withShareObject:self.miniAppModel currentViewController:self withShareContext:[[LLZShareContextModel alloc] init] withSuccessBlock:^(LLZShareResponseTitle title, NSString * _Nonnull msg) {
        [self showAlertWithTitle: title withMessage:msg];
    } withCancelBlock:^(LLZShareResponseTitle title, NSString * _Nonnull msg) {
        [self showAlertWithTitle: title withMessage:msg];
    } withErrorBlock:^(LLZShareResponseTitle title, NSError * _Nonnull error) {
        [self showAlertWithTitle: title withMessage:error.localizedDescription];
    }];

}

- (void)shareToQQ{
    [LLZShareManager shareToChannel:LLZShareChannelTypeQQ withShareObject:self.imageModel currentViewController:self withShareContext:[[LLZShareContextModel alloc] init] withSuccessBlock:^(LLZShareResponseTitle title, NSString * _Nonnull msg) {
        [self showAlertWithTitle: title withMessage:msg];
    } withCancelBlock:^(LLZShareResponseTitle title, NSString * _Nonnull msg) {
        [self showAlertWithTitle: title withMessage:msg];
    } withErrorBlock:^(LLZShareResponseTitle title, NSError * _Nonnull error) {
        [self showAlertWithTitle: title withMessage:error.localizedDescription];
    }];
}

- (void)shareToKS{
    [LLZShareManager shareToChannel:LLZShareChannelTypeKS withShareObject:self.videoModel currentViewController:self withShareContext:[[LLZShareContextModel alloc] init] withSuccessBlock:^(LLZShareResponseTitle title, NSString * _Nonnull msg) {
        [self showAlertWithTitle: title withMessage:msg];
    } withCancelBlock:^(LLZShareResponseTitle title, NSString * _Nonnull msg) {
        [self showAlertWithTitle: title withMessage:msg];
    } withErrorBlock:^(LLZShareResponseTitle title, NSError * _Nonnull error) {
        [self showAlertWithTitle: title withMessage:error.localizedDescription];
    }];
}

- (void)shareToDY{
    [LLZShareManager shareToChannel:LLZShareChannelTypeDY withShareObject:self.videoModel currentViewController:self withShareContext:[[LLZShareContextModel alloc] init] withSuccessBlock:^(LLZShareResponseTitle title, NSString * _Nonnull msg) {
        [self showAlertWithTitle: title withMessage:msg];
    } withCancelBlock:^(LLZShareResponseTitle title, NSString * _Nonnull msg) {
        [self showAlertWithTitle: title withMessage:msg];
    } withErrorBlock:^(LLZShareResponseTitle title, NSError * _Nonnull error) {
        [self showAlertWithTitle: title withMessage:error.localizedDescription];
    }];
}

- (void)shareToSMS{
    NSDictionary *json = [self.messageModel yy_modelToJSONObject];
    NSLog(@"%@", json);
    [LLZShareManager shareToChannel:LLZShareChannelTypeSMS withShareObject:self.messageModel currentViewController:self withShareContext:[[LLZShareContextModel alloc] init] withSuccessBlock:^(LLZShareResponseTitle title, NSString * _Nonnull msg) {
        [self showAlertWithTitle: title withMessage:msg];
    } withCancelBlock:^(LLZShareResponseTitle title, NSString * _Nonnull msg) {
        [self showAlertWithTitle: title withMessage:msg];
    } withErrorBlock:^(LLZShareResponseTitle title, NSError * _Nonnull error) {
        [self showAlertWithTitle: title withMessage:error.localizedDescription];
    }];
}

- (void)shareToPHONE {
    [LLZShareManager shareToChannel:LLZShareChannelTypePhone withShareObject:nil currentViewController:self withShareContext:[[LLZShareContextModel alloc] init] withSuccessBlock:^(LLZShareResponseTitle title, NSString * _Nonnull msg) {
        [self showAlertWithTitle: title withMessage:msg];
    } withCancelBlock:^(LLZShareResponseTitle title, NSString * _Nonnull msg) {
        [self showAlertWithTitle: title withMessage:msg];
    } withErrorBlock:^(LLZShareResponseTitle title, NSError * _Nonnull error) {
        [self showAlertWithTitle: title withMessage:error.localizedDescription];
    }];
}

- (void)saveImage {
    [LLZShareManager shareToChannel:LLZShareChannelTypeSaveImage withShareObject:self.imageModel currentViewController:self withShareContext:[[LLZShareContextModel alloc] init] withSuccessBlock:^(LLZShareResponseTitle title, NSString * _Nonnull msg) {
        [self showAlertWithTitle: title withMessage:msg];
    } withCancelBlock:^(LLZShareResponseTitle title, NSString * _Nonnull msg) {
        [self showAlertWithTitle: title withMessage:msg];
    } withErrorBlock:^(LLZShareResponseTitle title, NSError * _Nonnull error) {
        [self showAlertWithTitle: title withMessage:error.localizedDescription];
    }];
}

- (void)saveVideo{
    [LLZShareManager shareToChannel:LLZShareChannelTypeSaveVideo withShareObject:self.videoModel currentViewController:self withShareContext:[[LLZShareContextModel alloc] init] withSuccessBlock:^(LLZShareResponseTitle title, NSString * _Nonnull msg) {
        [self showAlertWithTitle: title withMessage:msg];
    } withCancelBlock:^(LLZShareResponseTitle title, NSString * _Nonnull msg) {
        [self showAlertWithTitle: title withMessage:msg];
    } withErrorBlock:^(LLZShareResponseTitle title, NSError * _Nonnull error) {
        [self showAlertWithTitle: title withMessage:error.localizedDescription];
    }];
}

- (void)showAlertWithTitle:(NSString *)title withMessage:(NSString *)msg {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:cancel];
    [[UIViewController currentViewController] presentViewController:alert animated:YES completion:nil];
}


@end

