//
//  HCSharePanel.m
//  HCVideoPlayer
//
//  Created by chc on 2018/1/9.
//  Copyright © 2018年 chc. All rights reserved.
//

#import "HCSharePanel.h"
#import "HCVerButton.h"

#define kMaxCol 4
#define kPadding 40
#define kBtnW 46
#define kBtnFont 12
#define kContentH (290 + kVP_iPhoneXSafeBottomHeight)

@interface HCSharePanel ()
@property (nonatomic, strong) NSArray <HCShareItem *> *shareItems;
@property (nonatomic, strong) NSMutableArray *shareBtnsM;
@property (nonatomic, weak) UIView *btnsContentView;
@property (nonatomic, weak) UILabel *titleLabel;
@end

@implementation HCSharePanel

#pragma mark - 懒加载
- (NSMutableArray *)shareBtnsM
{
    if (_shareBtnsM == nil) {
        _shareBtnsM = [NSMutableArray array];
    }
    return _shareBtnsM;
}

- (UIView *)btnsContentView
{
    if (_btnsContentView == nil) {
        UIView *btnsContentView = [[UIView alloc] init];
        [self addSubview:btnsContentView];
        _btnsContentView = btnsContentView;
    }
    return _btnsContentView;
}

- (UILabel *)titleLabel
{
    if (_titleLabel == nil) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = @"分享至";
        _titleLabel = titleLabel;
    }
    return _titleLabel;
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selfTap)];
        [self addGestureRecognizer:tap];
        [self setupBtns];
    }
    return self;
}

- (void)dealloc
{
    VPLog(@"dealloc - HCSharePanel");
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)setupBtns
{
    for (int i = 0; i < self.shareItems.count; i ++) {
        HCShareItem *item = self.shareItems[i];
        __weak typeof(self) weakSelf = self;
        [self addBtnWithShareItem:item operation:^(HCShareItem *shareItem) {
            if ([weakSelf.delegate respondsToSelector:@selector(sharePanel:didSelectItem:)]) {
                [weakSelf.delegate sharePanel:weakSelf didSelectItem:shareItem];
            }
        }];
    }
}

- (void)setupBtnsFrame
{
    CGFloat margin = (kVP_ScreenWidth - ((kMaxCol - 1) * (kBtnW + kPadding) + kBtnW)) * 0.5;
    for (int i = 0; i < self.shareBtnsM.count; i ++) {
        NSInteger row = i / kMaxCol;
        NSInteger col = i % kMaxCol;
        HCVerButton *btn = self.shareBtnsM[i];
        CGFloat width = kBtnW;
        CGFloat height = [btn heightToFitWidth:kBtnW];
        CGFloat x = margin + col * (kBtnW + kPadding);
        CGFloat y = row * (height + kPadding);
        btn.frame = CGRectMake(x, y, width, height);
    }
    
    UIButton *lastBtn = self.shareBtnsM.lastObject;
    CGFloat height = CGRectGetMaxY(lastBtn.frame);
    CGFloat width = kVP_ScreenWidth;
    CGFloat x = 0;
    CGFloat y = (kVP_ScreenHeight - height) * 0.5;
    self.btnsContentView.frame = CGRectMake(x, y, width, height);
}

#pragma mark - 外部方法
- (void)showPanelAtView:(UIView *)view key:(NSString *)key
{
    if (![view isKindOfClass:[UIView class]]) {
        return;
    }
    self.frame = view.bounds;
    [view addSubview:self];
    self.shareItems = [self getShareItemWithkey:key];
    [self setupBtns];
    [self setupBtnsFrame];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.03 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:kVP_AniDuration animations:^{
            self.backgroundColor = kVP_Color(0, 0, 0, 0.5);
            for (UIButton *btn in self.shareBtnsM) {
                btn.alpha = 1.0;
            }
        }];
    });
//    [self setAnimationForBtns:self.shareBtnsM];
}

