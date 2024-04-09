//
//  LLZServiceManager.h
//
//  Created by Lizhao on 2023/3/6.
//

#import <Foundation/Foundation.h>
#import "LLZContext.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 服务协议

@protocol LLZServiceProtocol <NSObject>

@optional
//协议调用方Context
@property (nonatomic, strong) id<LLZContextProtocol> _Nullable fromContext;
//是否作为单例使用
+ (BOOL)singleton;
//服务名称
- (NSString *)serviceName;

@end

@interface LLZServiceCenter : NSObject

#pragma mark - 服务注册

/// 注册单个服务协议
/// @param serviceImplClass 实现协议的class
/// @param serviceProtocol 需要注册的协议
- (void)registerServiceOfProtocol: (Protocol *)serviceProtocol withImplClass: (Class)serviceImplClass;

/// 注册单个服务协议
/// @param serviceImplStr 实现协议的class 字符串形式
/// @param serviceProtocolStr 需要注册的协议 字符串形式
/// @note 在oc宏方法提前编译注册中使用
- (void)registerServiceOfProtocolStr: (NSString *)serviceProtocolStr withImplClassStr:(NSString *)serviceImplStr;

/// 注册服务实例实现的所有所有继承指定基类协议的服务协议
/// @param baseServiceProtocol 需要注册的服务协议的基协议
/// @param serviceImplClass 服务实例的class
- (void)registerAllServicesOfProtocol:(Protocol * _Nullable)baseServiceProtocol withImplClass:(Class)serviceImplClass;

/// 注册服务实例实现的所有继承ServiceProtocol基类协议的服务协议
/// @param serviceImplStr 服务实例名称，字符串形式
/// @note 在oc宏方法提前编译注册中使用
- (void)registerAllServicesWithImplClassStr: (NSString *)serviceImplStr;


#pragma mark - 服务发现

/// 通过模块context， 服务名称和服务协议查找唯一服务实例
/// @parameter context 服务所属模块context
/// @parameter serviceProtocol - 服务协议
/// @param serviceName - 服务名称，唯一标识
/// @return 服务实例
- (id<LLZServiceProtocol> _Nullable)serviceOfProtocol:(Protocol *)serviceProtocol withName:(nullable NSString *)serviceName fromContext:(nullable id<LLZContextProtocol>)context;
- (id<LLZServiceProtocol> _Nullable)serviceOfProtocol:(Protocol *)serviceProtocol fromContext:(nullable id<LLZContextProtocol>)context;

/// 通过服务协议和服务名称查找多个服务实例
/// @param serviceProtocol 服务协议
/// @param serviceName 服务名称，唯一标识
/// @param context  调用模块信息
/// @return 服务实例数组
- (NSArray<id<LLZServiceProtocol>> * _Nullable)servicesOfProtocol:(Protocol *)serviceProtocol withName:(nullable NSString *)serviceName fromContext:(nullable id<LLZContextProtocol>)context;
- (NSArray<id<LLZServiceProtocol>> * _Nullable)servicesOfProtocol:(Protocol *)serviceProtocol fromContext:(nullable id<LLZContextProtocol>)context;

@end

NS_ASSUME_NONNULL_END
