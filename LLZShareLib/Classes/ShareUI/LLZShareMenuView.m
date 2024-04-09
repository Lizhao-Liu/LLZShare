//
//  LLZShareMenuView.m
//  LLZShareLib
//
//  Created by Lizhao on 2022/10/26.
//

#import "LLZShareMenuView.h"
#import "LLZShareMenuItem.h"
@import Masonry;
@import LLZShareService;

#ifndef kScreenWidth
#define kScreenWidth        CGRectGetWidth([UIScreen mainScreen].bounds)
#endif

#ifndef kScreenHeight
#define kScreenHeight       CGRectGetHeight([UIScreen mainScreen].bounds)
#endif


#define Weakify(oriInstance, weakInstance) __weak typeof(oriInstance) weakInstance = oriInstance;
#define Strongify(weakInstance, strongInstance) __strong typeof(weakInstance) strongInstance = weakInstance;

#define LLZColorHex(c) [UIColor colorWithRed:(((c) >> 16) & 0xFF) / 255.0 green:(((c) >> 8) & 0xFF) / 255.0 blue:((c)&0xFF) / 255.0 alpha:1.0]
#define LLZColorHexA(c, a) [UIColor colorWithRed:(((c) >> 16) & 0xFF) / 255.0 green:(((c) >> 8) & 0xFF) / 255.0 blue:((c)&0xFF) / 255.0 alpha:(a)]


static NSString *const kShareDefaultTitle = @"分享到";
static NSString *const kCancel = @"取消";
static NSInteger const kItemsOfOneLine = 4;

@interface LLZShareMenuView ()

@property (nonatomic, strong) UIWindow *shareWindow;

@property (nonatomic, strong) UIImageView *preview; // 图片预览视图
@property (nonatomic, strong) UIImage *preImage;  // 预览图片
@property (nonatomic, strong) NSString *preImageUrl;

@property (nonatomic, strong) UIView *topView;                 // 头部卡片视图
@property (nonatomic, strong) UIView *middleView;
@property (nonatomic, strong) UIView *shareContentView;
@property (nonatomic, strong) UIView *bottomView;                 // 底部卡片视图
@property (nonatomic, strong) UIView *bgView;


@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UIButton *linkButton;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, assign) CGFloat totalHeight;
@property (nonatomic, assign) CGFloat topViewHeight;
@property (nonatomic, assign) CGFloat middleViewHeight;
@property (nonatomic, assign) CGFloat bottomViewHeight;

@property (nonatomic, strong) LLZShareUIConfig *menuConfig;
@property (nonatomic, weak) UIViewController *presentingVC;

@end

@implementation LLZShareMenuView

- (instancetype)initWithConfig:(LLZShareUIConfig *)config shareMenuItems:(NSArray<LLZShareMenuItem*>*)shareMenuItems presentingVC: (UIViewController *)presentingVC {
    self = [super init];
    if(self){
        if(!config){
            _menuConfig = [LLZShareUIConfig defaultShareUIConfig];
        } else {
            _menuConfig = config;
        }
        _totalHeight = 0;
        _presentingVC = presentingVC;
        [self setUpTopView:_menuConfig];
        [self setUpShareItems: shareMenuItems];
        [self setUpLinkBtn:_menuConfig];
        [self setUpBottomView:_menuConfig];
        [self setUpPreviewImage: _menuConfig];
        [self.contentView setFrame:CGRectMake(0, kScreenHeight, kScreenWidth, _totalHeight)];
        
    }
    return self;
}

- (instancetype)initWithConfig:(LLZShareUIConfig *)config shareMenuItems:(NSArray<LLZShareMenuItem*>*)shareMenuItems{
    self = [super init];
    if(self){
        if(!config){
            _menuConfig = [LLZShareUIConfig defaultShareUIConfig];
        } else {
            _menuConfig = config;
        }
        _totalHeight = 0;
        [self setUpTopView:_menuConfig];
        [self setUpShareItems: shareMenuItems];
        [self setUpLinkBtn:_menuConfig];
        [self setUpBottomView:_menuConfig];
        [self setUpPreviewImage: _menuConfig];
        [self.contentView setFrame:CGRectMake(0, kScreenHeight, kScreenWidth, _totalHeight)];
        
    }
    return self;
}

