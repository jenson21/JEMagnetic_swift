//
//  MagneticsControllerProtocol.swift
//  JEMagnetic
//
//  Created by Jenson on 2021/4/10.
//  Copyright © 2021 Jenson. All rights reserved.
//

import UIKit

enum RequestType: Int {
    case RequestTypeGet     = 0
    case RequestTypePost    = 1
    case RequestTypePut     = 2
    case RequestTypeDelete  = 3
    case RequestTypeHeade   = 4
}

protocol MagneticsControllerProtocol: AnyObject {
    
    
    /*-------------------Magnetic Content---------------------*/
    //MARK: 磁片内容
    
    ///内容行数
    func magneticsController(magneticsController aMagneticsController: MagneticsController, rowCountForMagneticContentInTableView tableView: MagneticTableView!) -> Int
    ///内容行高
    func magneticsController(magneticsController aMagneticsController: MagneticsController, rowHeightForMagneticContentAtIndex index: Int) -> CGFloat
    ///复用内容视图
    func magneticsController(magneticsController aMagneticsController: MagneticsController, reuseCell cell: UITableViewCell, forMagneticContentAtIndex index: Int)

    
    /*-------------------Magnetic Content---------------------*/
    //MARK: 磁片内容

    ///内容视图Class。默认为UITableViewCell。
    func magneticsController(magneticsController aMagneticsController: MagneticsController, cellClassForMagneticContentAtIndex index: Int) -> UITableViewCell
    ///内容视图复用标识符。默认为"CellClass_MagneticType"的形式。
    func magneticsController(magneticsController aMagneticsController: MagneticsController, cellIdentifierForMagneticContentAtIndex index: Int) -> String
    ///点击内容事件
    func magneticsController(magneticsController aMagneticsController: MagneticsController, didSelectMagneticContentAtIndex index: Int)
    ///内容将显示
    func magneticsController(magneticsController aMagneticsController: MagneticsController, willDisplayCell cell: UITableViewCell, forMagneticContentAtIndex index: Int)
    ///内容已隐藏
    func magneticsController(magneticsController aMagneticsController: MagneticsController, didEndDisplayingCell cell: UITableViewCell, forMagneticContentAtIndex index: Int)
    ///头部将要显示
    func magneticsController(magneticsController aMagneticsController: MagneticsController, willDisplayingHeaderCell cell: UITableViewCell)
    ///头部已隐藏
    func magneticsController(magneticsController aMagneticsController: MagneticsController, didEndDisplayingHeaderCell cell: UITableViewCell)
    
    
    /*-------------------Suspend Header---------------------*/
    //MARK: 顶部悬浮视图
    
    ///悬浮视图高度。默认为0.0。
    func magneticsController(magneticsController aMagneticsController: MagneticsController, heightForSuspendHeaderInTableView tableView: MagneticTableView) -> CGFloat
    ///悬浮视图。默认为nil。
    func magneticsController(magneticsController aMagneticsController: MagneticsController, viewForSuspendHeaderInTableView tableView: MagneticTableView) -> UIView
    
    
    /*-------------------Magnetic Header---------------------*/
    //MARK: 磁片头部
    
    ///是否显示头部视图。默认为false。
    func magneticsController(magneticsController aMagneticsController: MagneticsController, shouldShowMagneticHeaderInTableView tableView: MagneticTableView) -> Bool
    ///头部行高
    func magneticsController(magneticsController aMagneticsController: MagneticsController, heightForMagneticHeaderInTableView tableView: MagneticTableView) -> CGFloat
    ///头部视图Class。默认为UITableViewCell。
    func magneticsController(magneticsController aMagneticsController: MagneticsController, cellClassForMagneticHeaderInTableView tableView: MagneticTableView) -> UITableViewCell
    ///头部视图复用标识符。默认为"CellClass_MagneticType"的形式。
    func magneticsController(magneticsController aMagneticsController: MagneticsController, cellIdentifierForMagneticHeaderInTableView tableView: MagneticTableView) -> String
    ///复用头部视图
    func magneticsController(magneticsController aMagneticsController: MagneticsController, reuseCell cell: UITableViewCell, cellIdentifierForMagneticHeaderInTableView tableView: MagneticTableView)
    ///点击头部事件
    func magneticsController(magneticsController aMagneticsController: MagneticsController, didSelectMagneticHeaderInTableView tableView: MagneticTableView)
    
    
    /*-------------------Magnetic Footer---------------------*/
    //MARK: 磁片尾部
    
