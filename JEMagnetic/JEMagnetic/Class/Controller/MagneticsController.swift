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
                    let serialQueue = DispatchQueue(label: "com.test.mySerialQueue")
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
    private var magneticControllersArray: [MagneticController] = [MagneticController]()
    
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

//MARK: Request
extension MagneticsController {
    
    
    ///请求磁片列表（继承实现）
    func requestMagnetics() {
        requestMagneticsWillStart()
    }
    
    ///加载更多数据。默认回调磁片-didTriggerRequestMoreDataActionInMagneticsController协议，可继承重写事件。
    func requestMoreData() {}
    
    /*-------------------请求单磁片---------------------*/
    ///请求单磁片数据（继承实现）
    func requestMagneticDataWithController(magneticController aMagneticController: MagneticController) {
        let type: RequestType = aMagneticController.magneticRequestTypeInMagneticsController(magneticsController: self)
        let url: String = aMagneticController.magneticRequestURLInMagneticsController(magneticsController: self)
        let param: NSDictionary = aMagneticController.magneticRequestParametersInMagneticsController(magneticsController: self)
        
        
        if url.count == 0 {
            return;
        }

        // to do
//        [JEHttpManager requestType:type requestUrl:url parameters:param success:^(id  _Nonnull responseObject) {
//            magneticController.magneticContext.magneticInfo = responseObject;
//            [weakSelf magneticSeparateDataBeReady:magneticController.magneticContext];
//        } failure:^(id  _Nonnull error) {
//            NSError *magneticError = [NSError errorWithDomain:@"MagneticError" code:MagneticErrorCodeNetwork userInfo:nil];
//            [weakSelf magneticSeparateDataUnavailable:magneticController.magneticContext error:magneticError];
//        }];
    }
    
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
    ///磁片数据请求成功
    func requestMagneticDataDidSucceedWithMagneticContext(magneticContext aMagneticContext: MagneticContext) {
        
        aMagneticContext.error = nil;
        let index = magneticsArray.firstIndex(of: aMagneticContext)
        let magneticController: MagneticController = magneticControllerAtIndex(index: index!)!
        magneticController.magneticRequestDidFinishInMagneticsController(magneticsController: self)
        tableView.reloadSections(sections: [index!])
    }
    ///磁片列表请求失败
    func requestMagneticDataDidFailWithMagneticContext(magneticContext aMagneticContext: MagneticContext, error: NSError) {
        
    }
    
    ///加载更多磁片请求成功
    func requestMoreMagneticsDidSucceedWithMagneticsArray(magneticsArray aMagneticsArray: Array<Any>?) {
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

//MARK: 网络请求
extension MagneticsController{
    
}

//MARK: UITableViewDataSource, UITableViewDelegate
extension MagneticsController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }
}

//MARK: MagneticControllerProtocol
extension MagneticsController: MagneticControllerProtocol{
    func refreshMagneticWithType(_ type: MagneticType, animation aAnimation: UITableView.RowAnimation) {
        
    }
    
    func refreshMagneticWithType(_ type: MagneticType) {
        
    }
    
    func refreshMagneticWithType(_ type: MagneticType, json ajson: Any) {
        
    }
    
    func addSectionWithType(_ magneticType: MagneticType, withMagneticContext magneticContext: MagneticContext, withMagneticController magneticController: MagneticController, index aIndex: Int, animation aAnimation: UITableView.RowAnimation) {
        
    }
    
    func deleteSectionWithType(_ magneticType: MagneticType, index aIndex: Int, animation aAnimation: UITableView.RowAnimation) {
        
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
