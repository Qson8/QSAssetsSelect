//
//  HCVerButton.h
//  HCVideoPlayer
//
//  Created by chc on 2018/1/9.
//  Copyright © 2018年 chc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HCHorButton : UIButton
/** 必须这样设置btn的字体 */
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, assign) CGFloat padding;
@property (nonatomic, assign, readonly) CGFloat fitWidth;
@end
