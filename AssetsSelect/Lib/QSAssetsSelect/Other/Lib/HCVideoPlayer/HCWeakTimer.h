//
//  HCWeakTimer.h
//  HCVideoPlayer
//
//  Created by chc on 2018/1/8.
//  Copyright © 2018年 chc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HCWeakTimer : NSObject
+ (instancetype )scheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval target:(id)target selector:(SEL)sel userInfo:(id)userInfo repeats:(BOOL)isRepeats;

+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval target:(id)target selector:(SEL)sel userInfo:(id)userInfo repeats:(BOOL)isRepeats forMode:(NSRunLoopMode)mode;

- (void)stop;
@property (readonly, getter=isValid) BOOL valid;
@end
