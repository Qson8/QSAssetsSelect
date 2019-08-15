//
//  HCIconSlider.h
//  ShortVideo
//
//  Created by chc on 2018/1/16.
//  Copyright © 2018年 chc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HCIconSlider;
@protocol HCIconSliderDelegate <NSObject>
- (void)iconSlider:(HCIconSlider *)iconSlider didChangedSliderValue:(double)sliderValue;
- (void)iconSlider:(HCIconSlider *)iconSlider didSliderUpAtValue:(CGFloat)value;
@end

@interface HCIconSlider : UIView
@property (nonatomic, weak) id <HCIconSliderDelegate> delegate;
@property (nonatomic, assign) CGFloat value;
@property (nonatomic, copy) NSString *thumbImageName;
@property (nonatomic, copy) NSString *leftImageName;
@property (nonatomic, copy) NSString *rightImageName;
@property (nonatomic, assign) CGFloat leftImageWidth;
@property (nonatomic, assign) CGFloat rightImageWidth;
- (CGFloat)heightToFit;
@end
