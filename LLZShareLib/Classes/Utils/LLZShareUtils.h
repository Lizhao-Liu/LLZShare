//
//  LLZShareUtils.h
//  LLZShareLib
//
//  Created by Lizhao on 2022/10/19.
//

#import <Foundation/Foundation.h>
@import LLZShareService;

NS_ASSUME_NONNULL_BEGIN

typedef void (^VideoHandleSuccessBlock) (void);
typedef void (^VideoHandleCancelBlock) (NSString *msg);
typedef void (^VideoHandleFailBlock) (NSError * _Nullable error);

/// 视频下载工具
@interface LLZShareVideoUtils : NSObject

- (void)saveVideoWithUrl:(NSString *)downloadUrl
                fileName:(NSString *)fileName
                fileSize:(NSString *)fileSize
               readCache:(BOOL)useCache
          successHandler:(VideoHandleSuccessBlock)successBlock
           cancelHandler:(VideoHandleCancelBlock)cancelBlock
             failHandler:(VideoHandleFailBlock)failBlock;


- (void)saveVideoWithLocalPath:(NSString *)localPath
                successHandler:(VideoHandleSuccessBlock)successBlock
                 cancelHandler:(VideoHandleCancelBlock)cancelBlock
                   failHandler:(VideoHandleFailBlock)failBlock;

@end


/// 图片处理工具
@interface LLZShareImageUtils : NSObject

// 缩放图片方法
+ (UIImage *)imageByScalingImage:(UIImage*)image proportionallyToSize:(CGSize)targetSize;

// 压缩图片方法
+ (NSData *)imageDataByCompressImage:(UIImage*)image toLength:(CGFloat)targetLength;

// 图片下载
+ (UIImage *)imageFromUrlStr:(NSString *)url;

+ (NSData *)imageDataFromImage:(UIImage *)image isPNG:(BOOL)isPNG;

@end


/// 多媒体文件缓存管理
@interface LLZShareMediaResourceManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *VideoCachePool;

+ (instancetype)sharedInstance;

// 读取已下载video缓存
- (nullable NSString *)videoIdFromCacheForUrl: (NSString *)videoUrl;

@end

NS_ASSUME_NONNULL_END
