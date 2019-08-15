//
//  MediaCacheItem.h
//  SydneyToday
//
//  Created by Qson on 2018/11/12.
//  Copyright © 2018 Yu Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MediaCacheItem : NSObject

@property (nonatomic, copy) NSString *videoUrl;
@property (nonatomic, copy) NSString *videopic;
@property (nonatomic, assign) NSInteger index;
@end
