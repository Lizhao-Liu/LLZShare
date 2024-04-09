//
//  LLZGPopupMaskView.h
//  LLZShareLib-ShareUI
//
//  Created by zhaozhao on 2024/4/8.
//

#import <UIKit/UIKit.h>
#import "LLZGPopupMaskConfig.h"
#import "LLZGPopupMaskViewDelegate.h"


typedef void(^DismissCallback)(void);

@interface LLZGPopupMaskView : UIView <LLZGPopupMaskViewDelegate>

@property (nonatomic) BOOL tapToDismiss;
@property (nonatomic) BOOL ignoreHitTest;// 默认false，若为true，则透传用户事件
@property (nonatomic) CGFloat animationDuration;


/**
 *  内容容器视图 （请勿直接将subviews添加在PopupMaskView上，添加到contentView）
 */
@property (nonatomic, strong)UIView *contentView;

/**
 *  显示弹出式蒙板视图
 *
 *  @param view     弹出的父视图
 *  @param offsetInsets 偏移边距
 *  @param maskColor    蒙板颜色
 *  @param completion   显示完成Block
 *  @param dismission   消失完成Block
 */
- (void)showInView:(UIView *)view
          offsetInsets:(UIEdgeInsets)offsetInsets
             maskColor:(UIColor *)maskColor
            completion:(void(^)(void))completion
            dismission:(void(^)(void))dismission;

@end

