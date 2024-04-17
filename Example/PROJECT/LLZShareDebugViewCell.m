//
//  LLZShareDebugViewCell.m
//  LLZShareModule
//
//  Created by Lizhao on 2022/11/9.
//

#define RGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

#import "LLZShareDebugViewCell.h"
@import Masonry;

@implementation LLZShareDebugViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setView];
    }
    return self;
}

- (void)setView{
    //图片
    _icon = [[UIImageView alloc]init];
    _icon.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_icon];
    
    
    
    //文字
    self.label = [[UILabel alloc] init];
    self.label.text = @"测试";
    self.label.font = [UIFont systemFontOfSize:15.0];
    self.label.textColor = RGB(55, 67, 92);
    [self.contentView addSubview:self.label];
    
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.height.mas_equalTo(20);
        make.bottom.mas_equalTo(-17.0);
    }];
    
    [_icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(62, 62));
        make.centerX.equalTo(self.mas_centerX);
        make.bottom.equalTo(self.label.mas_top).offset(-10);
    }];
    
    
    line_h = [[UIView alloc] init];
    line_h.backgroundColor = RGB(238, 239, 247);
    [self.contentView addSubview:line_h];
    
    line_v = [[UIView alloc] init];
    line_v.backgroundColor = RGB(238, 239, 247);
    [self.contentView addSubview:line_v];
    
    [line_h mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.height.mas_equalTo(1);
        make.left.equalTo(self.contentView.mas_left);
        make.width.equalTo(self.contentView.mas_width);
    }];
    
    [line_v mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-1);
        make.height.equalTo(self.contentView.mas_height);
        make.width.mas_offset(1);
    }];
}

- (void)updateLineWithCellIndex:(NSInteger)index {
    if (index == 0) {
        [line_h mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.contentView.mas_width).offset(-16);
            make.left.equalTo(self.contentView.mas_left).offset(16);
        }];
    }else if(index == 2){
        [line_h mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.contentView.mas_width).offset(-16);
            make.left.equalTo(self.contentView.mas_left);
        }];
    }else{
        [line_h mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left);
            make.width.equalTo(self.contentView.mas_width);
        }];
    }
}
- (void)hiddeBottomLine:(BOOL)hidde{
    line_h.hidden = hidde;
}

@end
