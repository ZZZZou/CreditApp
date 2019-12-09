//
//  CreditManagerViewController.swift
//  CreditApp
//
//  Created by wang on 2018/9/2.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import SnapKit
import UIKit
import RxSwift
import XCGLogger


class CMListViewController: UIViewController, HhDownload {

    // MARK: - Properties
    var disposeBag = DisposeBag()
    var viewModel: CardListViewModel!
    
    let tableView = UITableView(frame: CGRect(), style: .plain)
    let headView = UIView()
    let footView = UIView()
    let refresh = UIRefreshControl()
    private let dataSource = CMListDataSource()
    var logg = XCGLogger.default
    private var isMailAdd = false
    
    // MARK: - UIViewController overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.setupRefreshView()
        
//        let user = UserSingle.sharedInstance
//        viewModel = CardListViewModel(provider: Networking.newDefaultNetworking(), userID: user.userModel.user_uuid!)
//        viewModel.listingsModels().subscribe{
//            
//        }.disposed(by: disposeBag)
//        
//        self.addObserver()
//        
//        self.view.backgroundColor = UIColor.white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isMailAdd {
            refreshSendActions()
            isMailAdd = false
        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let scanner = Scanner(string: "lisa123")
        var username: NSString?
        let alphas = CharacterSet.alphanumerics
        if scanner.scanCharacters(from: alphas, into: &username),
            let name = username {
            print(name)
        }
    }
    
    // MARK: - UI
    
    func setupTableView() {
        
        //tableView
        tableView.backgroundColor = UIColor.backgroundGray
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        // constraint
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self.topLayoutGuide.snp.bottom)
            make.bottom.equalTo(self.bottomLayoutGuide.snp.top)
            make.left.equalTo(view)
            make.right.equalTo(view)
        }
        self.setupHeadView()
        self.setupFootView()
        
        tableView.delegate = self
        tableView.dataSource = dataSource
        dataSource.registerCells(with: tableView)
    }
    
    func setupRefreshView() {
        refresh.tintColor = UIColor.gray
        refresh.addTarget(self, action: #selector(CMListViewController.refreshTableView), for: .valueChanged)
        tableView.addSubview(refresh)
    }
    
    func setupHeadView() {
        
        //table head view
        headView.frame = CGRect()
        headView.backgroundColor = UIColor.backgroundGray
        
        let titleLable1 = UILabel()
        titleLable1.text = NSLocalizedString("cm.list.title1")
        titleLable1.textColor = UIColor.textBlack
        titleLable1.font = UIFont.normal
        headView.addSubview(titleLable1)
        
        let titleLabel2 = UILabel()
        titleLabel2.text = NSLocalizedString("cm.list.title2")
        titleLabel2.textColor = UIColor.textBlack
        titleLabel2.font = UIFont.normal
        headView.addSubview(titleLabel2)

        //inner constraint
        titleLable1.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(36)
            make.centerX.equalToSuperview()
        }
        titleLabel2.snp.makeConstraints { (make) in
            make.top.equalTo(titleLable1.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-24)
        }
        
        let height = headView.systemLayoutHeightFitting(fixedWidth: UIScreen.width)
        headView.size = CGSize(width: UIScreen.width, height: height)
        tableView.tableHeaderView = headView
    }
    
    func setupFootView(){
        //table foot view
        footView.frame = CGRect(x: 0, y: 0, width: UIScreen.width, height: 160+24*2)
        footView.backgroundColor = UIColor.backgroundGray
        tableView.tableFooterView = footView
        
        let backgroundView = UIButton()
        backgroundView.backgroundColor = UIColor.white
        backgroundView.layer.cornerRadius = 5
        backgroundView.layer.borderColor = UIColor(hex: "#808080").cgColor
        backgroundView.layer.borderWidth = 1
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        footView.addSubview(backgroundView)
        
        let icon = UIImageView(image: UIImage(named: "list-add"))
        footView.addSubview(icon)
        
        let iconTitle = UILabel()
        iconTitle.text = NSLocalizedString("cm.list.add-credit")
        iconTitle.textColor = UIColor.textGray
        iconTitle.font = UIFont.small
        iconTitle.isUserInteractionEnabled = false
        footView.addSubview(iconTitle)
        
        //inner constraint
        backgroundView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(160)
        }
        icon.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-12)
            make.width.equalTo(48)
            make.height.equalTo(48)
        }
        iconTitle.snp.makeConstraints { (make) in
            make.top.equalTo(icon.snp.bottom).offset(0)
            make.centerX.equalToSuperview()
        }
        
        //action
        backgroundView.addTarget(self, action: #selector(self.addCredit), for: .touchUpInside)
    }
    
    //MARK: - Action
    
    @objc func addCredit()  {
//        if !UserSingle.sharedInstance.isLogined {
//            let loginVC = LoginViewController()
//            loginVC.loginVCClosume = { [unowned self] in
//                SwiftTools.timeDelayWithTmer(1, todo: { [unowned self] in
//                    let choiceVC = ChoiceViewController()
//                    choiceVC.hidesBottomBarWhenPushed = true
//                    self.navigationController?.pushViewController(choiceVC, animated: true)
//                })
//            }
//            DispatchQueue.main.async {
//                self.present(loginVC, animated: true, completion: nil)
//            }
//            return
//        }
//        let choiceVC = ChoiceViewController()
//        choiceVC.hidesBottomBarWhenPushed = true
//        navigationController?.pushViewController(choiceVC, animated: true)
    }
    
    @objc func refreshTableView(){
        
    }
    
    
    //MARK: - Observer
    private var selectTabbarIndex = 0
    func addObserver() {
//        let tabbar = self.navigationController?.tabBarController as! DDTabbarViewController
//        tabbar.didSelectViewController.subscribe(
//            onNext: { [unowned self] (index) in
//                if index == 0 && self.selectTabbarIndex == 0{
//                    self.refreshSendActions()
//                }
//                self.selectTabbarIndex = index
//
//        }, onDisposed: {print("disposed in list view ctrl")}).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(Notification.Name(rawValue: kNotifications.EmailAddDefaults.rawValue)).map { [unowned self] (noti) in
            self.isMailAdd = true
        }.subscribe().disposed(by: disposeBag)
        
        NotificationCenter.default
            .rx.notification(Notification.Name(rawValue: kNotifications.EmailAutoLoadDefaults.rawValue))
            .map { [unowned self] (noti) in
                
                if let isSuccess = noti.userInfo?[kNotifications.EmailAutoLoadStatus] as? Bool {
                    if self.children.first is WebLoginViewController {
                        if let v = self.children.first?.view {
                            if isSuccess {
                                self.view.sendSubviewToBack(v)
                            } else {
                                self.view.bringSubviewToFront(v)
                            }
                        }
                    }
                    
                }
            }.subscribe().disposed(by: disposeBag)
    }
    
    fileprivate func refreshSendActions() {
        tableView.setContentOffset(CGPoint(x: 0, y: -self.refresh.height - 5), animated: true)
        SwiftTools.timeDelayWithTmer(0.5) {[unowned self] in
            self.refresh.beginRefreshing()
            self.refresh.sendActions(for: .valueChanged)
        }
    }
    
    //MARK: - Data
    
    fileprivate func downloadData(isRefreshed: Bool = true) {
        let user = UserSingle.sharedInstance
        if !user.isLogined {
            refresh.endRefreshing()
            print("not login")
            return
        }
        let parameters = ["userUUID": user.userModel.user_uuid, "isAllUpdate": isRefreshed] as [String : Any]
        _ = downloadToArrayWithParameters(parameters, url: kGetAllCardURL, modeltype: CMTotalCardModel.self).catchError({ (error) -> Observable<[CMTotalCardModel]> in
            if let e = error as? TestInfoError {
                print(e.info)
                self.refresh.endRefreshing()
            }
            return Observable.never()
        }).map({ [unowned self] (models)  in
            self.dataSource.modelArray = models
            self.refresh.endRefreshing()
//            self.tableView.reloadData()
            print(models)
            
        }).subscribe().disposed(by: disposeBag)
    }
    
    fileprivate func mailUpdate(_ model: MailModel) {
        logg.debug(model.mail + model.password)
        logg.debug(model.time)
        let loginVC = WebLoginViewController()
        loginVC.hidesBottomBarWhenPushed = true
        loginVC.viewWithWebLoginAddress(address: model.mailAddress)
        loginVC.viewWithAutoLoad(mailModel: model)
        self.addChild(loginVC)
        self.view.addSubview(loginVC.view)
        self.view.sendSubviewToBack(loginVC.view)
    }
}


extension CMListViewController: UITableViewDelegate, Prealm {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < 6 {
            let res = realmMailSearch(dataSource.modelArray[indexPath.row].from_mail)
            if let m = res.last {
                logg.debug(m.inputAccount)
                logg.debug(m.password)
                mailUpdate(m)
            }
            return
        }
        let capVC = CaptiveViewController()
        capVC.viewWithCardModel(cardModel: dataSource.modelArray[indexPath.row])
        capVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(capVC, animated: true)
    }
}
