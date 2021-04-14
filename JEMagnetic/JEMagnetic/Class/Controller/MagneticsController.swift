//
//  MagneticsController.swift
//  JEMagnetic
//
//  Created by Jenson on 2021/4/10.
//  Copyright © 2021 Jenson. All rights reserved.
//

import UIKit

/// 磁片列表刷新方式
struct MagneticsRefreshType: OptionSet{
    let rawValue: Int
    ///无刷新方式
    static let MagneticsRefreshTypeNone                 = 0
    ///下拉刷新
    static let MagneticsRefreshTypePullToRefresh        = MagneticsRefreshType(rawValue: 1 << 0)
    ///上拉加载更多
    static let MagneticsRefreshTypeInfiniteScrolling    = MagneticsRefreshType(rawValue: 1 << 1)
    ///中心加载视图
    static let MagneticsRefreshTypeLoadingView          = MagneticsRefreshType(rawValue: 1 << 2)
}
///磁片数据清除方式
enum MagneticsClearType: Int {
    ///请求前清除
    case MagneticsClearTypeBeforeRequest                = 0
    ///请求后清除
    case MagneticsClearTypeAfterRequest                 = 1
            
}

class MagneticsController: UIViewController {
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.refreshControl?.endRefreshing()
    }
    
    //MARK: 声明，构造
    
    /*-------------------let value---------------------*/
    /**
     初始化全局常量
     */
    //磁片封底视图标记
    private let kTagTableBottomView = 3527
     //磁片父控制器将显示通知
    fileprivate let kMagneticsSuperViewWillAppearNotification = "MagneticsSuperViewWillAppearNotification"
    //磁片父控制器已消失通知
    fileprivate let kMagneticsSuperViewDidDisappearNotification = "MagneticsSuperViewDidDisappearNotification"
    
    /*-------------------view data---------------------*/
    /**
     声明列表视图和数据及初始化
     */
    ///父视图控制器。内部监控页面显示隐藏，应使用业务子类。
    weak var _superViewController: UIViewController?
    weak var superViewController: UIViewController? {
        get{_superViewController}
        set(newSuperViewController){
            if _superViewController != newSuperViewController {
                _superViewController = newSuperViewController
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kMagneticsSuperViewWillAppearNotification), object: _superViewController)
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kMagneticsSuperViewDidDisappearNotification), object: _superViewController)
                
                let superViewClass: AnyClass? = superViewController?.classForCoder
                if superViewClass != nil, superViewClass != UIViewController.classForCoder(), superViewClass != UINavigationController.classForCoder() { //不替换基础类的IMP实现
                    //监控父控制器的页面显示/隐藏
                    let serialQueue = DispatchQueue(label: "com.view.mySerialQueue")
                    serialQueue.sync {
                        
                        swizzleMethod(for: superViewClass!, originalSelector: #selector(viewWillAppear(_:)), swizzledSelector: #selector(magnetics_viewWillAppear(_:)))
                        
                        swizzleMethod(for: superViewClass!, originalSelector: #selector(viewDidDisappear(_:)), swizzledSelector: #selector(magnetics_viewDidDisappear(_:)))
                    }
                   
                    //监听父控制器的页面显示/隐藏通知
                    NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue:kMagneticsSuperViewWillAppearNotification), object: superViewController, queue: nil) { (notification) in
                        self.receiveMagneticsSuperViewWillAppearNotification(notification)
                    }
                    
                    NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue:kMagneticsSuperViewDidDisappearNotification), object: superViewController, queue: nil) { (notification) in
                        self.receiveMagneticsSuperViewDidDisappearNotification(notification)
                    }
                }
            }
        }
    }
    ///磁片表视图
    private lazy var tableView: MagneticTableView = {
        var frame = self.view.bounds
        frame.size.width = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        let tableView = MagneticTableView(frame: frame, style: .plain)
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.autoresizingMask = .flexibleHeight;
        tableView.magneticControllersArray = magneticControllersArray as? NSMutableArray;
        tableView.magneticsController = self;
        if #available(iOS 11, *) {
            tableView.contentInsetAdjustmentBehavior = .never;
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
        } else {
            self.automaticallyAdjustsScrollViewInsets = false;
        }
        return tableView
    }()
    private lazy var loadingView: JEBaseLoadingView = {
        let loadingView = JEBaseLoadingView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        return loadingView
    }()
    ///磁片数据源
    private var magneticsArray = [MagneticContext]()
    ///磁片控制器数据源
    private var magneticControllersArray = [MagneticController]()
    
    /*-------------------Request---------------------*/
    /**
     磁片加载方式
     */
    ///磁片列表刷新方式
    var _refreshType: MagneticsRefreshType?
    var refreshType: MagneticsRefreshType? {
        get{_refreshType!}
        set(newRefreshType){
            if _refreshType != newRefreshType {_refreshType = newRefreshType}
            if _refreshType == MagneticsRefreshType.MagneticsRefreshTypePullToRefresh {
                if tableView.refreshControl == nil, self.isViewLoaded {
                    tableView.refreshControl = refreshControl
                } else {
                    tableView.refreshControl?.endRefreshing()
                }
            }
        }
    }
    ///磁片数据清除方式
    var clearType: MagneticsClearType?
    ///使用默认错误提示,default true
    var enableNetworkError = true
    /// 当前磁片加载完成
    var currentMagneticsLoadFinish = false
    
    /*-------------------Bottom---------------------*/
    /**
     磁片底部
     */
    ///显示表视图封底。默认为false。若取值为true且刷新方式不支持MagneticsRefreshTypeInfiniteScrolling，tableFooterView自动显示封底视图。
    var enableTableBottomView = false
    ///封底自定义视图。默认为nil，提示“没有更多了”+LOGO。
    var tableBottomCustomView: UIView?
    /// refresh
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .gray
        refreshControl.attributedTitle = NSAttributedString(string: "下拉刷新")
        refreshControl.addTarget(self, action: #selector(triggerRefreshAction), for: .valueChanged)
        return refreshControl
    }()
    
    @objc func triggerRefreshAction() {
    }
    //MARK: 初始化 init
}