- (void)hiddenPanel
{
    [UIView animateWithDuration:kVP_AniDuration animations:^{
        self.backgroundColor = kVP_Color(0, 0, 0, 0.0);
        for (UIButton *btn in self.shareBtnsM) {
            btn.alpha = 0.0;
        }
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if ([self.delegate respondsToSelector:@selector(didHiddenSharePanel)]) {
            [self.delegate didHiddenSharePanel];
        }
    }];
}

- (NSArray *)getShareItemWithkey:(NSString *)key
{
    NSString *dirPath = [[NSBundle mainBundle] pathForResource:@"HCVideoPlayer" ofType:@"bundle"];
    NSString *filePath = [dirPath stringByAppendingPathComponent:@"vp_share.plist"];
    NSDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    NSArray *array = dict[key][@"top"];
    NSMutableArray *shareItemsM = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        HCShareItem *item = [HCShareItem shareModelWithDict:dict];
        item.key = key;
        [shareItemsM addObject:item];
    }
    return shareItemsM;
}

#pragma mark - 内部方法
- (void)addBtnWithShareItem:(HCShareItem *)shareItem operation:(void (^)(HCShareItem *shareItem))operation
{
    HCVerButton *sheetBtn = [[HCVerButton alloc] init];
    [sheetBtn setImage:[UIImage vp_imageWithName:shareItem.norImage] forState:UIControlStateNormal];
    [sheetBtn setImage:[UIImage vp_imageWithName:shareItem.higImage] forState:UIControlStateHighlighted];
    [sheetBtn setTitleColor:[UIColor whiteColor]/*kVP_Color(154, 154, 154, 1.0)*/ forState:UIControlStateNormal];
    [sheetBtn setTitle:shareItem.title forState:UIControlStateNormal];
    [sheetBtn addTarget:self action:@selector(sheetBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    sheetBtn.operation = operation;
    sheetBtn.shareItem = shareItem;
    sheetBtn.alpha = 0.0;
    sheetBtn.titleFont = [UIFont systemFontOfSize:kBtnFont];
    sheetBtn.titleLabel.textColor = [UIColor whiteColor];
    [self.btnsContentView addSubview:sheetBtn];
    [self.shareBtnsM addObject:sheetBtn];
}

- (void)setAnimationForBtns:(NSArray *)btns
{
    int i = 1;
    for (UIButton *btn in btns) {
        CAAnimationGroup *group = [CAAnimationGroup animation];
        CAKeyframeAnimation *keyframeAnimation = [CAKeyframeAnimation animation];
        keyframeAnimation.keyPath = @"transform.translation";
        NSValue *values1 = [NSValue valueWithCGPoint:CGPointMake(0 , 3)];
        NSValue *values2 = [NSValue valueWithCGPoint:CGPointMake(0 , 0)];
        NSValue *values3 = [NSValue valueWithCGPoint:CGPointMake(0 , -2)];
        NSValue *values4 = [NSValue valueWithCGPoint:CGPointMake(0 , 1)];
        // 5 * ( M_PI / 180 )
        keyframeAnimation.values = @[values1,values3,values4,values2];
        keyframeAnimation.keyTimes = @[@0.15, @0.4, @0.75, @1.0];
        keyframeAnimation.beginTime = i * 0.05;
        keyframeAnimation.duration = 0.7;
        group.animations =@[keyframeAnimation];
        group.duration = 0.7f + i * 0.05;
        group.fillMode = kCAFillModeForwards;
        group.removedOnCompletion = NO;
        [btn.layer addAnimation:group forKey:nil];
        i++;
    }
}

#pragma mark - 事件
- (void)sheetBtnClicked:(HCVerButton *)shareBtn
{
    VPLog(@"sheetItemClicked");
    if (shareBtn.operation) {
        shareBtn.operation(shareBtn.shareItem);
    }
}

- (void)selfTap
{
    [self hiddenPanel];
}
@end
