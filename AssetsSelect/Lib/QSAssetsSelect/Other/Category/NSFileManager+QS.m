//
//  NSFileManager+QS.m
//  SydneyToday
//
//  Created by Qson on 2018/7/2.
//  Copyright © 2018年 Yu Wang. All rights reserved.
//

#import "NSFileManager+QS.h"
#import <AVFoundation/AVFoundation.h>

#define kCacheHTMLFile      @"HTMLFileCache/NewsDetailsHTMLFile"
NSTimeInterval const kDefaultTimeout = (7 * 24 * 60 * 60.0);

@implementation NSFileManager (QS)

#pragma mark - 各种路径及URL
/**
 *  获取URL
 *
 *  @param directory 指定的directory
 *
 *  @return 得到的URL
 */
+ (NSURL *)URLForDirectory:(NSSearchPathDirectory)directory {
    return [self.defaultManager URLsForDirectory:directory inDomains:NSUserDomainMask].lastObject;
}

/**
 *  获取指定directory的路径
 *
 *  @param directory 指定的directory
 *
 *  @return 得到的路径
 */
+ (NSString *)pathForDirectory:(NSSearchPathDirectory)directory {
    return NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES)[0];
}

/**
 *  获取Documents目录URL
 *
 *  @return Documents目录URL
 */
+ (NSURL *)documentsURL {
    return [self URLForDirectory:NSDocumentDirectory];
}

/**
 *  获取Documents目录路径
 *
 *  @return Documents目录路径
 */
+ (NSString *)documentsPath {
    return [self pathForDirectory:NSDocumentDirectory];
}

/**
 *  获取Library目录URL
 *
 *  @return Library目录URL
 */
+ (NSURL *)libraryURL {
    return [self URLForDirectory:NSLibraryDirectory];
}

/**
 *  获取Library目录路径
 *
 *  @return Library目录路径
 */
+ (NSString *)libraryPath {
    return [self pathForDirectory:NSLibraryDirectory];
}

/**
 *  获取Cache目录URL
 *
 *  @return Cache目录URL
 */
+ (NSURL *)cachesURL {
    return [self URLForDirectory:NSCachesDirectory];
}

/**
 *  获取Cache目录路径
 *
 *  @return Cache目录路径
 */
+ (NSString *)cachesPath {
    return [self pathForDirectory:NSCachesDirectory];
}

/**
 *  获取应用沙盒根路径
 *
 *  @return 应用沙盒根路径
 */
+ (NSString *)homePath {
    return NSHomeDirectory();
}

/**
 *  获取Tmp目录路径
 *
 *  @return Tmp目录路径
 */
+ (NSString *)tmpPath {
    return NSTemporaryDirectory();
}

#pragma mark - 其他扩展方法

/// 生成文件和目录全路径
- (NSString *)generateFilePathAtDirectory:(NSString *)directory lastPathComponent:(NSString *)lastPathComponent
{
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *components = [directory componentsSeparatedByString:@"/"];
    
    NSString *filePath = documentPath;
    for (NSString *com in components) {
        if(com.length) {
            filePath = [filePath stringByAppendingPathComponent:com];
            if (![fileManager isDirectoryExists:filePath]) {
                [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
            }
        }
    }
    
    if(lastPathComponent.length) {
        filePath = [filePath stringByAppendingPathComponent:lastPathComponent];
    }
    
    return filePath;
}

/**
 给沙盒指定文件夹设置过期时间，过期删除文件
 
 @param interval 文件有效期 （默认 7 * 24 * 60 * 60）
 @param directoryPath 文件夹全路径
 */
+ (void)configFileTimeout:(NSTimeInterval)interval atDirectory:(NSString *)directoryPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager configFileTimeout:kDefaultTimeout
                                          atDirectory:kLibraryCachesPath(kCacheHTMLFile)];
}

/**
 给沙盒指定文件夹设置过期时间，超过设置时间删除文件
 
 @param interval 文件有效期 （默认 7 * 24 * 60 * 60）
 @param directoryPath 文件夹全路径
 */
- (void)configFileTimeout:(NSTimeInterval)interval atDirectory:(NSString *)directoryPath
{
    if(![self isDirectoryExists:directoryPath]) return;
    
    NSArray *subpaths = [self subpathsOfDirectoryAtPath:directoryPath];
    if(!subpaths.count) return;
    
    NSTimeInterval timeout = interval?interval:(7 * 24 * 60 * 60);
    
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        for (NSString *path in subpaths) {
            NSString *allFilePath = [directoryPath stringByAppendingPathComponent:path];
            BOOL isTimeout = [self isFile:allFilePath timeout:timeout];
            if(!isTimeout) return;
            
            [self removeItemAtPath:allFilePath];
        }
    });
}

/*!
 * @brief 判断文件是否存在于沙盒中
 * @param fileName 文件路径名
 * @return 返回YES表示存在，返回NO表示不存在
 */
- (BOOL)isFileExists:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager fileExistsAtPath:filePath];
    
    return result;
}