#pragma mark - public methods

// 显示分享弹窗
- (void)showShareMenuWithView:(UIView *)currView{
    Weakify(self, weakSelf);
    // 背景蒙版, 这个方法内部的方法导致 color 不起作用
    [self insertSubview:self.bgView atIndex:0];
    [self showInView:currView
            offsetInsets:UIEdgeInsetsMake(-currView.frame.origin.y, 0, 0, 0)
               maskColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.30]
              completion:^{
                  [weakSelf showAnimation];
              }
              dismission:nil];
}

- (void)showShareMenuOnWindow {
    Weakify(self, weakSelf);
    [self showInView:self.shareWindow
            offsetInsets:UIEdgeInsetsMake(0, 0, 0, 0)
               maskColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.30]
              completion:^{
                  [weakSelf showAnimation];
              }
              dismission:nil];
}

- (void)showShareMenu {
    if(self.presentingVC){
        [self showShareMenuWithView:self.presentingVC.view];
    } else {
        [self showShareMenuOnWindow];
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(shareMenuItemDidAppear)]){
        [self.delegate shareMenuItemDidAppear];
    }
}

// 取消分享关闭分享弹窗
- (void)closeShareMenuView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(shareMenuViewClickedCancel)]) {
        [self.delegate shareMenuViewClickedCancel];
    }
    [self dismissShareView];
}

// 分享成功关闭分享弹窗
- (void)dismissShareView {
    [UIView animateWithDuration:0.2 animations:^{
        self.contentView.frame = CGRectMake(0, kScreenHeight, kScreenWidth,0.0);
    } completion:^(BOOL finished) {
        self.contentView.frame = CGRectMake(0, kScreenHeight, kScreenWidth,0.0);
    }];
    [self doDismiss];
    if(_shareWindow){ //释放sharewindow
        _shareWindow = nil;
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(shareMenuItemDidDisappear)]){
        [self.delegate shareMenuItemDidDisappear];
    }
}

#pragma mark - private methods
// 生成top view
- (void)setUpTopView:(LLZShareUIConfig *)config {
    CGFloat topHeight = 0;
    if (config.headerView) {
        self.topView = config.headerView;
        [self.contentView addSubview:self.topView];
        [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(0);
        }];
    } else {
        // 标题
        NSString *title = config.shareMenuTitle;
        [self.titleLabel setText:title.length > 0 ? title : kShareDefaultTitle];
        [self.topView addSubview:self.titleLabel];
        topHeight += 41;

        // 取消按钮
        self.cancelButton.frame = CGRectMake(kScreenWidth - 24. - 14., self.titleLabel.center.y - 18., 36., 36.);
        [self.topView addSubview:self.cancelButton];
        
        // 副标题
        if (config.shareMenuSubTitle && config.shareMenuSubTitle.length > 0) {
            // 距离标题间距
            topHeight += 20;
            
            CGFloat subWidth = kScreenWidth - 20.;
            CGFloat subHeight = 25.;
            NSAttributedString *attStr = [[NSAttributedString alloc] initWithString:config.shareMenuSubTitle
                                                                      attributes:@{
                                                                                   NSFontAttributeName : [UIFont systemFontOfSize:14.],
                                                                                   NSForegroundColorAttributeName :  [self colorWithHex:0x666666]
                                                                                   }];
            self.subTitleLabel.attributedText = attStr;
            CGRect rect = [attStr boundingRectWithSize:CGSizeMake(subWidth, 1000)
                                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                                context:nil];
            if (rect.size.height > 25.) {
                subHeight = rect.size.height;
            }
            self.subTitleLabel.frame = CGRectMake(10, topHeight, subWidth, subHeight);
            [self.topView addSubview:self.subTitleLabel];
            topHeight += subHeight;
        }
        self.topView.frame = CGRectMake(0, 0, kScreenWidth, topHeight);
        [self.contentView addSubview:self.topView];
    }
    
    _topViewHeight = topHeight;
    _totalHeight += topHeight;
}

