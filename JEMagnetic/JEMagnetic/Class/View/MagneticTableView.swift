//
//  MagneticTableView.swift
//  JEMagnetic
//
//  Created by Jenson on 2021/4/10.
//  Copyright © 2021 Jenson. All rights reserved.
//

import UIKit

let HEIGHT_ERROR = 120.0


class MagneticTableView: UITableView {
    
    /*-------------------Demo---------------------*/
    
    //MARK: 声明，构造
    ///列
    var column = 0
    ///磁片控制器数组
    var magneticControllersArrayT: [MagneticController] = [MagneticController]()
    ///磁片集
    weak var magneticsController: MagneticsController?
    
    ///更新指定section缓存并刷新
    func reloadSection(section: Int) {
    }
    ///更新指定section组缓存并刷新
    func reloadSections(sections: Array<Any>) {
    }
    //MARK: 初始化 init
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.backgroundColor = .white
        self.separatorStyle = .none
        self.delaysContentTouches = false
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: func
    override func reloadData() {
        for i in 0...self.magneticControllersArrayT.count {
            setupCacheDataWithSection(i)
        }
        super.reloadData()
    }
    
    func reloadSections(_ sections: Array<Int>) {
        for i in sections {
            setupCacheDataWithSection(i)
        }
        super.reloadData()
    }
    
    func reloadSection(_ section: Int) {
        setupCacheDataWithSection(section)
        super.reloadData()
    }
    
    override func reloadSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
        
        for (idx, _) in sections.enumerated() {
            setupCacheDataWithSection(idx)
        }
        super.reloadSections(sections, with: animation)
    }
    
    override func insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        let sections: NSMutableIndexSet = NSMutableIndexSet()
        for indexPath in indexPaths {
            sections.add(indexPath.section)
        }
        for (idx, _) in sections.enumerated() {
            setupCacheDataWithSection(idx)
        }
        super.insertRows(at: indexPaths, with: animation)
    }
    
    override func insertSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
        for (idx, _) in sections.enumerated() {
            setupCacheDataWithSection(idx)
        }
        super.insertSections(sections, with: animation)
    }
    
    //MARK: 生命周期
    
    //MARK: 网络请求
    
    //MARK: Event
}

extension MagneticTableView {
    // MARK: - Cache
    //重置指定section的缓存数据
    func setupCacheDataWithSection(_ section: Int) {
        guard section >= 0, section < magneticControllersArrayT.count else {
            return
        }
        let magneticsController: MagneticsController = delegate as! MagneticsController
        let magneticController: MagneticController = magneticControllersArrayT[section]
        
        //是否显示错误视图
        magneticController.showMagneticError = false
        if magneticController.magneticContext.error != nil {
            if let showMagneticError: Bool = magneticController.magneticsController(magneticsController: magneticsController, shouldShowMagneticErrorWithCode: MagneticErrorCode(rawValue: magneticController.magneticContext.error!.code)!) {
                magneticController.showMagneticError = showMagneticError
            }
        }
        
        //是否显示头部视图
        magneticController.showMagneticHeader = false
        if let showMagneticHeader: Bool = magneticController.magneticsController(magneticsController: magneticsController, shouldShowMagneticHeaderInTableView: self) {
            magneticController.showMagneticHeader = showMagneticHeader
        }
        
        //显示错误视图时隐藏头部视图
        if magneticController.showMagneticError == true {
            magneticController.showMagneticHeader = false
        }
        
        //是否显示尾部视图
        magneticController.showMagneticFooter = false
        if let showMagneticFooter: Bool = magneticController.magneticsController(magneticsController: magneticsController, shouldShowMagneticFooterInTableView: self) {
            magneticController.showMagneticFooter = showMagneticFooter
        }
        
        //显示错误视图时隐藏尾部视图
        if magneticController.showMagneticError == true {
            magneticController.showMagneticFooter = false
        }
        
        //是否显示磁片间距
        magneticController.showMagneticSpacing = false
        
        var magneticSpacing = 0.0
        if  let magneticSpacingV: CGFloat = magneticController.magneticsController(magneticsController: magneticsController, heightForMagneticSpacingInTableView: self) {
            magneticSpacing = Double(magneticSpacingV)
            if magneticSpacing <= 0.1 {
                magneticSpacing = 0.0
            }
        }
        
        if magneticSpacing > 0 {
            magneticController.showMagneticSpacing = true
        }
        
        //行数缓存
        magneticController.extensionRowIndex = 0
        var rowCount = 0
        if magneticController.magneticContext.error != nil {//数据错误
            if magneticController.showMagneticError == true {//显示错误视图
                rowCount += 1
            }
        } else {//数据正常
            //内容行数
            let count = magneticController.magneticsController(magneticsController: magneticsController, rowCountForMagneticContentInTableView: self)
            if count > 0 {
                rowCount += count
            }
        }
        
        //有可显示的数据
        if rowCount > 0 {
            if magneticController.showMagneticHeader == true { rowCount += 1 } //显示头部视图
            if magneticController.showMagneticFooter == true { rowCount += 1 } //显示尾部视图
            if magneticController.showMagneticSpacing == true { rowCount += 1 } //显示磁片间距
        }
        
        magneticController.rowCountCache = rowCount
        
        //行高缓存
        var rowHeights: [Double] = []
        for row in 0...rowCount {
            var rowHeight = 0.0
            //磁片间距
            let isMagneticSpacing = (magneticController.showMagneticSpacing && row == rowCount - 1)
            //头部视图
            let isMagneticHeader = (magneticController.showMagneticHeader && row == 0)
            //尾部视图
            var isMagneticFooter = false
            if magneticController.showMagneticFooter == true {
                if magneticController.showMagneticSpacing && row == rowCount - 2 {
                    isMagneticFooter = true
                }
                if !magneticController.showMagneticSpacing && row == rowCount - 1 {
                    isMagneticFooter = true
                }
            }
            
            if isMagneticSpacing == true {//磁片间距
                rowHeight = magneticSpacing
            } else if isMagneticHeader == true {//头部视图
                if let rowH = magneticController.magneticsController(magneticsController: magneticsController, heightForMagneticHeaderInTableView: self) {
                    rowHeight = Double(rowH)
                }
            } else if isMagneticFooter == true { //尾部视图
                if let rowH = magneticController.magneticsController(magneticsController: magneticsController, heightForMagneticFooterInTableView: self) {
                    rowHeight = Double(rowH)
                }
            } else {
                if magneticController.showMagneticError == true { //错误视图
                    rowHeight = HEIGHT_ERROR
                } else { //数据源
                    if row < magneticController.extensionRowIndex { //磁片内容
                        //数据源对应的index
                        let rowIndex = magneticController.showMagneticHeader ? row - 1 : row
                        rowHeight = Double(magneticController.magneticsController(magneticsController: magneticsController, rowHeightForMagneticContentAtIndex: rowIndex))
                    } else {//磁片扩展
                        //数据源对应的index
                        let rowIndex = row - magneticController.extensionRowIndex
                        rowHeight = Double(magneticController.extensionController?.magneticsController(magneticsController: magneticsController, rowHeightForMagneticContentAtIndex: rowIndex) ?? 0.0)
                    }
                }
            }
            rowHeights.append(rowHeight)
        }
        magneticController.rowHeightsCache = rowHeights
    }
}
