//
//  LLZShareChannelObjectWrapper.m
//
//  Created by Lizhao on 2022/11/10.
//

#import "LLZShareChannelObjectWrapper.h"

@implementation LLZShareChannelObjectWrapper

+ (instancetype)shareWrapperWithChannel:(LLZShareChannelType)channel shareObject:(LLZShareObject *)object {
    LLZShareChannelObjectWrapper *wrapper = [[LLZShareChannelObjectWrapper alloc] initWithChannel:channel shareObject:object];
    return wrapper;
}

- (instancetype)initWithChannel:(LLZShareChannelType)channel shareObject:(LLZShareObject *)object {
    self = [super init];
    if(self){
        _targetShareChannel = channel;
        _targetShareObject = object;
    }
    return self;
}

@end
