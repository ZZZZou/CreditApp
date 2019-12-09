//
//  WebLoginViewController.swift
//  CreditApp
//
//  Created by 胡骏 on 2018/9/4.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import UIKit

import XCGLogger
import Alamofire
import SwiftyJSON

class WebLoginViewController: UIViewController, BindableType {

//    lazy var loadZhihuView: ZhiHuLoadViewController = {
//        let z = ZhiHuLoadViewController()
//        return z
//    }()
    
    lazy var loadZhihuView: EmailLoadingViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "emailLoading") as! EmailLoadingViewController
    }()
    
    fileprivate var address: String = ""
    fileprivate var isAutoUpdate = false
    
    var logg = XCGLogger.default
    
    var viewModel: WebLoginViewModelProtocol!
    
    // MARK: - life cycle
   
    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
        addLoginControllerWithAddress(address: address)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func bindViewModel() {
    }
    // MARK: - public methods
   
    func viewWithWebLoginAddress(address: String) {
        self.address = address
    }
    fileprivate var autoMailModel: MailModel?
    func viewWithAutoLoad(mailModel: MailModel) {
        isAutoUpdate = true
        autoMailModel = mailModel
    }
    // MARK: - notification、closume、event response
    
    
    // MARK: - private methods
    fileprivate func startLoadMail(manager: AFHTTPSessionManager, updict: [String : Any]) {
        
        manager.post(kGetCookie,
                     parameters: updict,
                     progress: { [unowned self] (progress) in
                        self.logg.debug(progress)
                     },
                     success: { [unowned self] (task, response) in
                        self.logg.debug(response)
                
                        guard let resultDict = response as? [String: Any], let dic = resultDict["header"] as? [String: String], let statusString = dic["status"] else {
                            return
                        }
                
                        switch statusString {
                        case "000":
                            NotificationCenter.default.post(name: NSNotification.Name(kNotifications.EmailAddDefaults.rawValue), object: nil, userInfo: nil)
                            self.logg.debug("有新数据")
                        case "003":
                           
                            self.logg.debug("没有账单")
                        case "004":
                          
                            self.logg.debug("没有新数据")
                            
                        default:
                            break
                        }
                        if !self.isAutoUpdate {
                            self.loadZhihuView.view.removeFromSuperview()
                            self.loadZhihuView.removeFromParent()
                        }
                        self.logg.debug(statusString)
                        if self.isAutoUpdate {
                            let coordinator = self.viewModel.coordinator
                            coordinator.popToRoot(animated: true)
                            NotificationCenter.default.post(name: NSNotification.Name("didAddMail"), object: nil)
                        } else {
                            let coordinator = self.viewModel.coordinator
                            coordinator.popToRoot(animated: true)
                            NotificationCenter.default.post(name: NSNotification.Name("didAddMail"), object: nil)
                        }
        
                    }) {  [unowned self] (task, error) in
                            self.startLoadMail(manager: manager, updict: updict)
            }
    }
    
    private func addLoginControllerWithAddress(address: String) {
        
        switch address {
        case "163":
            let web163 = WebLogin163ViewController()
            web163.delegate = self
            if isAutoUpdate, let a = autoMailModel {
                web163.viewWithAutoLoad(mailModel: a)
            }
            addChild(web163)
            view.addSubview(web163.view)
        case "qq":
            let qqweb = WebLoginQQViewController()
            qqweb.delegate = self
            if isAutoUpdate, let a = autoMailModel {
                qqweb.viewWithAutoLoad(mailModel: a)
            }
            addChild(qqweb)
            view.addSubview(qqweb.view)
        case "126":
            let web126 = WebLogin126ViewController()
            web126.delegate = self
            if isAutoUpdate, let a = autoMailModel {
                web126.viewWithAutoLoad(mailModel: a)
            }
            addChild(web126)
            view.addSubview(web126.view)
        default:
            let qqweb = WebLoginQQViewController()
            qqweb.delegate = self
            if isAutoUpdate, let a = autoMailModel {
                qqweb.viewWithAutoLoad(mailModel: a)
            }
            addChild(qqweb)
            view.addSubview(qqweb.view)
        }
    }
    
    private func makeUI() {
        self.title = NSLocalizedString("邮箱导入", comment: "")
        view.backgroundColor = UIColor(hex: "#eef2f6")
    }
    
    private func cleanCacheAndCookie() {
        let storage = HTTPCookieStorage.shared
        if let cookies = storage.cookies {
            for cookie in cookies {
                storage.deleteCookie(cookie)
            }
        }
    }
}

extension WebLoginViewController: WebLoginViewControllerDelegate, Prealm {
   
    func WebLoginViewControllerFindCookies(_ vc: UIViewController, cookies: [String : Any], mail: String, password: String, address: String, inputAccount: String) {
        cleanCacheAndCookie()
        vc.view.isHidden = true
        let manager = AFHTTPSessionManager(sessionConfiguration: URLSessionConfiguration.default)
        manager.requestSerializer = AFJSONRequestSerializer.init()
        navigationController?.setNavigationBarHidden(true, animated: true)
       
        
        self.addChild(loadZhihuView)
        view.addSubview(loadZhihuView.view)
        self.loadZhihuView.emailUser = "当前邮箱：" + mail
        
        logg.debug("cookie coming")
        startLoadMail(manager: manager, updict: cookies)
        
        if !mail.isEmpty && !password.isEmpty {
           
            let currentDate = Date(timeIntervalSinceNow: 0)
            let mailModel = MailModel()
            mailModel.inputAccount = inputAccount
            mailModel.mail = mail
            mailModel.password = password
            mailModel.mailAddress = address
            mailModel.time = currentDate
            let result = realmMailSearch(mail)
            if result.isEmpty {
                logg.debug("no data")
            } else {
                logg.debug("had data")
//                realmDeleteResultsModel(result)
            }
            _ = realmAddModel(mailModel)

        }
    }
}
