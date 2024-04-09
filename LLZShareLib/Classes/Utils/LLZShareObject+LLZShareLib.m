//
//  LLZShareObject+LLZShareLib.m
//  LLZShareLib
//
//  Created by Lizhao on 2022/10/18.
//

#import "LLZShareObject+LLZShareLib.h"
#import "NSString+LLZShareLib.h"
#import "LLZShareUtils.h"
//@import LLZFoundation;

#ifndef EMPTYSTRING
#define EMPTYSTRING(A) ({__typeof(A) __a = (A);__a == nil ? @"" : [NSString stringWithFormat:@"%@",__a];})
#endif

@implementation LLZShareObject (LLZShareLib)

- (BOOL)buildValidshareObjectWithError:(NSError **)error {
    self.shareTitle = EMPTYSTRING(self.shareTitle);
    self.shareContent = EMPTYSTRING(self.shareContent);
    return YES;
}
@end


@implementation LLZShareMessageObject (LLZShareLib)

- (BOOL)buildValidshareObjectWithError:(NSError **)error {
    [super buildValidshareObjectWithError:error];
    if(!(self.shareContent && self.shareContent.length>0)){
        if(error){
            *error = [[NSError alloc] initWithDomain:LLZShareErrorDomain code:LLZShareErrorType_shareObjectIncomplete userInfo:@{NSLocalizedDescriptionKey: @"传入数据错误：分享内容为空"}];
            return NO;
        }
    }
    return YES;
}

@end


@implementation LLZShareImageObject (LLZShareLib)

- (BOOL)buildValidshareObjectWithError:(NSError **)error {
    
    [super buildValidshareObjectWithError:error];
    self.shareImageUrl = EMPTYSTRING(self.shareImageUrl);
    
    if (self.shareImage){
        return YES;
    }
    if (self.shareImageUrl && self.shareImageUrl.length > 0) {
        UIImage *img = [LLZShareImageUtils imageFromUrlStr:self.shareImageUrl];
        self.isPNG = [self isPNGFromImageUrl:self.shareImageUrl];
        if (img) {
            self.shareImage = img;
            return YES;
        } else {
            *error = [[NSError alloc] initWithDomain:LLZShareErrorDomain code:LLZShareErrorType_shareObjectIncomplete userInfo:@{NSLocalizedDescriptionKey: @"传入数据错误：图片url错误"}];
            return NO;
        }
    } else {
        *error = [[NSError alloc] initWithDomain:LLZShareErrorDomain code:LLZShareErrorType_shareObjectIncomplete userInfo:@{NSLocalizedDescriptionKey: @"传入数据错误：图片为空"}];
        return NO;
    }
}

- (BOOL)isPNGFromImageUrl:(NSString *)imageUrl {
    NSString *fileExtension = [imageUrl pathExtension].lowercaseString;
    if ([fileExtension isEqualToString:@"png"]) {
        return YES;
    } else {
        return NO;
    }
}

@end


@implementation LLZShareVideoObject (LLZShareLib)

- (BOOL)buildValidshareObjectWithError:(NSError **)error {
    [super buildValidshareObjectWithError:error];
    self.downloadUrl = EMPTYSTRING(self.downloadUrl);
    self.fileName = EMPTYSTRING(self.fileName);
    self.fileSize = EMPTYSTRING(self.fileSize);
    self.failActionUrl = EMPTYSTRING(self.failActionUrl);
    self.successActionUrl = EMPTYSTRING(self.successActionUrl);
    self.localPath = EMPTYSTRING(self.localPath);
    
    if(!(self.downloadUrl && self.downloadUrl.length > 0) && !(self.localPath && self.localPath.length >0) ){
        *error = [[NSError alloc] initWithDomain:LLZShareErrorDomain code:LLZShareErrorType_shareObjectIncomplete userInfo:@{NSLocalizedDescriptionKey: @"传入数据错误：视频地址为空"}];
        return NO;
    }
    
    if(self.downloadUrl && self.downloadUrl.length > 0) {
        if(!(self.fileSize && self.fileSize.length > 0)){
            *error = [[NSError alloc] initWithDomain:LLZShareErrorDomain code:LLZShareErrorType_shareObjectIncomplete userInfo:@{NSLocalizedDescriptionKey: @"传入数据错误：视频下载大小为空"}];
            return NO;
        }
        
        if(![self.fileSize containsString:@"M"] && ![self.fileSize containsString:@"m"]) {
            self.fileSize = [self.fileSize stringByAppendingString:@"M"];
        }
        if(!(self.fileName && self.fileName.length > 0)){
            self.fileName =  [NSString stringWithFormat:@"%ld.mp4", (long)([[NSDate date] timeIntervalSince1970]*1000)];
        }
        if(![self.fileName containsString:@"mp4"] && ![self.fileName containsString:@"MP4"]) {
            self.fileName = [self.fileName stringByAppendingString:@".mp4"];
        }
    }
    
    return YES;
}

@end


@implementation LLZShareWebpageObject (LLZShareLib)

