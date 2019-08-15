//
//  MediaProgressView.h
//  SydneyToday
//
//  Created by Qson on 2017/12/16.
//  Copyright © 2017年 Yu Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediaProgressView : UIView
@property (assign, nonatomic) NSInteger timeMax;
- (void)clearProgress;
@end
