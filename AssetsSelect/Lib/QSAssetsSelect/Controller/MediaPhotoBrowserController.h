//
//  MediaPhotoBrowserController.h
//  SydneyToday
//
//  Created by Qson on 2018/11/2.
//  Copyright © 2018 Yu Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MediaPhotoBrowserDelegate <NSObject>
@optional
- (void)photoBrowserRightButtonDidClick;
@end

@interface MediaPhotoBrowserController : UIViewController
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSArray *imageArray;
@end