- (BOOL)buildValidshareObjectWithError:(NSError **)error {
    [super buildValidshareObjectWithError:error];
    self.shareTitle = EMPTYSTRING(self.shareTitle);
    self.webpageUrl = EMPTYSTRING(self.webpageUrl);
    self.thumbImageUrl = EMPTYSTRING(self.thumbImageUrl);
    if(!self.thumbImage && self.thumbImageUrl && self.thumbImageUrl.length > 0){
        self.thumbImage = [LLZShareImageUtils imageFromUrlStr:self.thumbImageUrl];
    }
    if(!self.thumbImage){
        // 如果是分享链接，且图片为空，则默认logo, 进行兜底处理
        self.thumbImage = [UIImage imageNamed:@"AppIcon"];
    }
    if(self.webpageUrl && self.webpageUrl.length > 0) {
        return YES;
    } else {
        *error = [[NSError alloc] initWithDomain:LLZShareErrorDomain code:LLZShareErrorType_shareObjectIncomplete userInfo:@{NSLocalizedDescriptionKey: @"传入数据错误：传入网页地址为空"}];
        return NO;
    }
}

@end


@implementation LLZShareMiniProgramObject (LLZShareLib)

- (BOOL)buildValidshareObjectWithError:(NSError **)error {
    [super buildValidshareObjectWithError:error];
    self.userName = EMPTYSTRING(self.userName);
    self.path = EMPTYSTRING(self.path);
    self.sharePageUrl = EMPTYSTRING(self.sharePageUrl);
    if(!(self.userName && self.userName.length > 0)){
        *error = [[NSError alloc] initWithDomain:LLZShareErrorDomain code:LLZShareErrorType_shareObjectIncomplete userInfo:@{NSLocalizedDescriptionKey: @"传入数据错误：小程序原始id为空"}];
        return NO;
    }
    return YES;
    
}


@end


@implementation LLZShareAutoTypeObject (LLZShareLib)

- (LLZShareObject *)typedshareObject {
    self.userName = EMPTYSTRING(self.userName);
    // 1. 首先根据username判断是否为小程序
    if(self.userName && self.userName.length > 0){
        return [self convertToMiniProgramObject];
    }
    // 2. 根据sharePageUrl判断是否为链接
    self.sharePageUrl = EMPTYSTRING(self.sharePageUrl);
    if(self.sharePageUrl && self.sharePageUrl.length > 0){
        return [self convertToWebpageObject];
    }
    // 3. 根据shareimage 或者 shareimageurl判断是否为图片
    self.shareImageUrl =EMPTYSTRING(self.shareImageUrl);
    if(self.shareImage || (self.shareImageUrl && self.shareImageUrl.length > 0)){
        return [self convertToImageObject];
    }
    // 4. 根据download字段判断是否为视频
    self.downloadUrl = EMPTYSTRING(self.downloadUrl);
    if(self.downloadUrl && self.downloadUrl.length > 0){
        return [self convertToVideoObject];
    }
    // 5. 若以上都不是，则转为文字分享model
    return [self convertToMessageObject];
}

- (LLZShareMessageObject *)convertToMessageObject {
    LLZShareMessageObject *object = [[LLZShareMessageObject alloc] init];
    object.shareTitle = self.shareTitle;
    object.shareContent = self.shareContent;
    return object;
}

- (LLZShareVideoObject *)convertToVideoObject {
    LLZShareVideoObject *object = [[LLZShareVideoObject alloc] init];
    object.downloadUrl = self.downloadUrl;
    object.fileName = self.fileName;
    object.fileSize = self.fileSize;
    object.failActionUrl = self.failActionUrl;
    object.successActionUrl = self.successActionUrl;
    object.shareTitle = self.shareTitle;
    object.shareContent = self.shareContent;
    return object;
}

- (LLZShareImageObject *)convertToImageObject {
    LLZShareImageObject *object = [[LLZShareImageObject alloc] init];
    object.shareTitle = self.shareTitle;
    object.shareContent = self.shareContent;
    if(self.shareImage){
        object.shareImage = self.shareImage;
    }else if(self.shareImageUrl){
        object.shareImageUrl = self.shareImageUrl;
    }
    return object;
}

- (LLZShareWebpageObject *)convertToWebpageObject {
    LLZShareWebpageObject * object = [[LLZShareWebpageObject alloc] init];
    object.webpageUrl = self.sharePageUrl;
    object.shareTitle = self.shareTitle;
    object.shareContent = self.shareContent;
    object.thumbImage = self.shareImage;
    object.thumbImageUrl = self.shareImageUrl;

    return object;
}

- (LLZShareMiniProgramObject *)convertToMiniProgramObject {
    LLZShareMiniProgramObject *object = [[LLZShareMiniProgramObject alloc] init];
    object.path = self.path;
    object.userName = self.userName;
    object.sharePageUrl = self.sharePageUrl;
    object.shareContent = self.shareContent;
    object.shareTitle = self.shareTitle;
    object.type = self.miniProgramType;
    if(self.miniAppImage){
        object.hdImage = self.miniAppImage;
    } else if (self.shareImage){
        object.hdImage = self.shareImage;
    } else if (self.shareImageUrl && self.shareImageUrl.length > 0) {
        object.hdImage = [LLZShareImageUtils imageFromUrlStr:self.shareImageUrl];
    }
    return object;
}



@end
