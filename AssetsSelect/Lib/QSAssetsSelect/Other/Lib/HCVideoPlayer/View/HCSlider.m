//
//  HCSlider.m
//  HCVideoPlayer
//
//  Created by chc on 2017/12/7.
//  Copyright © 2017年 chc. All rights reserved.
//

#import "HCSlider.h"
#import "HCVideoPlayerConst.h"

@implementation HCSlider
- (void)dealloc
{
    VPLog(@"dealloc - HCSlider");
}

- (CGRect)trackRectForBounds:(CGRect)bounds
{
    if (_sliderHeight == 0) {
        _sliderHeight = 2;
    }
    return CGRectMake(0, (CGRectGetHeight(self.frame) - _sliderHeight) * 0.5, CGRectGetWidth(self.frame), _sliderHeight);
}
@end
