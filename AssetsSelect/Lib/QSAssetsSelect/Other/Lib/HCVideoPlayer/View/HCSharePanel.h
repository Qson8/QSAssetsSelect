//
//  HCSharePanel.h
//  HCVideoPlayer
//
//  Created by chc on 2018/1/9.
//  Copyright © 2018年 chc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCVideoPlayerConst.h"

@class HCSharePanel;
@protocol HCSharePanelDelegate <NSObject>
- (void)sharePanel:(HCSharePanel *)sharePanel didSelectItem:(HCShareItem *)item;
- (void)didHiddenSharePanel;
@end

@interface HCSharePanel : UIView
@property (nonatomic, weak) id <HCSharePanelDelegate> delegate;
- (void)showPanelAtView:(UIView *)view key:(NSString *)key;
- (void)hiddenPanel;
@end
