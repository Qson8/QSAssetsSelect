//
//  HCAirplayCastTool.m
//  HCVideoPlayer
//
//  Created by chc on 2018/7/20.
//  Copyright © 2018年 chc. All rights reserved.
//

#import "HCAirplayCastTool.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@implementation HCAirplayCastTool
+ (BOOL)isAirPlayOnCast
{
//    // 先排除蓝牙耳机
//    BOOL isBluetoothA2DPOutput = NO;
//    AVAudioSessionPortDescription *pd = [[AVAudioSession sharedInstance].currentRoute.outputs firstObject];
//    if ([pd.portType isEqualToString:@"BluetoothA2DPOutput"] || [pd.portType isEqualToString:@"BluetoothHFP"]) {
//        // TODO:
//        isBluetoothA2DPOutput = YES;
//    }
//    
//    if (isBluetoothA2DPOutput) {
//        return NO;
//    }
//    
//    
//    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
//    //    BOOL a = volumeView.areWirelessRoutesAvailable;
//    //    BOOL b = volumeView.isWirelessRouteActive;
//    
//    // 排除后是投屏
//    if (volumeView.isWirelessRouteActive) {
//        return YES;
//    }
//    else {
//        return NO;
//    }
    return NO;
}
@end