    ///是否显示尾部视图。默认为NO。
    func magneticsController(magneticsController aMagneticsController: MagneticsController, shouldShowMagneticFooterInTableView tableView: MagneticTableView) -> Bool
    ///尾部行高
    func magneticsController(magneticsController aMagneticsController: MagneticsController, heightForMagneticFooterInTableView tableView: MagneticTableView) -> CGFloat
    ///尾部视图Class。默认为UITableViewCell。
    func magneticsController(magneticsController aMagneticsController: MagneticsController, cellClassForMagneticFooterInTableView tableView: MagneticTableView) -> UITableViewCell
    ///尾部视图复用标识符。默认为"CellClass_MagneticType"的形式。
    func magneticsController(magneticsController aMagneticsController: MagneticsController, cellIdentifierForMagneticFooterInTableView tableView: MagneticTableView) -> String
    ///复用尾部视图
    func magneticsController(magneticsController aMagneticsController: MagneticsController, reuseCell cell: UITableViewCell, forMagneticFooterInTableView tableView: MagneticTableView)
    ///点击尾部事件
    func magneticsController(magneticsController aMagneticsController: MagneticsController, didSelectMagneticFooterInTableView tableView: MagneticTableView)
    
    
    /*-------------------Magnetic Spacing---------------------*/
    //MARK: 磁片底部间距
    
    ///磁片间距大小。默认为0.0，当高度为0.0时无间距（不占用cell）。
    func magneticsController(magneticsController aMagneticsController: MagneticsController, heightForMagneticSpacingInTableView tableView: MagneticTableView) -> CGFloat
    ///磁片间距颜色。默认为透明。
    func magneticsController(magneticsController aMagneticsController: MagneticsController, colorForMagneticSpacingInTableView tableView: MagneticTableView) -> UIColor
    ///复用磁片底部间距视图
    func magneticsController(magneticsController aMagneticsController: MagneticsController, reuseCell cell: UITableViewCell, forMagneticSpaingInTableView tableView: MagneticTableView)
    ///磁片颜色。
    func magneticsController(magneticsController aMagneticsController: MagneticsController, colorForMagneticBackgroundInTableView tableView: MagneticTableView) -> UIColor
    
    
    /*-------------------Magnetic Error---------------------*/
    //MARK: 磁片错误
    
    ///是否显示磁片错误提示。默认为false。
    func magneticsController(magneticsController aMagneticsController: MagneticsController, shouldShowMagneticErrorWithCode errorCode: MagneticErrorCode) -> Bool
    ///是否忽略磁片错误。默认为false。
    func magneticsController(magneticsController aMagneticsController: MagneticsController, shouldIgnoreMagneticErrorWithCode errorCode: MagneticErrorCode) -> Bool
    ///磁片错误描述。默认为"获取失败 点击重试"。
    func magneticsController(magneticsController aMagneticsController: MagneticsController, errorDescriptionWithCode errorCode: MagneticErrorCode) -> NSAttributedString
        
    
    /*-------------------Life Circle---------------------*/
    //MARK: 生命周期
    
    ///完成初始化监听
    func didFinishInitConfigurationInMagneticsController(magneticsController aMagneticsController: MagneticsController)
    ///磁片父控制器将显示
    func magneticsController(magneticsController aMagneticsController: MagneticsController, superViewWillAppear superViewController: UIViewController)
    ///磁片父控制器已隐藏
    func magneticsController(magneticsController aMagneticsController: MagneticsController, superViewDidDisappear superViewController: UIViewController)
    
    
    /*-------------------Scroll---------------------*/
    //MARK: 滚动监听（需开启页面滚动监听开关observeScrollEvent）
    
