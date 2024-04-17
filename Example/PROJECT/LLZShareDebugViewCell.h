//
//  LLZShareDebugViewCell.h
//  LLZShareModule
//
//  Created by Lizhao on 2022/11/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LLZShareDebugViewCell : UICollectionViewCell
{
    UIView *line_h;
    UIView *line_v;
}
@property(nonatomic,strong) UIImageView *icon;
@property(nonatomic,strong)UILabel *label;

/// 0：左，1：中，2：右（一行三个按钮）
- (void)updateLineWithCellIndex:(NSInteger)index;
- (void)hiddeBottomLine:(BOOL)hidde;

@end

NS_ASSUME_NONNULL_END
