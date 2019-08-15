//
//  HCNetWorkSpeed.h
//  HCVideoPlayer
//
//  Created by chc on 2018/1/10.
//  Copyright © 2018年 chc. All rights reserved.
//

#import <Foundation/Foundation.h>
/** @{@"received":@"100kB/s"} */
FOUNDATION_EXTERN NSString *const NotificationNetworkReceivedSpeed;

/** @{@"send":@"100kB/s"} */
FOUNDATION_EXTERN NSString *const NotificationNetworkSendSpeed;

@interface HCNetWorkSpeed : NSObject
@property (nonatomic, copy, readonly) NSString * receivedNetworkSpeed;
@property (nonatomic, copy, readonly) NSString * sendNetworkSpeed;

+ (instancetype)shareNetworkSpeed;
- (void)startMonitoringNetworkSpeed;
- (void)stopMonitoringNetworkSpeed;
@end