//MARK: 生命周期
extension MagneticsController{
    
    override func loadView() {
        super.loadView()
        self.view.addSubview(tableView)
        self.view.clipsToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //下拉刷新
        if (refreshType == .MagneticsRefreshTypePullToRefresh) {
            tableView.refreshControl = refreshControl;
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (superViewController == nil) {
            receiveMagneticsSuperViewWillAppearNotification(Notification(name: Notification.Name(rawValue: "")))
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (superViewController == nil) {
            receiveMagneticsSuperViewDidDisappearNotification(Notification(name: Notification.Name(rawValue: "")))
        }
    }
    
    @objc func magnetics_viewWillAppear(_ animated: Bool) {
        magnetics_viewWillAppear(animated)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kMagneticsSuperViewWillAppearNotification), object: self)
    }
    @objc func magnetics_viewDidDisappear(_ animated: Bool) {
        magnetics_viewDidDisappear(animated)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kMagneticsSuperViewDidDisappearNotification), object: self)
    }
    
    //接收到父控制器将显示通知
    private func receiveMagneticsSuperViewWillAppearNotification(_ notification: Notification) {
        for magneticController in magneticControllersArray{
            //to do : respondsToSelector
            magneticController.magneticsController(magneticsController: self, superViewWillAppear: superViewController!)
        }
    }
    //接收到父控制器已隐藏通知
    private func receiveMagneticsSuperViewDidDisappearNotification(_ notification: Notification) {
        for magneticController in magneticControllersArray {
            magneticController.magneticsController(magneticsController: self, superViewDidDisappear: superViewController!)
        }
    }
}

//MARK: func
extension MagneticsController{
    
    /*-------------------Public Methods---------------------*/
    
