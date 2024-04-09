#import "LLZService.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "LLZContext.h"
#include <pthread/pthread.h>
#import "LLZServiceCenter.h"
#include <mach-o/getsect.h>
#include <mach-o/loader.h>
#include <mach-o/dyld.h>
#include <mach-o/ldsyms.h>
#include <dlfcn.h>

@interface LLZService () {
    NSArray<Protocol *> *_serviceProtocolWhiteList;
}

@property (nonatomic, strong) LLZServiceCenter *serviceManager;

@end


@implementation LLZService

+ (instancetype)shared {
    static id shared = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        shared = [[LLZService alloc] init];
    });
    return shared;
}

- (id)init {
    self = [super init];
    if (self) {
        _serviceManager = [[LLZServiceCenter alloc] init];
    }
    return self;
}

#pragma mark - white list

- (void)setServiceWhiteList:(NSArray<Protocol *> *)protocolWhiteList {
    _serviceProtocolWhiteList = protocolWhiteList;
}

- (void)registerServiceImplStr:(NSString *)serviceImplStr {
    [self.serviceManager registerAllServicesWithImplClassStr:serviceImplStr];
}

//注册服务
- (void)registerServiceImplStr:(NSString *)serviceImplStr
                forProtocolStr:(NSString *)serviceProtocolStr {
    [self.serviceManager registerServiceOfProtocolStr:serviceProtocolStr withImplClassStr:serviceImplStr];
}

- (void)registerServiceImplClass:(Class)serviceImplClass
                     forProtocol:(Protocol *)serviceProtocol {
    [self.serviceManager registerServiceOfProtocol:serviceProtocol withImplClass:serviceImplClass];
}

- (id<LLZServiceProtocol>)takeOneServiceForProtocol:(Protocol *)serviceProtocol
                                        fromContext:(nullable id<LLZContextProtocol>)context {
    return [self takeOneServiceForProtocol:serviceProtocol withName:nil fromContext:context];
}

- (id<LLZServiceProtocol>)takeOneServiceForProtocol:(Protocol *)serviceProtocol withName:(NSString *)serviceName fromContext:(id<LLZContextProtocol>)context {
    if (_serviceProtocolWhiteList && _serviceProtocolWhiteList.count > 0) {
        if (![_serviceProtocolWhiteList containsObject:serviceProtocol]) {
            return nil;
        }
    }
    id<LLZServiceProtocol> service = [self.serviceManager serviceOfProtocol:serviceProtocol withName:serviceName fromContext:context];
    if(service == nil) {
    // 未找到已注册的实现类
        NSLog(@"service [%@] not found", NSStringFromProtocol(serviceProtocol));// 错误日志
    }
    
    return service;
}

- (NSArray<id<LLZServiceProtocol>> *)servicesForProtocol:(Protocol *)serviceProtocol fromContext:(nullable id<LLZContextProtocol>)context {
    return [self servicesForProtocol:serviceProtocol withName:nil fromContext:context];
}

- (NSArray<id<LLZServiceProtocol>> *)servicesForProtocol:(Protocol *)serviceProtocol withName:(nullable NSString *)serviceName
                                             fromContext:(nullable id<LLZContextProtocol>)context {
    if (_serviceProtocolWhiteList && _serviceProtocolWhiteList.count > 0) {
        if (![_serviceProtocolWhiteList containsObject:serviceProtocol]) {
            return nil;
        }
    }
    NSArray<id<LLZServiceProtocol>> *services = [self.serviceManager servicesOfProtocol:serviceProtocol withName:serviceName fromContext:context];
    if(services == nil){
        // 未找到已注册的实现类
        NSLog(@"service [%@] not found", NSStringFromProtocol(serviceProtocol));// 错误日志
    }
    return services;
}

NSArray<NSString *>* LoadAnnotationData(char *sectionName,const struct mach_header *mhp);
static void dyld_callback(const struct mach_header *mhp, intptr_t vmaddr_slide) {
    //解析SEG_DATA中标注的service
    NSArray *servicesEX = LoadAnnotationData("ShareHandlers", mhp);
    for (NSString *service in servicesEX) {
        if (!service || service.length <= 0) {
            continue;
        }
        NSArray<NSString *> *serviceArray = [service componentsSeparatedByString:@","];
        if (serviceArray.count == 2) {
            [[LLZService shared] registerServiceImplStr:serviceArray[0]
                                        forProtocolStr:serviceArray[1]];
        }
    }
}

__attribute__((constructor))
void init(void) {

    _dyld_register_func_for_add_image(dyld_callback);
}

//解析SEG_DATA中标注的内容
NSArray<NSString *>* LoadAnnotationData(char *sectionName, const struct mach_header *mhp) {
    NSMutableArray *annotationList = [NSMutableArray array];
    unsigned long size = 0;
#ifndef __LP64__
    uintptr_t *memory = (uintptr_t*)getsectiondata(mhp, SEG_DATA, sectionName, &size);
#else
    const struct mach_header_64 *mhp64 = (const struct mach_header_64 *)mhp;
    uintptr_t *memory = (uintptr_t*)getsectiondata(mhp64, SEG_DATA, sectionName, &size);
#endif
    
    unsigned long count = size/sizeof(void*);
    for(int idx = 0; idx < count; ++idx) {
        char *string = (char*)memory[idx];
        NSString *str = [NSString stringWithUTF8String:string];
        if(str == nil)
            continue;
        [annotationList addObject:str];
    }
    return annotationList;
}

@end
