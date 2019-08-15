//
//  HCMorePanel.h
//  HCVideoPlayer
//
//  Created by chc on 2018/1/10.
//  Copyright © 2018年 chc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HCMorePanel;
@protocol HCMorePanelDelegate <NSObject>
- (void)didHiddenMorePanel;
- (void)morePanel:(HCMorePanel *)morePanel didSelectRate:(CGFloat)rate;
- (void)morePanel:(HCMorePanel *)morePanel didChangeColloctStatus:(BOOL)status;
@end

@interface HCMorePanel : UIView
@property (nonatomic, weak) id <HCMorePanelDelegate> delegate;
@property (nonatomic, assign) CGFloat rate;
@property (nonatomic, assign) BOOL collectStatus;
- (void)showPanelAtView:(UIView *)view;
- (void)hiddenPanel;
@end
