//
//  LLZShareMenuView.h
//  LLZShareLib
//
//  Created by Lizhao on 2022/10/26.
//

#import <UIKit/UIKit.h>
#import "LLZGPopupMaskView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LLZShareMenuViewDelegate <NSObject>
@optional

//分享面板的被取消的回调
- (void)shareMenuViewClickedCancel;

//分享菜单显示的回调
- (void)shareMenuItemDidAppear;

//分享菜单显示的回调
- (void)shareMenuItemDidDisappear;

@end

@class LLZShareMenuItem;
@class LLZShareUIConfig;

@interface LLZShareMenuView : LLZGPopupMaskView

@property (nonatomic, weak) id<LLZShareMenuViewDelegate> delegate;

- (instancetype)initWithConfig:(LLZShareUIConfig *)config shareMenuItems:(NSArray<LLZShareMenuItem*>*)shareMenuItems presentingVC: (UIViewController *)presentingVC;

- (instancetype)initWithConfig:(LLZShareUIConfig *)config shareMenuItems:(NSArray<LLZShareMenuItem*>*)shareMenuItems;

- (void)showShareMenu;

- (void)dismissShareView;

@end


NS_ASSUME_NONNULL_END