    ///向可见磁片发送列表滚动事件（同一个磁片只接收一次回调）
    func magneticsController(magneticsController aMagneticsController: MagneticsController, didScrollVisibleCellsInTableView tableView: MagneticTableView)
    ///向可见磁片发送每个cell的滚动事件
    func magneticsController(magneticsController aMagneticsController: MagneticsController, didScrollVisibleCell cell: UITableViewCell, forMagneticContentAtIndex index: Int)
    ///向可见磁片发送列表滚动停止事件（同一个磁片只接收一次回调）
    func magneticsController(magneticsController aMagneticsController: MagneticsController, didEndScrollingVisibleCellsInTableView tableView: MagneticTableView)
    ///列表滚动停止时，向可见磁片发送每个cell的曝光百分比
    func magneticsController(magneticsController aMagneticsController: MagneticsController, didEndScrollingVisibleCell cell: UITableViewCell, exposeFromPercent fromPercent: Int, toPercentValue toPercent: Int, forMagneticContentAtIndex index: Int)
    ///向当前视图可见磁片透传scrollView scrollViewWillBeginDragging代理
    func magneticsController(magneticsController aMagneticsController: MagneticsController, scrollViewWillBeginDraggingForCell cell: UITableViewCell)
    ///向当前视图可见磁片发送停止事件
    func magneticsController(magneticsController aMagneticsController: MagneticsController, didEndScrollingForCell cell: UITableViewCell)
    ///向当前视图可见磁片发送滑动动画事件
    func magneticsController(magneticsController aMagneticsController: MagneticsController, didScrollForCell cell: UITableViewCell)
    
    
    /*-------------------Request More---------------------*/
    //MARK: 加载更多（属性canRequestMoreData为true的磁片可响应）
    
    ///触发加载更多事件监听
    func didTriggerRequestMoreDataActionInMagneticsController(magneticsController aMagneticsController: MagneticsController)
    
    
    /*-------------------Single Magnetic Request---------------------*/
    //MARK: 单磁片请求
    
    ///单磁片网络请求结束，包括成功or失败
    func magneticRequestDidFinishInMagneticsController(magneticsController aMagneticsController: MagneticsController)
    ///网络请求类型，默认get
    func magneticRequestTypeInMagneticsController(magneticsController aMagneticsController: MagneticsController) ->RequestType
    ///请求的url, 异步请求必须实现
    func magneticRequestURLInMagneticsController(magneticsController aMagneticsController: MagneticsController) ->String
    ///请求的参数
    func magneticRequestParametersInMagneticsController(magneticsController aMagneticsController: MagneticsController) -> NSDictionary
    ///解析数据源的model,异步请求必须实现
    func magneticRequestParserModelClassInMagneticsController(magneticsController aMagneticsController: MagneticsController) ->AnyClass
    
    
    /*-------------------Expose---------------------*/
    //MARK: 埋点上报
    
    func magneticsController(magneticsController aMagneticsController: MagneticsController, exposureforMagneticHeaderAtIndex index: Int) -> Array<Any>
    
    func magneticsController(magneticsController aMagneticsController: MagneticsController, exposureforMagneticFooterAtIndex index: Int) -> Array<Any>

    func magneticsController(magneticsController aMagneticsController: MagneticsController, exposureforMagneticContentAtIndex index: Int) -> Array<Any>
    
}

extension MagneticsControllerProtocol{

    /*-------------------Magnetic Content---------------------*/
    //MARK: 磁片内容

