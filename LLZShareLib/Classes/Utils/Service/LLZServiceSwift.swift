
//
//  LLZServiceSwift.swift
//  YMMModuleLib
//
//  Created by Lizhao on 2023/2/15.
//

import Foundation

// 因为swift协议注册时机问题，swift语言下 LLZService 注册/发现尚未实现

//public extension LLZService {
//
//    func register<Service>(service serviceType: Service.Type, used implClass: AnyClass) {
//        guard implClass is Service else  {
//            assertionFailure("\(implClass) must implement \(serviceType)")
//            return
//        }
//        serviceManager.registerService(of: serviceType, withImplClass: implClass)
//    }
//
//
//    func service<Service>(of serviceType: Service.Type, from context:LLZContextProtocol?) ->Service? {
//        serviceManager.service(of: serviceType, fromContext: context)
//    }
//
//    @objc(registerServicesWithImplClass:)
//    func registerServices(used implClass: AnyClass) {
//        serviceManager.registerAllServices(of: YMMServiceProtocol.self, withImplClass: implClass)
//    }
//
//}
