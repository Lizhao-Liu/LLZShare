//
//  LLZGPopupMaskViewDelegate.h
//  Pods
//
//  Created by zhaozhao on 2024/4/8.
//

#ifndef LLZGPopupMaskViewDelegate_h
#define LLZGPopupMaskViewDelegate_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LLZGPopupMaskConfig.h"

typedef void(^popupMaskViewDismissedBlock)(void);

@protocol LLZGPopupMaskViewDelegate <NSObject>


/// 外部接收蒙版消失回调
@property (nonatomic, copy) popupMaskViewDismissedBlock dismissedBlock;
/// 外部接收蒙版出现回调
@property (nonatomic, copy) popupMaskViewDismissedBlock completionBlock;


#pragma mark - 基本能力方法

@optional

-(BOOL) isRun;

- (void)addCompletion:(void(^)(void))completion
           dismission:(void(^)(void))dismission;

-(void) show;

-(void) setMaskConfig:(LLZGPopupMaskConfig *) config;

-(LLZGPopupMaskConfig *) getMaskConfig;

-(void) initSubview;

-(UIView *) contentView;


#pragma mark - 生命周期
/**
 *  蒙板加载视图 (重载后请调用super方法)
 */
- (void)loadView;

/**
 *  蒙板将要显示时被调用
 */
- (void)maskWillAppear;

/**
 *  蒙板正在显示时被调用
 */
- (void)maskDoAppear;

/**
 *  蒙板已显示时被调用
 */
- (void)maskDidAppear;

/**
 *  蒙板将要消失时被调用
 */
- (void)maskWillDisappear;

/**
 *  蒙板正在消失时被调用
 */
- (void)maskDoDisappear;

/**
 *  蒙板已消失时被调用
 */
- (void)maskDidDisappear;

-(void) doDismiss;

/**
*  解散弹出式蒙板视图,重改结束回调
*/
- (void)doDismiss:(void(^)(void))dismission;


@end



#endif /* LLZGPopupMaskViewDelegate_h */