    func magneticsController(magneticsController aMagneticsController: MagneticsController, cellClassForMagneticContentAtIndex index: Int) -> UITableViewCell{UITableViewCell()}
    func magneticsController(magneticsController aMagneticsController: MagneticsController, cellIdentifierForMagneticContentAtIndex index: Int) -> String{""}
    func magneticsController(magneticsController aMagneticsController: MagneticsController, didSelectMagneticContentAtIndex index: Int){}
    func magneticsController(magneticsController aMagneticsController: MagneticsController, willDisplayCell cell: UITableViewCell, forMagneticContentAtIndex index: Int){}
    func magneticsController(magneticsController aMagneticsController: MagneticsController, didEndDisplayingCell cell: UITableViewCell, forMagneticContentAtIndex index: Int){}
    func magneticsController(magneticsController aMagneticsController: MagneticsController, willDisplayingHeaderCell cell: UITableViewCell){}
    func magneticsController(magneticsController aMagneticsController: MagneticsController, didEndDisplayingHeaderCell cell: UITableViewCell){}
    
    
    /*-------------------Suspend Header---------------------*/
    //MARK: 顶部悬浮视图
    
    func magneticsController(magneticsController aMagneticsController: MagneticsController, heightForSuspendHeaderInTableView tableView: MagneticTableView) -> CGFloat{0.0}
    func magneticsController(magneticsController aMagneticsController: MagneticsController, viewForSuspendHeaderInTableView tableView: MagneticTableView) -> UIView{return UIView()}
    
    
    /*-------------------Magnetic Header---------------------*/
    //MARK: 磁片头部
    
    func magneticsController(magneticsController aMagneticsController: MagneticsController, shouldShowMagneticHeaderInTableView tableView: MagneticTableView) -> Bool{false}
    func magneticsController(magneticsController aMagneticsController: MagneticsController, heightForMagneticHeaderInTableView tableView: MagneticTableView) -> CGFloat{0.0}
    func magneticsController(magneticsController aMagneticsController: MagneticsController, cellClassForMagneticHeaderInTableView tableView: MagneticTableView) -> UITableViewCell{UITableViewCell()}
    func magneticsController(magneticsController aMagneticsController: MagneticsController, cellIdentifierForMagneticHeaderInTableView tableView: MagneticTableView) -> String{""}
    func magneticsController(magneticsController aMagneticsController: MagneticsController, reuseCell cell: UITableViewCell, cellIdentifierForMagneticHeaderInTableView tableView: MagneticTableView){}
    func magneticsController(magneticsController aMagneticsController: MagneticsController, didSelectMagneticHeaderInTableView tableView: MagneticTableView){}
    
    
    /*-------------------Magnetic Footer---------------------*/
    //MARK: 磁片尾部
    
    func magneticsController(magneticsController aMagneticsController: MagneticsController, shouldShowMagneticFooterInTableView tableView: MagneticTableView) -> Bool{false}
    func magneticsController(magneticsController aMagneticsController: MagneticsController, heightForMagneticFooterInTableView tableView: MagneticTableView) -> CGFloat{0.0}
    func magneticsController(magneticsController aMagneticsController: MagneticsController, cellClassForMagneticFooterInTableView tableView: MagneticTableView) -> UITableViewCell{UITableViewCell()}
    func magneticsController(magneticsController aMagneticsController: MagneticsController, cellIdentifierForMagneticFooterInTableView tableView: MagneticTableView) -> String{""}
    func magneticsController(magneticsController aMagneticsController: MagneticsController, reuseCell cell: UITableViewCell, forMagneticFooterInTableView tableView: MagneticTableView){}
    func magneticsController(magneticsController aMagneticsController: MagneticsController, didSelectMagneticFooterInTableView tableView: MagneticTableView){}
    
    
    /*-------------------Magnetic Spacing---------------------*/
    //MARK: 磁片底部间距
    
    func magneticsController(magneticsController aMagneticsController: MagneticsController, heightForMagneticSpacingInTableView tableView: MagneticTableView) -> CGFloat{0.0}
    func magneticsController(magneticsController aMagneticsController: MagneticsController, colorForMagneticSpacingInTableView tableView: MagneticTableView) -> UIColor{UIColor()}
    func magneticsController(magneticsController aMagneticsController: MagneticsController, reuseCell cell: UITableViewCell, forMagneticSpaingInTableView tableView: MagneticTableView){}
    func magneticsController(magneticsController aMagneticsController: MagneticsController, colorForMagneticBackgroundInTableView tableView: MagneticTableView) -> UIColor{UIColor()}
    
    
    /*-------------------Magnetic Error---------------------*/
    //MARK: 磁片错误
    