    ///获取指定类型的磁片控制器
    func queryMagneticControllersWithType(type: MagneticType) -> Array<MagneticController> {
        let magneticControllersMuArray = NSMutableArray()
        for magneticController: MagneticController in magneticControllersArray {
            if magneticController.magneticContext.type == type {
                magneticControllersMuArray.add(magneticController)
            }
        }
        return magneticControllersMuArray as! Array<MagneticController>
    }
    ///滚动到指定类型的磁片
    func scrollToMagneticType(type: MagneticType, animated aAnimated: Bool) {
        var i = 0
        for magneticController: MagneticController in magneticControllersArray {
            i = i + 1
            if magneticController.magneticContext.type == type {break}
            if i < magneticControllersArray.count {
                tableView.scrollToRow(at: IndexPath.init(row: 0, section: i), at: .top, animated: aAnimated)
            }
        }
    }
    
    /*-------------------Private Methods---------------------*/
    
    //获取index对应的磁片控制器
    private func magneticControllerAtIndex(index aIndex: Int) -> MagneticController? {
        aIndex < magneticControllersArray.count ? magneticControllersArray[aIndex] : nil
    }
    //是否为磁片间距
    private func isMagneticSpacing(magneticController aMagneticController: MagneticController, atIndexPath indexPath: NSIndexPath) -> Bool {
        aMagneticController.showMagneticSpacing && indexPath.row == (aMagneticController.rowCountCache - 1)
    }
    //是否为磁片头部
    private func isMagneticHeader(magneticController aMagneticController: MagneticController, atIndexPath indexPath: NSIndexPath) -> Bool {
        aMagneticController.showMagneticHeader && indexPath.row == 0
    }
    //是否为磁片尾部
    private func isMagneticFooter(magneticController aMagneticController: MagneticController, atIndexPath indexPath: NSIndexPath) -> Bool {
        var isMagneticFooter = false
        if aMagneticController.showMagneticFooter {
            if aMagneticController.showMagneticSpacing && indexPath.row == aMagneticController.rowCountCache - 2 {
                isMagneticFooter = true
            }
            if !aMagneticController.showMagneticSpacing && indexPath.row == aMagneticController.rowCountCache - 1 {
                isMagneticFooter = true
            }
        }
        return isMagneticFooter
    }
    //是否为有效磁片内容
    private func isValidMagneticContent(magneticController aMagneticController: MagneticController?, atIndexPath indexPath: NSIndexPath) -> Bool {
        if aMagneticController == nil {return false}
        if isMagneticSpacing(magneticController: aMagneticController!, atIndexPath: indexPath) {return false}//磁片间距
        if isMagneticHeader(magneticController: aMagneticController!, atIndexPath: indexPath) {return false} //头部视图
        if isMagneticFooter(magneticController: aMagneticController!, atIndexPath: indexPath) {return false} //尾部视图
        if aMagneticController!.showMagneticError {return false}//错误磁片
        return true
    }
    
}

//MARK: data Parser
extension MagneticsController{
    
    //解析磁片数据源，创建磁片控制器
    func parseMagneticControllersWithMagneticsArray(magneticsArray aMagneticsArray: Array<MagneticContext>) -> Array<MagneticController> {
        let magneticControllersMuArray = NSMutableArray()
        for magneticContext: MagneticContext in magneticsArray {
            //初始化磁片控制器
            var classC: NSObject.Type? = NSClassFromString(magneticContext.clazz!) as? NSObject.Type
            if classC?.isSubclass(of: MagneticController.classForCoder()) == nil {
                classC = MagneticController.classForCoder() as? NSObject.Type
            }
            
            let magneticController: MagneticController = classC!.init() as! MagneticController
            magneticController.delegate = self
            magneticController.magneticsController = self
            magneticController.magneticContext = magneticContext
            magneticControllersMuArray.add(magneticController)
            
            //初始化扩展控制器
            let extensionClass: NSObject.Type? = NSClassFromString(magneticContext.extensionClazz!) as? NSObject.Type
            if extensionClass?.isSubclass(of: MagneticController.classForCoder()) != nil {
                let extensionController: MagneticController  = extensionClass!.init() as! MagneticController
                extensionController.delegate = self;
                extensionController.magneticsController = self;
                extensionController.magneticContext = magneticContext;
                extensionController.isExtension = true;
                magneticController.extensionController = extensionController;
            }
        }
        return magneticControllersMuArray as! Array<MagneticController>
    }
}

//MARK: 网络请求
extension MagneticsController{
    
