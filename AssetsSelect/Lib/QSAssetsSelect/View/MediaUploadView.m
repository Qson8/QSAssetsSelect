//
//  MediaUploadView.m
//  14.文件上传
//
//  Created by Qson on 2018/1/6.
//  Copyright © 2018年 康生 邱. All rights reserved.
//

#import "MediaUploadView.h"
#import "UIView+Extension.h"

#define QSColor(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@interface MediaUploadView ()
@property (nonatomic, weak) UIView *rampView;
@property (nonatomic, weak) UILabel *percentLabel;
@property (nonatomic, copy) NSString *updataDescribe;
@end

@implementation MediaUploadView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds =YES;
        self.backgroundColor = [UIColor clearColor];
        [self rampView];
        [self percentLabel];
        [self setupFrame];
        self.hidden = YES;
        self.updataDescribe = @"图片上传";
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self setupFrame];
}

#pragma mark - 内部实现
- (void)setupFrame
{
    self.rampView.frame = self.bounds;
    self.percentLabel.frame = self.bounds;
}

- (void)startUpdating
{
    if(self.updataDescribe.length)
        self.percentLabel.text = [NSString stringWithFormat:@"%@0%%",self.updataDescribe];
    self.hidden = NO;
}

- (void)finishUpdating
{
    self.hidden = YES;
}

- (void)updataFailure
{
    self.hidden = YES;
}

#pragma mark - 懒加载
- (UIView *)rampView
{
    if(_rampView == nil) {
        UIView *rampView = [[UIView alloc] init];
        rampView.backgroundColor = QSColor(0, 0, 0, 0.4);
        [self addSubview:rampView];
        _rampView = rampView;
    }
    return _rampView;
}
- (UILabel *)percentLabel
{
    if(_percentLabel == nil) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:(IS_IPHONE_5 || IS_IPHONE_4) ? 8 : kIPadSuitFloat(10)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        [self addSubview:label];
        _percentLabel = label;
    }
    return _percentLabel;
}

#pragma mark - 外部方法
- (void)setRampColor:(UIColor *)rampColor
{
    _rampColor = rampColor;
    self.rampView.backgroundColor = rampColor;
}

- (void)setFileType:(MediaType)fileType
{
    _fileType = fileType;
    
    switch (fileType) {
        case kMediaTypeImage:
            self.updataDescribe = @"图片上传";
            break;
        case kMediaTypeVideo:
            self.updataDescribe = @"视频上传";
            break;
        case kMediaTypeFile:
            self.updataDescribe = @"文件上传";
            break;
        default:
            break;
    }
    
    if(self.updataDescribe.length)
        self.percentLabel.text = [NSString stringWithFormat:@"%@0%%",self.updataDescribe];
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    
    //通知主线程刷新
    dispatch_async(dispatch_get_main_queue(), ^{
        //回调或者说是通知主线程刷新，
        self.percentLabel.text = [NSString stringWithFormat:@"%@%.f%%",self.updataDescribe,(progress * 100)];
        CGFloat sy = progress * self.height;
        self.rampView.transform = CGAffineTransformMakeTranslation(0, -sy);
    });
}

@end
