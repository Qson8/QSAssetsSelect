//
//  HCProgressView.h
//  HCVideoPlayer
//
//  Created by chc on 2017/12/7.
//  Copyright © 2017年 chc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HCProgressView;
@protocol HCProgressViewDelegate <NSObject>
- (void)progressView:(HCProgressView *)progressView didChangedSliderValue:(double)sliderValue time:(NSTimeInterval)time;
- (void)progressView:(HCProgressView *)progressView didSliderUpAtValue:(CGFloat)value time:(CGFloat)time;
@end

@interface HCProgressView : UIView
@property (nonatomic, assign) CGFloat progressHeight;
@property (nonatomic, assign) double playProgress;
@property (nonatomic, assign) double loadProgress;
@property (nonatomic, assign) NSTimeInterval playTime;
@property (nonatomic, assign) NSTimeInterval loadTime;
@property (nonatomic, assign) NSTimeInterval totalTime;

@property (nonatomic, assign, readonly) NSTimeInterval lastPlayTime;
@property (nonatomic, weak) id <HCProgressViewDelegate> delegate;
@end