// 生成分享列表
- (void)setUpShareItems:(NSArray<LLZShareMenuItem*>*)shareMenuItems{
    // 1. 确定分享渠道按钮行数
    NSInteger columns;
    NSInteger rows;
    if(shareMenuItems.count % kItemsOfOneLine == 0){
        rows = shareMenuItems.count / kItemsOfOneLine;
    } else {
        rows = shareMenuItems.count / kItemsOfOneLine + 1;
    }

    if(rows == 1){
        columns = shareMenuItems.count;
    } else {
        columns = kItemsOfOneLine;
    }
    
    // 2. 设置按钮间隔
    CGFloat horizontalSpacing = (kScreenWidth - columns * kShareItemWidth)/(columns + 1);
    CGFloat verticalSpacing = 20;
    // 分享按钮和topview间距
    CGFloat startY = (29. - kShareEdgeInsetHeight);
    
    // 3. 设置各个按钮位置
    CGFloat offsetX = horizontalSpacing;
    CGFloat offsetY = startY;
    NSInteger col = 0;
    for(NSInteger i = 0; i < shareMenuItems.count; i++) {
        if(col == kItemsOfOneLine){
            offsetY += kShareItemHeight + verticalSpacing;
            col = 0;
        }
        offsetX = col * kShareItemWidth + horizontalSpacing * (col + 1);
        LLZShareMenuItem *button = shareMenuItems[i];
        button.frame = CGRectMake(offsetX, offsetY, kShareItemWidth, kShareItemHeight);
        [self.shareContentView addSubview:button];
        col += 1;
    }
    
    // 4. 分享菜单栏高度
    CGFloat bottomSpacing = 20.0;
    CGFloat shareContentHeight = offsetY + kShareItemHeight + bottomSpacing;
    // 5. 分享菜单加入middleView
    [self.middleView addSubview:_shareContentView];
    [self.shareContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.mas_equalTo(0);
            make.height.mas_equalTo(shareContentHeight);
    }];
    _totalHeight += shareContentHeight;
}

// 生成链接跳转button
- (void)setUpLinkBtn: (LLZShareUIConfig *)config {
    CGFloat bottomSpacing;
    if(config.linkBtn && config.linkBtn.content.length > 0){
        LLZShareMenuLinkBtnModel *linkBtnModel = config.linkBtn;
        CGFloat linkBtnHeight = 25.0;
        bottomSpacing = (16. + 6.);
        [self.linkButton setTitle:linkBtnModel.content forState:UIControlStateNormal];
        [self.linkButton addTarget:self
                        action:@selector(linkEvent:)
                forControlEvents:UIControlEventTouchUpInside];
        self.linkButton.frame = CGRectMake(10., 0, kScreenWidth - 20., linkBtnHeight);
        //分享链接按钮加入middleView
        [self.middleView addSubview:self.linkButton];
        [self.linkButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(self.shareContentView.mas_bottom);
                    make.left.mas_equalTo(10);
                    make.width.mas_equalTo(kScreenWidth - 20);
                    make.height.mas_equalTo(linkBtnHeight);
        }];
        _totalHeight += linkBtnHeight;
        _totalHeight += bottomSpacing;
    } else {
        bottomSpacing = 20;
        //分享链接按钮加入middleView
        [self.middleView addSubview:self.linkButton];
        [self.linkButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(self.shareContentView).mas_offset(20);
                    make.left.right.mas_equalTo(0);
                    make.height.mas_equalTo(0);
        }];
        _totalHeight += bottomSpacing;
    }
    // 组件middle view
    [self.contentView addSubview:self.middleView];
    [self.contentView bringSubviewToFront:self.middleView];
    _middleViewHeight = _totalHeight - _topViewHeight;
    [self.middleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topView.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(_middleViewHeight);
    }];
}

- (void)setUpPreviewImage: (LLZShareUIConfig *)config {
    if(config.previewImage) {
        self.preImage = config.previewImage;
    } else if (config.preImageUrl && config.preImageUrl.length > 0) {
        self.preImageUrl = config.preImageUrl;
    }
}

