//
//  LLZGPopupMaskConfig.h
//  Pods
//
//  Created by zhaozhao on 2024/4/8.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef void(^LLZGPopupCompletionBlock)(void);

@interface LLZGPopupMaskConfig : NSObject

@property (nonatomic, strong) UIColor *maskColor;//蒙层背景

@property (nonatomic, strong) UIView *superView;//创建在view上

@property (nonatomic) UIEdgeInsets offsetInsets;

/**
 *  是否点击即消失,默认是NO
 */
@property (nonatomic) BOOL tapToDismiss;

/**
 *  动画持续时间
 */
@property (nonatomic)CGFloat animationDuration;

@property (copy, nonatomic) LLZGPopupCompletionBlock completion;
@property (copy, nonatomic) LLZGPopupCompletionBlock dismiss;

@property (nonatomic, assign)NSInteger  subIndex;//处于父视图的层级:从1计数

@property (class, strong, readonly) UIColor *mainTint; // alert 弹窗的主题色

@end