    /*-------------------请求单磁片---------------------*/
    ///请求单磁片数据（继承实现）
    func requestMagneticDataWithController(magneticController aMagneticController: MagneticController) {
        let type: RequestType = aMagneticController.magneticRequestTypeInMagneticsController(magneticsController: self)
        let url: String = aMagneticController.magneticRequestURLInMagneticsController(magneticsController: self)
        let param: NSDictionary = aMagneticController.magneticRequestParametersInMagneticsController(magneticsController: self)
        
        if url.count == 0 {
            return;
        }

        //网络请求
        JEHttpManager.requestType(requestType: type.rawValue, requestUrl: url, parameters: param, success: { (responseObject) in
            aMagneticController.magneticContext.magneticInfo = responseObject as! [String : String]
            magneticSeparateDataBeReady(magneticContext: aMagneticController.magneticContext)
        }, failure: { (error) in
            let magneticError = NSError.init(domain: "MagneticError", code: MagneticErrorCode.MagneticErrorCodeNetwork.rawValue, userInfo: nil)
            magneticSeparateDataUnavailable(magneticContext: aMagneticController.magneticContext, error: magneticError)
        })
    }
    
}

//MARK: Request Magnetics
extension MagneticsController {
    
    
    ///请求磁片列表（继承实现）
    func requestMagnetics() {
        requestMagneticsWillStart()
    }
    
    ///加载更多数据。默认回调磁片-didTriggerRequestMoreDataActionInMagneticsController协议，可继承重写事件。
    func requestMoreData() {
        //触发加载更多事件
        for i in 0...magneticControllersArray.count {
            let magneticController: MagneticController = magneticControllersArray[i]
            magneticController.didTriggerRequestMoreDataActionInMagneticsController(magneticsController: self)
        }
    }
    
    /*-------------------请求磁片列表---------------------*/
    ///磁片列表请求将开始
    func requestMagneticsWillStart() {
        if clearType == .MagneticsClearTypeBeforeRequest, magneticControllersArray.count > 0 { //请求前清除数据源
            magneticsArray.removeAll()
            magneticControllersArray.removeAll()
            tableView.reloadData()
        }
        
        //隐藏错误提示
        // to do
//        self.view.hideErrorView
        
        //显示加载视图
        if refreshType == .MagneticsRefreshTypeLoadingView && magneticControllersArray.count != 0 {
            //居中显示
            let hHeader = tableView.tableHeaderView?.frame.size.height
            let hTable = tableView.frame.size.height
            
            let cY = (hTable - hHeader! - tableView.contentInset.top - tableView.contentInset.bottom) / 2.0 + hHeader!
            loadingView.center = CGPoint(x: tableView.frame.size.width / 2.0, y: cY)
            tableView.addSubview(loadingView)
            loadingView.startAnimating()
        }
        
    }
    
