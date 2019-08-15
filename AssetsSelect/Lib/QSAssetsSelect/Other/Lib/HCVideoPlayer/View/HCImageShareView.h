//
//  HCImageShareView.h
//  ShortVideo
//
//  Created by chc on 2018/1/18.
//  Copyright © 2018年 chc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HCImageShareView : UIView
@property (nonatomic, strong) UIImage *image;
- (CGFloat)heightToFit;
@end
