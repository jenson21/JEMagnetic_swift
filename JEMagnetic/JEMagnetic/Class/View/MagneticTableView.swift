//
//  MagneticTableView.swift
//  JEMagnetic
//
//  Created by Jenson on 2021/4/10.
//  Copyright © 2021 Jenson. All rights reserved.
//

import UIKit

class MagneticTableView: UITableView {
    
    /*-------------------Demo---------------------*/
    
    //MARK: 声明，构造
    ///列
    var column = 0
    ///磁片控制器数组
    weak var magneticControllersArray: NSMutableArray? = [MagneticController]() as? NSMutableArray
    ///磁片集
    weak var magneticsController: MagneticsController?
    
    ///更新指定section缓存并刷新
    func reloadSection(section: Int) {
    }
    ///更新指定section组缓存并刷新
    func reloadSections(sections: Array<Any>) {
    }
    //MARK: 初始化 init
    
    //MARK: func
    
    //MARK: 生命周期
    
    //MARK: 网络请求
    
    //MARK: Event
}