    ///磁片列表请求成功
    func requestMagneticsDidSucceedWithMagneticsArray(magneticsArray aMagneticsArray: Array<MagneticContext>) {
        if magneticsArray.count != 0 && aMagneticsArray.count != 0 && magneticsArray == aMagneticsArray { //数据未变更
            if refreshType == .MagneticsRefreshTypePullToRefresh { //下拉刷新
                tableView.refreshControl?.endRefreshing()
            }
            return;
        }

        //清空缓存
        if (clearType == .MagneticsClearTypeAfterRequest) {
            //初始化监听可能调用了UI刷新和数据请求，若请求前没有清除数据源，需要保证回调前清空缓存
            magneticsArray.removeAll()
            magneticControllersArray.removeAll()
            tableView.reloadData()
        }

        //解析数据源
        let controllersArray = parseMagneticControllersWithMagneticsArray(magneticsArray: magneticsArray)
        
        //更新数据源
        magneticControllersArray = controllersArray;
        magneticsArray = aMagneticsArray;

        //执行磁片初始化监听（可能调用了UI刷新和数据请求，需在_magneticsArray和_magneticControllersArray赋值后调用）
        for magneticController: MagneticController in magneticControllersArray {
            magneticController.magneticContext.isChange = true
            magneticController.didFinishInitConfigurationInMagneticsController(magneticsController: self)
            magneticController.extensionController?.didFinishInitConfigurationInMagneticsController(magneticsController: self)
        }

        //隐藏错误提示
        if (enableNetworkError) {
            // to do
//            self.view.hideErrorView
        }

        //隐藏加载视图
        if (refreshType == .MagneticsRefreshTypeLoadingView) { //中心加载视图
            loadingView.stopAnimating()
            loadingView.removeFromSuperview()
        }
        if (refreshType == .MagneticsRefreshTypePullToRefresh) { //下拉刷新
            tableView.refreshControl?.endRefreshing()
        }

        tableView.reloadData()
        
        //请求独立数据源
        for (_, value) in magneticControllersArray.enumerated() {
            if value.magneticContext.asyncLoad {
                requestMagneticDataWithController(magneticController: value)
            }
        }

    }
    ///磁片列表请求失败
    func requestMagneticsDidFailWithError(error: NSError) {
        //清空数据源
        if clearType == .MagneticsClearTypeAfterRequest {
            magneticsArray.removeAll()
            magneticControllersArray.removeAll()
            tableView.reloadData()
        }
        
        //隐藏加载视图
        if refreshType == .MagneticsRefreshTypeLoadingView { //中心加载视图
            loadingView.stopAnimating()
            loadingView.removeFromSuperview()
        }
        if refreshType == .MagneticsRefreshTypePullToRefresh { //下拉刷新
            tableView.refreshControl?.endRefreshing()
        }
        
        //显示错误提示视图
        if enableNetworkError {
            if error.code == MagneticErrorCode.MagneticErrorCodeFailed.rawValue { //数据错误
                // to do
//                [self.view showFailedError:self selector:@selector(touchErrorViewAction)];
            } else { //网络错误
//                [self.view showNetworkError:self selector:@selector(touchErrorViewAction)];
            }
        }
    }
    
    /*-------------------请求磁片---------------------*/
    
    //单磁片请求成功回调
    func magneticSeparateDataBeReady(magneticContext aMagneticContext: MagneticContext) {
        let magneticIndex = magneticsArray.firstIndex(of: aMagneticContext)
        if magneticIndex != nil, magneticIndex! < magneticControllersArray.count {
            requestMagneticDataDidSucceedWithMagneticContext(magneticContext: aMagneticContext)
        }
    }

    //单磁片请求失败回调
    func magneticSeparateDataUnavailable(magneticContext aMagneticContext: MagneticContext, error aEror: NSError) {
        let magneticIndex = magneticsArray.firstIndex(of: aMagneticContext)
        if magneticIndex != nil, magneticIndex! < magneticControllersArray.count {
            requestMagneticDataDidFailWithMagneticContext(magneticContext: aMagneticContext, error: aEror)
        }
    }
    
    ///磁片数据请求成功
    func requestMagneticDataDidSucceedWithMagneticContext(magneticContext aMagneticContext: MagneticContext) {
        
        aMagneticContext.error = nil;
        let index = magneticsArray.firstIndex(of: aMagneticContext)
        let magneticController: MagneticController = magneticControllerAtIndex(index: index!)!
        magneticController.magneticRequestDidFinishInMagneticsController(magneticsController: self)
        tableView.reloadSections(sections: [index!])
    }
    ///磁片数据请求失败
    func requestMagneticDataDidFailWithMagneticContext(magneticContext aMagneticContext: MagneticContext, error: NSError) {
        
        let index = magneticsArray.firstIndex(of: aMagneticContext)
        let magnetic = magneticControllerAtIndex(index: index!)

        if magnetic != nil {
            if error.domain == "MagneticError" {
                aMagneticContext.error = error;
            } else {
                aMagneticContext.error = NSError(domain: "MagneticError", code: MagneticErrorCode.MagneticErrorCodeNetwork.rawValue, userInfo: nil)

            }
            
            magnetic?.magneticRequestDidFinishInMagneticsController(magneticsController: self)
            if (magnetic?.magneticsController(magneticsController: self, shouldIgnoreMagneticErrorWithCode: MagneticErrorCode(rawValue: aMagneticContext.error!.code)!))! {
                //忽略当前类型错误
                aMagneticContext.error = nil
            }
            tableView.reloadSections(sections: [index!]);
        }
    }
    