/*!
 * @brief 判断目录(文件夹)是否存在于沙盒中
 * @param path 目录(文件夹)路径名
 * @return 返回YES表示存在，返回NO表示不存在
 */
- (BOOL)isDirectoryExists:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL b = NO;
    BOOL result = [fileManager fileExistsAtPath:path isDirectory:&b];
    
    return result;
}

/**
 判断该路径下是文件还是文件夹
 
 @param path 路径
 @return 返回结果
 */
- (BOOL)isDirectoryAtFilePath:(NSString *)path
{
    NSFileManager *fileM = [NSFileManager defaultManager];
    NSString *newStr = path;
    BOOL b = NO;
    [fileM fileExistsAtPath:newStr isDirectory:&b];
    
    return b;
}

/*!
 * @brief 判断文件是否超时
 * @param filePath 文件路径名
 * @param timeout 限制的超时时间，单位为秒
 * @return 返回YES表示超时，返回NO表示未超时
 */
- (BOOL)isFile:(NSString *)filePath timeout:(NSTimeInterval)timeout {
    if ([self isFileExists:filePath]) {
        NSError *error = nil;
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath
                                                                                    error:&error];
        if (error) {
            return YES;
        }
        if ([attributes isKindOfClass:[NSDictionary class]] && attributes) {
            //  NSLog(@"%@", attributes);
            NSString *createDate = [attributes objectForKey:@"NSFileModificationDate"];
            createDate = [NSString stringWithFormat:@"%@", createDate];
            if (createDate.length >= 19) {
                createDate = [createDate substringToIndex:19];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                
                NSDate *sinceDate = [formatter dateFromString:createDate];
                NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:sinceDate];
                return (interval >= timeout);
            }
        }
    }
    return YES;
}

/**
 获取文件夹内所有文件路径

 @param path 文件夹路径
 @return 返回该文件夹内所有文件的路径
 */
- (NSArray *)subpathsOfDirectoryAtPath:(NSString *)path
{
    NSFileManager *fileM = [NSFileManager defaultManager];
    NSArray *subpaths = [fileM subpathsOfDirectoryAtPath:path error:nil];
    
    return subpaths;
}


/**
 删除文件

 @param path 需要删除的文件路径
 */
- (void)removeItemAtPath:(NSString *)path
{
    NSFileManager *fileM = [NSFileManager defaultManager];
    [fileM removeItemAtPath:path error:nil];
}

/**
 获取文件的修改时间
 
 @param path 文件路径
 @return 修改时间
 */
- (NSString *)modificationDateAtFilePath:(NSString *)path
{
    if ([self isDirectoryExists:path] == NO)
    {
        // 获取当前文件属性
        NSFileManager *fileM = [NSFileManager defaultManager];
        NSDictionary *dic = [fileM attributesOfItemAtPath:path error:nil];
        // 从字典对象中获取文件的修改时间
        NSString *modificationDate = [dic valueForKey:@"NSFileModificationDate"];
        return modificationDate;
    }
    return nil;
}

@end


/*! @brief  NSFileManager (File)
 *
 * 文件存储
 */
@implementation NSFileManager (File)

/*! @brief 提供一个目录名，得到该目录的全路径，如果不存在改目录就创建
 *
 * @param   directoryName 目录名

 * @return  返回全路径
 */
+ (NSString *)fechVideoStoragePath:(NSString *)directoryName
{
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    documentPath = [documentPath stringByAppendingPathComponent:directoryName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager isDirectoryExists:documentPath]) {
        // 创建目录，存在则不会创建
        [fileManager createDirectoryAtPath:[documentPath stringByAppendingPathComponent:directoryName] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return documentPath;
}

+ (void)storageImage:(UIImage *)image filePath:(NSString *)filePath
{
    if(!filePath.length || !image) return;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = UIImagePNGRepresentation(image);
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager createFileAtPath:filePath contents:imageData attributes:nil];
        CGLog(@"图片写入路径：%@",filePath);
    });
}

+ (UIImage *)imageForStorageFilePath:(NSString *)filePath
{
    if(!filePath.length) return nil;
    
    UIImage *image = nil;
    if([[NSFileManager defaultManager] isFileExists:filePath]) {
        image = [UIImage imageWithContentsOfFile:filePath];
    }
    return image;
}

+ (void)removeStorageFilePath:(NSString *)filePath
{

    if(!filePath.length) return;
    
    if([[NSFileManager defaultManager] isFileExists:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}

/** 保存视频到指定路径 */
+ (void)saveVideoSourceUrl:(NSURL *)assetFilePath outputURL:(NSURL *)outputURL
{
    if(!assetFilePath || !outputURL) return;
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:assetFilePath options:nil];

    AVAssetExportSession *exportSession= [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        int exportStatus = exportSession.status;

        switch (exportStatus)
        {
            case AVAssetExportSessionStatusFailed:
            {
                // log error to text view
                NSError *exportError = exportSession.error;
                CGLog (@"AVAssetExportSessionStatusFailed: %@", exportError);
                break;
            }
            case AVAssetExportSessionStatusCompleted:
            {
                CGLog(@"写入成功");
            }
        }
    }];

}
@end