// 生成bottom view
- (void)setUpBottomView: (LLZShareUIConfig *)config {
    CGFloat bottomHeight = 0;
    if(config.bottomView){
        bottomHeight += config.bottomView.frame.size.height;
        [self.bottomView addSubview:config.bottomView];
    }
    bottomHeight += [self areaBottomH];
    [self.contentView addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(bottomHeight);
        make.top.mas_equalTo(self.middleView.mas_bottom);
    }];
    _bottomViewHeight = bottomHeight;
    _totalHeight += bottomHeight;
}

#pragma mark - getters & setters

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] init];
        _topView.backgroundColor = [UIColor whiteColor];
    }
    return _topView;
}


- (UIView *)shareContentView {
    if (!_shareContentView) {
        _shareContentView = [[UIView alloc] init];
        _shareContentView.backgroundColor = [UIColor whiteColor];
    }
    return _shareContentView;
}

- (UIView *)middleView {
    if (!_middleView) {
        _middleView= [[UIView alloc] init];
        _middleView.backgroundColor = [UIColor whiteColor];
    }
    return _middleView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView= [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor whiteColor];
    }
    return _bottomView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(49., 16.0, kScreenWidth - 98., 25.0)];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setFont:[UIFont boldSystemFontOfSize:18.]];
        [_titleLabel setTextColor:[self colorWithHex:0x333333]];
    }
    return _titleLabel;
}

- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc] init];
        _subTitleLabel.numberOfLines = 0;
        [_subTitleLabel setTextAlignment:NSTextAlignmentCenter];
        [_subTitleLabel setFont:[UIFont boldSystemFontOfSize:14.]];
        [_subTitleLabel setTextColor: [self colorWithHex:0x666666]];
    }
    return _subTitleLabel;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setBackgroundColor:[UIColor whiteColor]];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"ShareUI" ofType:@"bundle"];
        UIImage *closeIcon = [UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:@"icon_share_close"]];
        [_cancelButton setImage:closeIcon forState:UIControlStateNormal];
        [_cancelButton addTarget:self
                         action:@selector(closeShareMenuView)
               forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}


- (UIButton *)linkButton {
    if (!_linkButton) {
        _linkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_linkButton setTitleColor:[self colorWithHex:0xff5b00] forState:UIControlStateNormal];
        [_linkButton setBackgroundColor:[UIColor whiteColor]];
        [_linkButton.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    }
    return _linkButton;
}

- (UIImageView *)preview {
    if (!_preview) {
        _preview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 252., 350.)];
        _preview.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _preview;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = LLZColorHexA(0x00000, 0.3);
        [self addSubview:_bgView];
        [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return _bgView;
}

// 放置视图的自定义window
- (UIWindow *)shareWindow {
    if (!_shareWindow) {
        _shareWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        _shareWindow.windowLevel = UIWindowLevelAlert;
        [_shareWindow becomeKeyWindow];
        _shareWindow.hidden = NO;
        _shareWindow.alpha = 1.0;
    }
    return _shareWindow;
}


#pragma mark - animation
// 菜单弹出动画
- (void)showAnimation {
    self.contentView.backgroundColor = [UIColor clearColor];
    [self updateTopViewConstraints];
    if(self.preImage){
        [self showPreviewImg:self.preImage];
    } else if(self.preImageUrl) {
        [self showPreviewImgUrl:self.preImageUrl];
    }
    Weakify(self, weakSelf);
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.contentView.frame = CGRectMake(0, kScreenHeight - (self.totalHeight),
                                                    kScreenWidth, self.totalHeight);
    } completion:^(BOOL finished) {
        weakSelf.contentView.frame = CGRectMake(0, kScreenHeight - (self.totalHeight),
                                                    kScreenWidth, self.totalHeight);
    }];
}

