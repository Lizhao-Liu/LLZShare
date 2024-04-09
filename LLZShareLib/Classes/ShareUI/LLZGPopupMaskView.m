//
//  LLZGPopupMaskView.m
//  LLZShareLib-ShareUI
//
//  Created by zhaozhao on 2024/4/8.
//


#import "LLZGPopupMaskView.h"

@interface LLZGPopupMaskView () {
    //是否已移除
    BOOL isDismissed;
    
    dispatch_once_t loadOnceToken;
}

@property (nonatomic, copy) void(^dismission)(void);

@property (nonatomic, strong) LLZGPopupMaskConfig *config;
@property (nonatomic) BOOL runStatus;

@property (nonatomic, assign) long long showInteval;

@end

@implementation LLZGPopupMaskView
@synthesize dismissedBlock;
@synthesize completionBlock;

#pragma mark - Get Set Property

-(long long)getDateTimeTOMilliSeconds:(NSDate *)datetime
{
    NSTimeInterval interval = [datetime timeIntervalSince1970];
    
    return interval*1000;
}

-(void) setMaskConfig:(LLZGPopupMaskConfig *)config
{
    self.config = config;
}

-(LLZGPopupMaskConfig *) getMaskConfig
{
    return self.config;
}

-(LLZGPopupMaskConfig *) config
{
    if(!_config) {
        _config = [LLZGPopupMaskConfig new];
    }
    return _config;
}

-(CGFloat) animationDuration
{
    return self.config.animationDuration;
}

-(void) setAnimationDuration:(CGFloat)animationDuration
{
    self.config.animationDuration = animationDuration;
}

-(void) setTapToDismiss:(BOOL)tapToDismiss
{
    self.config.tapToDismiss = tapToDismiss;
}

-(BOOL) tapToDismiss
{
    return self.config.tapToDismiss;
}

#pragma mark UIResponder Methods

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    if (self.config.tapToDismiss) {
        [self doDismiss];
    }
}

#pragma mark Base Methods

- (void)loadView {
    // do noting in base
}

- (void)maskWillAppear {
    // do noting in base
}

- (void)maskDoAppear {
    // do noting in base
}

- (void)maskDidAppear {
    // do noting in base
    if (self.completionBlock) {
        self.completionBlock();
    }
}

- (void)maskWillDisappear {
    // do noting in base
}

- (void)maskDoDisappear {
    // do noting in base
    
}

- (void)maskDidDisappear {
    // do noting in base
    if (self.dismissedBlock) {
        self.dismissedBlock();
    }
}

#pragma mark Property Methods

- (UIView *)contentView {
    
    if (!_contentView) {
        _contentView = [[UIView alloc]init];
        _contentView.frame = self.bounds;
        [self addSubview:_contentView];
    }
    
    return _contentView;
}


#pragma mark Inerface Methods

- (void)showInView:(UIView *)view
          offsetInsets:(UIEdgeInsets)offsetInsets
             maskColor:(UIColor *)maskColor
            completion:(void(^)(void))completion
            dismission:(void(^)(void))dismission {
    
    isDismissed = NO;
    
    self.dismission = dismission;
    
    UIView *currentView = view;
    
    NSArray *tipsAlerts = currentView.subviews;
    BOOL hasTipsAlert = NO;
    for (UIView *subview in tipsAlerts) {
        if ([subview isKindOfClass:[view class]]) {
            
            hasTipsAlert = YES;
            break;
        }
    }
    
    CGRect frame = currentView.bounds;
    frame.origin.x += offsetInsets.left;
    frame.origin.y += offsetInsets.top;
    frame.size.width -= offsetInsets.left+offsetInsets.right;
    frame.size.height -= offsetInsets.top+offsetInsets.bottom;
    
    self.backgroundColor = [UIColor clearColor];
    self.frame = frame;
    self.clipsToBounds = YES;
    if (self.config.subIndex > 0) {
        [currentView insertSubview:self atIndex:self.config.subIndex - 1];
    }else{
        [currentView addSubview:self];
    }
    
    dispatch_once(&loadOnceToken, ^{
        [self loadView];
    });
    
    [self maskWillAppear];
    [self maskDoAppear];
    if (hasTipsAlert == NO) {
        self.backgroundColor = maskColor;
    }
    self.contentView.alpha = 1.f;
    
    [self maskDidAppear];
    self.showInteval = [self getDateTimeTOMilliSeconds:[NSDate date]];
    if (completion) {
        completion();
    }
}

-(void) doDismiss:(void (^)(void))dismission
{
    self.dismission =  dismission;
    [self doDismiss];
}

- (void)doDismiss {
    if (isDismissed) {
        return;
    }
    isDismissed = YES;
    
    [self maskWillDisappear];

    [self maskDoDisappear];
    
    [self removeFromSuperview];
        
    if (self.dismission) {
        self.dismission();
    }
    [self maskDidDisappear];
}


-(void) show
{
    LLZGPopupMaskConfig *config = self.config;
    [self showInView:config.superView
            offsetInsets:config.offsetInsets
               maskColor:config.maskColor
              completion:config.completion
              dismission:config.dismiss];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.ignoreHitTest) {
        return nil;
    } else {
        return [super hitTest:point withEvent:event];
    }
}

@end
