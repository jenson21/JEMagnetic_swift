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
    func refreshMagneticWithType(_ type: MagneticType, animation aAnimation: UITableView.RowAnimation)
    ///刷新指定类型的磁片
    func refreshMagneticWithType(_ type: MagneticType)
    ///刷新指定类型磁片的数据源
    func refreshMagneticWithType(_ type: MagneticType, json ajson: Any)
    /// 添加指定Section磁片
    /// - Parameters:
    ///   - magneticType: 磁片类型
    ///   - magneticContext: 刷新数据模型
    ///   - magneticController: 刷新controller
    ///   - index: 指定位置
    ///   - animation: animation
    func addSectionWithType(_ magneticType: MagneticType, withMagneticContext magneticContext: MagneticContext, withMagneticController magneticController: MagneticController, index aIndex: Int, animation aAnimation: UITableView.RowAnimation)
    /// 删除指定Section磁片
    /// - Parameters:
    ///   - magneticType: 磁片类型
    ///   - index: 指定位置
    ///   - animation: animation
    func deleteSectionWithType(_ magneticType: MagneticType, index aIndex: Int, animation aAnimation: UITableView.RowAnimation)
    ///通用参数字典。用于请求参数、统计埋点等。
    func generalParameters() -> NSDictionary
}


extension MagneticControllerProtocol{
    
    func generalParameters() -> NSDictionary{
        return NSDictionary()
    }
    
}
