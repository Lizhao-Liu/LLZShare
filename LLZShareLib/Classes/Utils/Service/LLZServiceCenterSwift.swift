//
//  LLZServiceCenter.swift
//  YMMModuleLib
//
//  Created by Lizhao on 2023/3/20.
//

import Foundation

public let Key_UserDefault_OCProtocolMatchingPattern : String = "OCProtocolMatchingPattern"
public let DefaultOCProtocolMatchingPattern : String = "^__C\\.(.*)" 

public extension LLZServiceCenter {

    private static let OCProtocolMatchingPattern: NSRegularExpression = {
        return try! NSRegularExpression(pattern: OCProtocolMatchingPatternStr)
    }()
    
    @objc class var OCProtocolMatchingPatternStr : String {
        set {
            if (try? NSRegularExpression(pattern: newValue)) != nil {
                UserDefaults.standard.set(newValue, forKey: Key_UserDefault_OCProtocolMatchingPattern)
                UserDefaults.standard.synchronize()
            } else {
                LLZModuleLogger.errorLog("error: invalid oc matching pattern \(newValue) trying to be set", extra: nil)
            }
        }
        get {
            UserDefaults.standard.string(forKey: Key_UserDefault_OCProtocolMatchingPattern) ?? DefaultOCProtocolMatchingPattern
        }
    }
        
    // swift传入的Generic.Type类型protocol转换为oc支持的NSProtocol
    class func serviceProtocol<Generic>(of serviceType: Generic.Type) -> Protocol? {
        let serviceTypeName = String(reflecting: serviceType)
        var serviceName = serviceTypeName;
        
        let matches = OCProtocolMatchingPattern.matches(in: serviceTypeName, range: NSRange(location: 0, length: serviceTypeName.utf16.count))
        if let match = matches.first {
          let range = match.range(at:1)
          if let swiftRange = Range(range, in: serviceTypeName) {
           let name = serviceTypeName[swiftRange]
              serviceName = String(name)
          }
        }
        let serviceProtocol:Protocol = NSProtocolFromString(serviceName)!
        return serviceProtocol
    }
    
    // 注册
    func registerService<Service>(of serviceType: Service.Type, withImplClass implClass: AnyClass){
        registerService(of: LLZServiceCenter.serviceProtocol(of: serviceType)!, withImplClass: implClass)
    }
    
    // 发现
    func service<Service>(of serviceType: Service.Type, fromContext context:LLZContextProtocol?) ->Service?{
        let serviceProtocol = LLZServiceCenter.serviceProtocol(of: serviceType)!
        let impl = service(of: serviceProtocol, fromContext: context)
        return impl as? Service
    }
}
