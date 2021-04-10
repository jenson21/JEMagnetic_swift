//
//  MagneticControllerProtocol.swift
//  JEMagnetic
//
//  Created by Jenson on 2021/4/10.
//  Copyright © 2021 Jenson. All rights reserved.
//

import UIKit

protocol MagneticControllerProtocol: AnyObject {
    
    ///刷新指定类型的磁片
    func refreshMagneticWithType(type: MagneticType, rowAnimation animation: UITableView.RowAnimation)
    ///刷新指定类型的磁片
    func refreshMagneticWithType(type: MagneticType)
    ///刷新指定类型磁片的数据源
    func refreshMagneticWithType(type: MagneticType, dataJson json: Any)
    /// 添加指定Section磁片
    /// - Parameters:
    ///   - magneticType: 磁片类型
    ///   - magneticContext: 刷新数据模型
    ///   - magneticController: 刷新controller
    ///   - index: 指定位置
    ///   - animation: animation
    func addSectionWithType(magneticType: MagneticType, withMagneticContext magneticContext: MagneticContext, withMagneticController magneticController: MagneticController, withIndex index: Int, withAnimation animation: UITableView.RowAnimation)
    /// 删除指定Section磁片
    /// - Parameters:
    ///   - magneticType: 磁片类型
    ///   - index: 指定位置
    ///   - animation: animation
    func deleteSectionWithType(magneticType: MagneticType, withIndex index: Int, withAnimation animation: UITableView.RowAnimation)
    ///通用参数字典。用于请求参数、统计埋点等。
    func generalParameters() -> NSDictionary
}


extension MagneticControllerProtocol{
    
    func generalParameters() -> NSDictionary{
        return NSDictionary()
    }
    
}