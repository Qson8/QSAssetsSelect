//
//  HCWeakTimer.m
//  HCVideoPlayer
//
//  Created by chc on 2018/1/8.
//  Copyright © 2018年 chc. All rights reserved.
//

#import "HCWeakTimer.h"
#import "HCVideoPlayerConst.h"

@interface HCWeakTimer ()
@property (nonatomic,weak) id target;
@property (nonatomic,assign) SEL selector;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation HCWeakTimer
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval target:(id)target selector:(SEL)sel userInfo:(id)userInfo repeats:(BOOL)isRepeats {
    
    return [self scheduledTimerWithTimeInterval:timeInterval target:target selector:sel userInfo:userInfo repeats:isRepeats forMode:NSDefaultRunLoopMode];
}

+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval
                                        target:(id)target
                                      selector:(SEL)sel
                                      userInfo:(id)userInfo
                                       repeats:(BOOL)isRepeats
                                       forMode:(NSRunLoopMode)mode {
    HCWeakTimer *objc = [[self alloc] init];
    objc.target = target;
    objc.selector = sel;
    objc.timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:objc selector:@selector(timeAction:) userInfo:userInfo repeats:isRepeats];
    [[NSRunLoop currentRunLoop] addTimer:objc.timer forMode:mode];
    //Nstimer 对 WeakTimeObject 对象 强引用
    return objc;
}

- (void)stop
{
    [_timer invalidate];
    _timer = nil;
}

- (BOOL)isValid
{
    return self.timer.valid;
}

//消息传递，在 self.target  运行 self.selector 方法
- (void)timeAction:(id)info {
    [self.target performSelector:self.selector withObject:info];
}

- (void)dealloc
{
    VPLog(@"dealloc - HCWeakTimer");
}
@end