    func magneticsController(magneticsController aMagneticsController: MagneticsController, shouldShowMagneticErrorWithCode errorCode: MagneticErrorCode) -> Bool{false}
    func magneticsController(magneticsController aMagneticsController: MagneticsController, shouldIgnoreMagneticErrorWithCode errorCode: MagneticErrorCode) -> Bool{false}
    func magneticsController(magneticsController aMagneticsController: MagneticsController, errorDescriptionWithCode errorCode: MagneticErrorCode) -> NSAttributedString{NSAttributedString()}
        
    
    /*-------------------Life Circle---------------------*/
    //MARK: 生命周期
    
    func didFinishInitConfigurationInMagneticsController(magneticsController aMagneticsController: MagneticsController){}
    func magneticsController(magneticsController aMagneticsController: MagneticsController, superViewWillAppear superViewController: UIViewController){}
    func magneticsController(magneticsController aMagneticsController: MagneticsController, superViewDidDisappear superViewController: UIViewController){}
    
    
    /*-------------------Scroll---------------------*/
    //MARK: 滚动监听（需开启页面滚动监听开关observeScrollEvent）
    
    func magneticsController(magneticsController aMagneticsController: MagneticsController, didScrollVisibleCellsInTableView tableView: MagneticTableView){}
    func magneticsController(magneticsController aMagneticsController: MagneticsController, didScrollVisibleCell cell: UITableViewCell, forMagneticContentAtIndex index: Int){}
    func magneticsController(magneticsController aMagneticsController: MagneticsController, didEndScrollingVisibleCellsInTableView tableView: MagneticTableView){}
    func magneticsController(magneticsController aMagneticsController: MagneticsController, didEndScrollingVisibleCell cell: UITableViewCell, exposeFromPercent fromPercent: Int, toPercentValue toPercent: Int, forMagneticContentAtIndex index: Int){}
    func magneticsController(magneticsController aMagneticsController: MagneticsController, scrollViewWillBeginDraggingForCell cell: UITableViewCell){}
    func magneticsController(magneticsController aMagneticsController: MagneticsController, didEndScrollingForCell cell: UITableViewCell){}
    func magneticsController(magneticsController aMagneticsController: MagneticsController, didScrollForCell cell: UITableViewCell){}
    
    
    /*-------------------Request More---------------------*/
    //MARK: 加载更多（属性canRequestMoreData为true的磁片可响应）
    
    func didTriggerRequestMoreDataActionInMagneticsController(magneticsController aMagneticsController: MagneticsController){}
    
    
    /*-------------------Single Magnetic Request---------------------*/
    //MARK: 单磁片请求
    
    func magneticRequestDidFinishInMagneticsController(magneticsController aMagneticsController: MagneticsController){}
    func magneticRequestTypeInMagneticsController(magneticsController aMagneticsController: MagneticsController) ->RequestType{.RequestTypeGet}
    func magneticRequestURLInMagneticsController(magneticsController aMagneticsController: MagneticsController) ->String{""}
    func magneticRequestParametersInMagneticsController(magneticsController aMagneticsController: MagneticsController) -> NSDictionary{NSDictionary()}
    func magneticRequestParserModelClassInMagneticsController(magneticsController aMagneticsController: MagneticsController) ->AnyClass{(Any).self as! AnyClass}
    
    
    /*-------------------Expose---------------------*/
    //MARK: 埋点上报
    
    func magneticsController(magneticsController aMagneticsController: MagneticsController, exposureforMagneticHeaderAtIndex index: Int) -> Array<Any>{Array()}
    func magneticsController(magneticsController aMagneticsController: MagneticsController, exposureforMagneticFooterAtIndex index: Int) -> Array<Any>{Array()}
    func magneticsController(magneticsController aMagneticsController: MagneticsController, exposureforMagneticContentAtIndex index: Int) -> Array<Any>{Array()}
    
}
