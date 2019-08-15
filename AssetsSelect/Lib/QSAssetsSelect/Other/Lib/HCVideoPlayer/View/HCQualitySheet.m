//
//  HCQualitySheet.m
//  HCVideoPlayer
//
//  Created by chc on 2017/12/7.
//  Copyright © 2017年 chc. All rights reserved.
//

#import "HCQualitySheet.h"

@implementation HCQualitySheet
#pragma mark - 懒加载
- (UIView *)contentView
{
    if (_contentView == nil) {
        UIView *contentView = [[UIView alloc] init];
        [self addSubview:contentView];
        _contentView = contentView;
    }
    return _contentView;
}

#pragma mark - 外部方法
- (void)setAllSupportQuality:(NSArray *)allSupportQuality
{
    _allSupportQuality = allSupportQuality;
    for (UIButton *btn in self.contentView.subviews) {
        btn.enabled = NO;
        for (NSNumber *num in _allSupportQuality) {
            if (num.integerValue == btn.tag) {
                btn.enabled = YES;
            }
        }
    }
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _items = @[@"流畅", @"标清", @"高清", @"超清", @"2K"];//, @"4K", @"原始"];
        for (int i = 0; i < _items.count; i ++) {
            NSString *title = _items[i];
            UIButton *btn = [[UIButton alloc] init];
            [self.contentView addSubview:btn];
            [btn setTitle:title forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor brownColor] forState:UIControlStateSelected];
            [btn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
            btn.titleLabel.font = [UIFont systemFontOfSize:12];
            btn.tag = i;
            [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat selfWidth = self.bounds.size.width;
    CGFloat selfHeight = self.bounds.size.height;
    CGFloat btnHeight = selfHeight / self.contentView.subviews.count;
    for (UIButton *btn in self.contentView.subviews) {
        btn.frame = CGRectMake(0, btn.tag * btnHeight, selfWidth, btnHeight);
    }
    self.contentView.frame = CGRectMake(0, 0, selfWidth, self.contentView.subviews.count * btnHeight);
}

#pragma mark - 事件
- (void)btnClicked:(UIButton *)button
{
}
@end
