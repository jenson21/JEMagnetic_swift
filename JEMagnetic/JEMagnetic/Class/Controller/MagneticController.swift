//
//  MagneticController.swift
//  JEMagnetic
//
//  Created by Jenson on 2021/4/10.
//  Copyright © 2021 Jenson. All rights reserved.
//

import UIKit

class MagneticController: NSObject {
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: 声明，构造
    
    /// 扩展控制器
    var extensionController: MagneticController?
    ///磁片数据源
    var magneticContext: MagneticContext = MagneticContext()
    weak var delegate: MagneticControllerProtocol?
    ///磁片列表控制器
    var magneticsController: MagneticsController?
    ///是否为扩展
    var isExtension: Bool       = false
    ///折叠状态。默认为false。
    var isFold: Bool            = false
    ///是否完成准备，可渲染
    var isPrepared: Bool        = false
    
    /*-------------------Cache---------------------*/
    //MARK: 缓存声明，用于优化表视图性能
    ///是否显示错误视图
    var showMagneticError       = false
    ///是否显示头部视图
    var showMagneticHeader      = false
    ///是否显示尾部视图
    var showMagneticFooter      = false
    ///是否显示磁片间距
    var showMagneticSpacing     = false
    ///行数缓存
    var rowCountCache           = 0
    ///扩展行数起始index
    var extensionRowIndex       = 0
    ///行高缓存
    var rowHeightsCache: Array<Any> = Array()
  
    /*-------------------RequestMore---------------------*/
    //MARK: 加载更多
    ///是否可加载更多。默认为NO。开启后可响应-didTriggerRequestMoreDataActionInMagneticsController:协议。
    var canRequestMoreData = false
    ///请求错误磁片数据
    func requestErrorMagneticData() {
        let errorCode: MagneticErrorCode = MagneticErrorCode(rawValue: (magneticContext.error?.code)!)!
        if errorCode == .MagneticErrorCodeNetwork || errorCode == .MagneticErrorCodeFailed {
            //显示加载状态
            magneticContext.state = .MagneticStateLoading;
//            magneticsController refreshMagneticWithType
            
            //重新请求数据
//            [self.magneticsController requestMagneticDataWithController:self]
        }
    }
    
}



//MARK: MagneticsControllerProtocol
extension MagneticController: MagneticsControllerProtocol{    
    
    /*-------------------Magnetic Content---------------------*/
    ///内容行数
    func magneticsController(magneticsController aMagneticsController: MagneticsController, rowCountForMagneticContentInTableView tableView: MagneticTableView!) -> Int{0}
    ///内容行高
    func magneticsController(magneticsController aMagneticsController: MagneticsController, rowHeightForMagneticContentAtIndex index: Int) -> CGFloat{0.0}
    ///复用内容视图
    func magneticsController(magneticsController aMagneticsController: MagneticsController, reuseCell cell: UITableViewCell, forMagneticContentAtIndex index: Int){
    }
    
    /*-------------------Magnetic Spacing---------------------*/
    ///磁片底部间距
    func magneticsController(magneticsController aMagneticsController: MagneticsController, heightForMagneticSpacingInTableView tableView: MagneticTableView) -> CGFloat? {nil}
    
    /*-------------------Magnetic Error---------------------*/
    ///是否显示磁片错误提示
    func magneticsController(magneticsController aMagneticsController: MagneticsController, shouldShowMagneticErrorWithCode errorCode: MagneticErrorCode) -> Bool? {nil}
    
}
