//
//  LLZContext.h
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LLZServiceProtocol;

///上下文协议
@protocol LLZContextProtocol <NSObject>

@end



///模块上下文
@interface LLZModuleContext : NSObject<LLZContextProtocol>

///模块名称
@property (nonatomic, copy, readonly) NSString *moduleName;

/// 查找服务实现
/// @param serviceProtocol 需要查找实现的服务协议
/// @return 返回找到的服务实现
- (id)findServiceWithProtocol:(Protocol *)serviceProtocol;

/// 通过服务协议和服务名称查找服务实现
/// @param serviceProtocol - 服务协议
/// @param serviceName - 服务名称，唯一标识
- (id<LLZServiceProtocol> _Nullable)findServiceWithProtocol:(Protocol *)serviceProtocol withName:(nullable NSString *)serviceName;

/// 查找所有服务实现
/// @param serviceProtocol 需要查找实现的服务协议
/// @return 返回找到的所有服务实现
- (NSArray *)findAllServicesWithProtocol:(Protocol *)serviceProtocol;

@end

NS_ASSUME_NONNULL_END
