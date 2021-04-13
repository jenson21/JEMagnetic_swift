//
//  JEHttpManager.swift
//  JEMagnetic
//
//  Created by Jenson on 2021/4/14.
//  Copyright © 2021 Jenson. All rights reserved.
//

import Foundation

class JEHttpManager: NSObject {
    
    /// 请求
    /// @param requestType 请求类型
    /// @param url 全路径
    /// @param parameters 请求参数
    /// @param success 成功回调
    /// @param failure 失败回调
    
    
    /// 请求
    /// - Parameters:
    ///   - aRequestType: 请求类型
    ///   - aRequestUrl: url 全路径
    ///   - aParameters: 请求参数
    ///   - aSuccess: 成功回调
    ///   - aFailure: 失败回调
    /// - Returns: description
    static func requestType(requestType aRequestType: Int, requestUrl aRequestUrl: String, parameters aParameters: NSDictionary, success aSuccess: (_ aResponseObject: Any) -> (), failure aFailure: (_ error: Any) -> () ) {
        
    }
    
}