    ///加载更多磁片请求成功
    func requestMoreMagneticsDidSucceedWithMagneticsArray(magneticsArray aMagneticsArray: Array<MagneticContext>?) {
        
        guard aMagneticsArray?.count == 0 else {
            //记录参数
            //新增磁片对应的sections
            var sections = [Int]()
            let startSection = aMagneticsArray?.count
            
            //解析数据源
            let magneticVCArray = parseMagneticControllersWithMagneticsArray(magneticsArray: aMagneticsArray!)
            
            //更新数据源
            magneticControllersArray.append(contentsOf: magneticVCArray)
            magneticsArray.append(contentsOf: aMagneticsArray!)
            
            //执行磁片初始化监听（可能调用了UI刷新和数据请求，需在_magneticsArray和_magneticControllersArray赋值后调用）
            for magneticVc: MagneticController in magneticVCArray {
                magneticVc.didFinishInitConfigurationInMagneticsController(magneticsController: self)
                magneticVc.extensionController?.didFinishInitConfigurationInMagneticsController(magneticsController: self)
                sections.append(startSection! + 1)
            }
            
            //刷新视图
            tableView.reloadSections(sections: [sections])
            return
        }
    }
    
    ///加载更多磁片失败
    func requestMoreMagneticsDidFailWithError(error: NSError) {
    }
    
}

//MARK: Bottom
extension MagneticsController{
    ///触发加载更多事件，启动加载动画
    func triggerInfiniteScrollingAction() {}
    ///完成加载更多事件，停止加载动画
    func finishInfiniteScrollingAction() {}
    ///完成所有数据加载，显示没有更多了封底图
    func didFinishLoadAllData() {}
    ///刷新封底视图
    private func refreshTableBottomView(){}
}

//MARK: MagneticControllerProtocol
extension MagneticsController: MagneticControllerProtocol{
    
    ///刷新指定类型的磁片
    func refreshMagneticWithType(_ type: MagneticType, animation aAnimation: UITableView.RowAnimation) {
        
        let sections = NSMutableIndexSet()
        for i in 0...magneticControllersArray.count {
            let magneticVC: MagneticController = magneticControllersArray[i]
            if magneticVC.magneticContext.type == type {
                if magneticVC.magneticContext.asyncLoad {
                    requestMagneticDataWithController(magneticController: magneticVC)
                    return;
                }
                sections.add(i)
            }
        }
        
        guard sections.count == 0 else {
            
            if aAnimation != .none {
                let serialQueue = DispatchQueue(label: "com.refresh.mySerialQueue")
                serialQueue.sync {
                    tableView.beginUpdates()
                    tableView.reloadSections(sections as IndexSet, with: aAnimation)
                }
                
            } else {
                tableView.reloadSections(sections as IndexSet, with: aAnimation)
            }
            
            return
        }
    }
    
    ///刷新指定类型的磁片
    func refreshMagneticWithType(_ type: MagneticType) {
        refreshMagneticWithType(type, animation: .none)
    }
    
    func refreshMagneticWithType(_ type: MagneticType, json ajson: Any?) {
        let sections = NSMutableArray()
        for i in 0...magneticControllersArray.count {
            let magneticVC: MagneticController = magneticControllersArray[i]
            if magneticVC.magneticContext.type == type {
                sections.add(i)
                magneticVC.magneticContext.json = ajson!
                magneticVC.magneticContext.isChange = true
                magneticVC.didFinishInitConfigurationInMagneticsController(magneticsController: self)
            }
        }
        
        if sections.count > 0 {
            tableView.reloadSections(sections: sections as! Array<Any>)
        }
    }
    
