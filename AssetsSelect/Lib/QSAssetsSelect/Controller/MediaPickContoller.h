//
//  MediaPickContoller.h
//  SydneyToday
//
//  Created by Qson on 2017/12/13.
//  Copyright © 2017年 Yu Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediaPickContoller : UINavigationController
@property (nonatomic, assign) void(^dismissBlock)(void);
@property (nonatomic, assign) void(^didFinishPickingPhotos)(id photos);
@end