- (void)showPreviewImgUrl:(NSString *)urlString {
    if (urlString == nil) {
        return;
    }
    NSURL *imgUrl = nil;
    if ([urlString hasPrefix:@"http"] || [urlString hasPrefix:@"https"]) {
        // 网络图片
        imgUrl = [NSURL URLWithString:urlString];
        __weak typeof(self)weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:imgUrl]];
            if (img) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf showPreviewImg:img];
                });
            }
        });
    } else {
        imgUrl = [NSURL fileURLWithPath:urlString];
        UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:imgUrl]];
        [self showPreviewImg:img];
    }
}

// 预览图
- (void)showPreviewImg:(UIImage *)image {
    if (image == nil) {
        return;
    }
    CGFloat minTopVerticalSpace = 10;
    CGFloat minBottomVerticalSpace = 20;
    CGFloat minHorizontalSpace = 30;
    
    if (@available(iOS 11.0, *)) {
        minTopVerticalSpace = UIApplication.sharedApplication.keyWindow.safeAreaInsets.top + minTopVerticalSpace;
    }
    CGFloat fixelW = CGImageGetWidth(image.CGImage)/image.scale;
    CGFloat fixelH = CGImageGetHeight(image.CGImage)/image.scale;
    
    CGFloat canWidth = kScreenWidth - 2 * minHorizontalSpace;
    CGFloat canHeight = kScreenHeight - self.totalHeight - minTopVerticalSpace - minBottomVerticalSpace;
    
    CGFloat showWidth = fixelW;
    CGFloat showHeight = fixelH;
    
    BOOL isVer = YES;
    if (fixelW > canWidth || fixelH > canHeight) {
        CGFloat wScale = canWidth / fixelW;
        CGFloat hScale = canHeight / fixelH;
        CGFloat scale = wScale < hScale ? wScale : hScale;
        isVer = (hScale <= wScale);
        showWidth = fixelW * scale;
        showHeight = fixelH * scale;
    } else {
        isVer = NO;
    }
    
    if (isVer) {
        // 如果以高比例为准，则y坐标为minTopVerticalSpace
        self.preview.frame = CGRectMake((kScreenWidth - showWidth)/2, -(kScreenHeight - self.totalHeight) + minTopVerticalSpace, showWidth, showHeight);
    } else {
        // 如果以宽比例为准，则y方向剧中
        self.preview.frame = CGRectMake((kScreenWidth - showWidth)/2, -(kScreenHeight - self.totalHeight) + ((kScreenHeight - self.totalHeight) - showHeight)/2, showWidth, showHeight);
    }

    self.preview.image = image;
    [self.contentView addSubview:self.preview];
}

- (void)updateTopViewConstraints {
    [self.topView setNeedsUpdateConstraints];
    [self.topView updateConstraintsIfNeeded];
    [self.topView layoutIfNeeded];
    CGFloat topHeight = self.topView.frame.size.height;
    if(self.topViewHeight != topHeight){
        self.topViewHeight = topHeight;
        self.totalHeight = self.topViewHeight + self.middleViewHeight + self.bottomViewHeight;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // 圆角
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.topView.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(8,8)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];

    maskLayer.frame = self.topView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.topView.layer.mask = maskLayer;
    
}

#pragma mark - gesture methods

- (void)linkEvent:(id)sender {
// 抛出自定义响应事件
    
    [self dismissShareView];
}

#pragma mark - UIResponder Method
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGPoint convertPoint = [self.topView convertPoint:point fromView:self];
    if (convertPoint.y <= 0) {
        [self closeShareMenuView];
    }
}

#pragma mark - utility methods

- (CGFloat)areaBottomH {
    if(self.presentingVC){ //显示在vc上
        if (@available(iOS 11.0, *)) {
            return self.presentingVC.view.safeAreaInsets.bottom;
        } else {
            return 0;
        }
    } else { //显示在window上
        return [self bottomSafeHeight];
    }
}

- (CGFloat)bottomSafeHeight {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0f) {
        if (@available(iOS 11.0, *)) {
            return [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom;
        }
    }
    return 0;
}

- (UIColor *)colorWithHex:(NSInteger)hexValue {
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
                           green:((float)((hexValue & 0xFF00) >> 8))/255.0
                            blue:((float)(hexValue & 0xFF))/255.0 alpha:1.0];
}

@end