    func addSectionWithType(_ magneticType: MagneticType, withMagneticContext magneticContext: MagneticContext, withMagneticController magneticController: MagneticController, index aIndex: Int, animation aAnimation: UITableView.RowAnimation) {
        let sections = NSMutableIndexSet()
        magneticsArray.insert(magneticContext, at: aIndex)
        magneticControllersArray.insert(magneticController, at: aIndex)
        //计算需要操作的section
        for i in 0...magneticControllersArray.count {
            let magneticVC: MagneticController = magneticControllersArray[i]
            if magneticVC.magneticContext.type == magneticType {
                sections.add(i)
            }
        }
        
        tableView.insertSections(sections as IndexSet, with: aAnimation)
    }
    
    func deleteSectionWithType(_ magneticType: MagneticType, index aIndex: Int, animation aAnimation: UITableView.RowAnimation) {
        let sections = NSMutableIndexSet()
        //计算需要操作的section
        for i in 0...magneticControllersArray.count {
            let magneticVC: MagneticController = magneticControllersArray[i]
            if magneticVC.magneticContext.type == magneticType {
                sections.add(i)
            }
        }
        
        magneticsArray.remove(at: aIndex);
        magneticControllersArray.remove(at: aIndex)
        tableView.deleteSections(sections as IndexSet, with: aAnimation)
    }
    
}

//MARK: UIScrollViewDelegate
extension MagneticsController{
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let visibleCells = tableView.visibleCells
        for visibleCell: UITableViewCell in visibleCells {
            let indexPath: NSIndexPath = tableView.indexPath(for: visibleCell)! as NSIndexPath
            let magneticVC = magneticControllerAtIndex(index: indexPath.section)
            magneticVC?.magneticsController(magneticsController: self, scrollViewWillBeginDraggingForCell: visibleCell)
            }
    }
}

