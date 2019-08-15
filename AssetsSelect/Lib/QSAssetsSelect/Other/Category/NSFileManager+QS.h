//
//  NSFileManager+QS.h
//  SydneyToday
//
//  Created by Qson on 2018/7/2.
//  Copyright © 2018年 Yu Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kDocumentPath(fileName) [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:fileName]
#define kLibraryCachesPath(fileName) [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:fileName]

extern NSTimeInterval const kDefaultTimeout;

@interface NSFileManager (QS)

#pragma mark - 各种路径及URL
+ (NSURL *)documentsURL;
+ (NSString *)documentsPath;
+ (NSURL *)libraryURL;
+ (NSString *)libraryPath;
+ (NSURL *)cachesURL;
+ (NSString *)cachesPath;
+ (NSString *)homePath;
+ (NSString *)tmpPath;

#pragma mark - 其他扩展方法
/**
 * 生成文件和目录全路径
 * directory: 目录，可以多级 如 list/165/photo
 * lastPathComponent:带后缀的文件名，如123.mp4
 */
- (NSString *)generateFilePathAtDirectory:(NSString *)directory lastPathComponent:(NSString *)lastPathComponent;
+ (void)configFileTimeout:(NSTimeInterval)interval atDirectory:(NSString *)directoryPath;
- (void)configFileTimeout:(NSTimeInterval)interval atDirectory:(NSString *)directoryPath;

- (BOOL)isFileExists:(NSString *)filePath;
- (BOOL)isDirectoryExists:(NSString *)path;
- (BOOL)isDirectoryAtFilePath:(NSString *)path;
- (BOOL)isFile:(NSString *)filePath timeout:(NSTimeInterval)timeout;

- (NSArray *)subpathsOfDirectoryAtPath:(NSString *)path;
- (void)removeItemAtPath:(NSString *)path;
@end


/*! @brief  NSFileManager (File)
 *
 * 文件存储
 */
@interface NSFileManager (File)
/*! @brief 提供一个目录名，得到该目录的全路径，如果不存在改目录就创建
 *
 * @param   directoryName 目录名
 
 * @return  返回全路径
 */
+ (NSString *)fechVideoStoragePath:(NSString *)directoryName;

/// 存
+ (void)storageImage:(UIImage *)image filePath:(NSString *)filePath;
// 取
+ (UIImage *)imageForStorageFilePath:(NSString *)filePath;
// 删
+ (void)removeStorageFilePath:(NSString *)filePath;

/** 保存视频到指定路径 */
+ (void)saveVideoSourceUrl:(NSURL *)assetFilePath outputURL:(NSURL *)outputURL;
@end

