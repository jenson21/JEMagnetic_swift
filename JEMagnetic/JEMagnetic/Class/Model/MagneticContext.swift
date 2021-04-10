//
//  MagneticContext.swift
//  JEMagnetic
//
//  Created by Jenson on 2021/4/10.
//  Copyright © 2021 Jenson. All rights reserved.
//

import Foundation

//MARK: 磁片类型
enum MagneticType: Int {
    case typeclass = 0
}

//MARK: 磁片状态
enum MagneticState: Int {
    ///默认状态
    case MagneticStateNormal            = 0
    ///加载状态
    case MagneticStateLoading           = 1
    ///错误状态
    case MagneticStateError             = 2
}

//MARK: 磁片错误类型
enum MagneticErrorCode: Int {
    ///无错误
    case MagneticErrorCodeNone          = 0
    ///网络错误
    case MagneticErrorCodeNetwork       = -5500
    ///数据错误
    case MagneticErrorCodeFailed        = -5501
}

class MagneticHeaderContext: NSObject {
    weak var magneticContext: MagneticContext?
}

class MagneticContext: NSObject {
    
    //MARK: 声明，构造
    
    ///header
    private var _headerContext: MagneticHeaderContext?
    var headerContext: MagneticHeaderContext? {
        get{_headerContext!}
        set(newHeaderContext){
            if _headerContext != newHeaderContext {
                _headerContext = newHeaderContext
                _headerContext?.magneticContext = self
            }
        }
    }
    ///磁片控制器Class
    var clazz: String?
    ///组件id
    var magneticId: String?
    ///磁片顺序
    var magneticIndex = 0
    ///是否支持加载更多
    var hasMore = false
    ///是否异步请求
    var asyncLoad = false
    var currentIndex = 0
    ///类型
    private var _type: MagneticType?
    var type: MagneticType {
        get{_type!}
        set(newType){
            if _type != newType {
                _type = newType
                self.clazz = parseClassName(type: _type!)
            }
        }
    }
    ///状态
    var state: MagneticState?
    ///磁片信息（CMS配置的原始数据）
    var magneticInfo = [String: String]()
    ///数据源,可为model
    private var _json: AnyObject?
    var json: AnyObject? {
        get{_json!}
        set(newJson){
            _json = newJson
            self.error = nil
        }
    }
    
    ///错误
    private var _error: NSError?
    var error: NSError? {
        get{_error!}
        set(newError){
            if _error != newError {
                _error = newError
                self.state = (_error! as! Bool) ? .MagneticStateError : .MagneticStateNormal
            }
        }
    }
    
    
    /*-------------------Extension---------------------*/
    //MARK: 扩展区
    
    ///扩展区类型
    private var _extensionType: MagneticType?
    var extensionType: MagneticType? {
        get{_extensionType!}
        set(newExtensionType){
            if extensionType != newExtensionType {
                _extensionType = newExtensionType
                self.extensionClazz = parseClassName(type: _extensionType!)
            }
        }
    }
    ///扩展控制器Class
    var extensionClazz: String?
    // 那个模块的推荐
    var modular: String?
    // 当前模块在列表中的偏移量
    var cardOffetY = 0.0
    // 数据源是否更改
    var isChange = false
    
}

//MARK: func
extension MagneticContext{
   
    /*-------------------Parse---------------------*/
    func parseClassName(type: MagneticType) -> String? {
        var className: String? = nil
        switch type {
        case .typeclass:
            className = "typeclass"
            break
        default:break
        }
        
        return className
        
    }
    
}