//MARK: UITableViewDataSource, UITableViewDelegate
extension MagneticsController: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {magneticControllersArray.count}
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let magneticVC = magneticControllerAtIndex(index: section)
        return magneticVC?.rowCountCache ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let magneticVC = magneticControllerAtIndex(index: section)
        let headerHeight: CGFloat = (magneticVC?.magneticsController(magneticsController: self, heightForSuspendHeaderInTableView: tableView as! MagneticTableView))!
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let magneticVC = magneticControllerAtIndex(index: indexPath.section)
        if indexPath.row < magneticVC?.rowHeightsCache.count ?? 0 {
            return ceil((magneticVC?.rowHeightsCache[indexPath.row] ?? 0.0) as! CGFloat)
        }
        return 0.0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let magneticVC = magneticControllerAtIndex(index: section)
        let headerView = magneticVC?.magneticsController(magneticsController: self, viewForSuspendHeaderInTableView: tableView as! MagneticTableView)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let magneticVC: MagneticController = magneticControllerAtIndex(index: indexPath.section)!//布局参数
        var isShowSpacing = isMagneticSpacing(magneticController: magneticVC, atIndexPath: indexPath as NSIndexPath)//磁片间距
        let isShowHeader = isMagneticHeader(magneticController: magneticVC, atIndexPath: indexPath as NSIndexPath) //头部视图
        let isShowFooter = isMagneticFooter(magneticController: magneticVC, atIndexPath: indexPath as NSIndexPath)//尾部视图
        
        //复用参数
        var magneticClass: UITableViewCell?
        var identifier: String?
        
        if (isShowSpacing) { //磁片间距
            magneticClass = UITableViewCell()
            identifier = "MagneticSpacingCell"
        } else if (isShowHeader) { //头部视图
            magneticClass = magneticVC.magneticsController(magneticsController: self, cellClassForMagneticHeaderInTableView: tableView as! MagneticTableView)
            identifier = magneticVC.magneticsController(magneticsController: self, cellIdentifierForMagneticHeaderInTableView: tableView as! MagneticTableView)
        } else if (isShowFooter) { //尾部视图
            magneticClass = magneticVC.magneticsController(magneticsController: self, cellClassForMagneticFooterInTableView: tableView as! MagneticTableView)
            identifier = magneticVC.magneticsController(magneticsController: self, cellIdentifierForMagneticFooterInTableView: tableView as! MagneticTableView)
        } else {
            if magneticVC.showMagneticError { //错误磁片
                magneticClass = MagneticErrorCell()
                identifier = NSStringFromClass((magneticClass?.classForCoder)!);
            } else { //数据源
                if indexPath.row < magneticVC.extensionRowIndex { //磁片内容
                    //数据源对应的index
                    let rowIndex = magneticVC.showMagneticHeader ? indexPath.row - 1 : indexPath.row
                    magneticClass = magneticVC.magneticsController(magneticsController: self, cellClassForMagneticContentAtIndex: rowIndex)
                    identifier = magneticVC.magneticsController(magneticsController: self, cellIdentifierForMagneticContentAtIndex: rowIndex)
                } else { //磁片扩展
                    //数据源对应的index
                    let rowIndex = indexPath.row - magneticVC.extensionRowIndex;
                    magneticClass = magneticVC.extensionController?.magneticsController(magneticsController: self, cellClassForMagneticContentAtIndex: rowIndex)
                    identifier = magneticVC.extensionController?.magneticsController(magneticsController: self, cellIdentifierForMagneticContentAtIndex: rowIndex)
                }
            }
        }
        
        if magneticClass == nil {
            magneticClass = UITableViewCell()
        }
        if identifier?.count == 0 {
            //同类磁片内部复用cell
            identifier = NSStringFromClass((magneticClass?.classForCoder)!) + "_" + String(magneticVC.magneticContext.type.rawValue)
        }
        
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: identifier!)
        if cell == nil {
            cell = magneticClass ?? UITableViewCell()
            cell?.clipsToBounds = true
            cell?.isExclusiveTouch = true
            cell?.selectionStyle = .none;
            
            cell?.backgroundColor = magneticVC.magneticsController(magneticsController: self, colorForMagneticBackgroundInTableView: tableView as! MagneticTableView)
            cell?.contentView.backgroundColor = cell?.backgroundColor
        }
        
        if (isShowSpacing) { //磁片间距
            let backgroundColor = magneticVC.magneticsController(magneticsController: self, colorForMagneticSpacingInTableView: tableView as! MagneticTableView)

            cell?.backgroundColor = backgroundColor;
            cell?.contentView.backgroundColor = backgroundColor;
            magneticVC.magneticsController(magneticsController: self, reuseCell: cell!, forMagneticSpaingInTableView: tableView as! MagneticTableView)
            
        } else if (isShowHeader) { //头部视图
            magneticVC.magneticsController(magneticsController: self, reuseCell: cell!, cellIdentifierForMagneticHeaderInTableView: tableView as! MagneticTableView)
        } else if (isShowFooter) { //尾部视图
            magneticVC.magneticsController(magneticsController: self, reuseCell: cell!, forMagneticFooterInTableView: tableView as! MagneticTableView)
        } else { //数据源
            if magneticVC.showMagneticError { //错误磁片
                let magneticErrorCell: MagneticErrorCell = cell as! MagneticErrorCell
                magneticErrorCell.magneticController = magneticVC;
                magneticErrorCell.refreshMagneticErrorView()
            } else {
                if indexPath.row < magneticVC.extensionRowIndex { //磁片内容
                    //数据源对应的index
                    let rowIndex = magneticVC.showMagneticHeader ? indexPath.row - 1 : indexPath.row
                    magneticVC.magneticsController(magneticsController: self, reuseCell: cell!, forMagneticContentAtIndex: rowIndex)
                } else { //磁片扩展
                    //数据源对应的index
                    let rowIndex = indexPath.row - magneticVC.extensionRowIndex
                    magneticVC.extensionController?.magneticsController(magneticsController: self, reuseCell: cell!, forMagneticContentAtIndex: rowIndex)
                }
            }
        }
        return cell!
    }
}

//MARK: Event
extension MagneticsController{
    
    /*-------------------Error View---------------------*/
    //默认点击提示信息事件
    private func touchErrorViewAction() {
        if refreshType == .MagneticsRefreshTypeLoadingView {
            requestMagnetics()
        } else if refreshType == .MagneticsRefreshTypePullToRefresh {
            if enableNetworkError {
                // to do
//                view.hideErrorView
            }
            tableView.refreshControl?.beginRefreshing()
        } else {
            requestMagnetics()
        }
    }
    
}
