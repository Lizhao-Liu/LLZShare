//
//  LLZShareObject+LLZShareLib.h
//  LLZShareLib
//
//  Created by Lizhao on 2022/10/18.
//

@import LLZShareService;

NS_ASSUME_NONNULL_BEGIN

@interface LLZShareObject (LLZShareLib)

- (BOOL)buildValidshareObjectWithError:(NSError *_Nullable *)error;

@end

@interface LLZShareAutoTypeObject (LLZShareLib)

- (LLZShareObject *)typedshareObject;
- (LLZShareVideoObject *)convertToVideoObject;
- (LLZShareImageObject *)convertToImageObject;
- (LLZShareWebpageObject *)convertToWebpageObject;
- (LLZShareMiniProgramObject *)convertToMiniProgramObject;
- (LLZShareMessageObject *)convertToMessageObject;

@end

NS_ASSUME_NONNULL_END
