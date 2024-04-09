//
//  LLZContext.m
//
//

#import "LLZContext.h"

#import "LLZService.h"
#import <objc/runtime.h>
#import <objc/message.h>

///缺省模块优先级
static const NSInteger MODULE_PRIORITY_DEFAULT = 1000;


@interface LLZModuleContext ()
@end

@implementation LLZModuleContext


- (id<LLZServiceProtocol>)findServiceWithProtocol:(Protocol *)serviceProtocol {
    return [[LLZService shared] takeOneServiceForProtocol:serviceProtocol
                                             fromContext:self];
}

- (id<LLZServiceProtocol> _Nullable)findServiceWithProtocol:(Protocol *)serviceProtocol withName:(nullable NSString *)serviceName {
    return [[LLZService shared] takeOneServiceForProtocol:serviceProtocol withName:serviceName fromContext:self];
}

- (NSArray<id<LLZServiceProtocol>> *)findAllServicesWithProtocol:(Protocol *)serviceProtocol {
    return [[LLZService shared] servicesForProtocol:serviceProtocol
                                       fromContext:self];
}


@end

