//
//  BorrowingViewController.swift
//  CreditApp
//
//  Created by 胡骏 on 2019/3/13.
//  Copyright © 2019 CreditManager. All rights reserved.
//

import MBProgressHUD
import UIKit
import WebKit
import RxSwift
import RxCocoa

class BorrowingViewController: UIViewController, WKScriptMessageHandler {
    
    let disposeBag = DisposeBag()
    var vm = BorrowingViewModel()
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "JsModel" {
            if let b = message.body as? Dictionary<String, String> {
               if let title = b["platformTitle"],
                let url = b["platformURL"] {
                
                let webVC = WebLoadViewController()
                webVC.viewWith(title: title, url: url)
                webVC.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(webVC, animated: true)
                
               }else if let _ = b["sharedURL"] {
                
                    guard UserModel.currentUser.isLogin, UMSocialManager.default()?.isInstall(.wechatSession) ?? false else {
                        return
                    }
                    //显示分享面板
                    UMSocialUIManager.showShareMenuViewInWindow { (platform, userInfo) in
                        self.shareWebPageTo(platformType: platform)
                    }
                }
            }
        }
    }
    
    func shareWebPageTo(platformType: UMSocialPlatformType)
    {
        //创建分享消息对象
        let messageObject = UMSocialMessageObject()
        //创建网页内容对象
        let shareObject = UMShareWebpageObject.shareObject(withTitle: "想知道被银行薅了多少？来信用卡体检App", descr:"一键体检出信用卡薅走你的各种费用，专业的防薅建议，让你更好用卡", thumImage: UIImage(named: "email-icon"))
        //设置网页地址
        let phone = UserModel.currentUser.telephone.toLoginNumber()
        shareObject?.webpageUrl = "http://www.kingcredit.top/#/shareinvite?shared=\(phone)"
        //分享消息对象设置分享内容对象
        messageObject.shareObject = shareObject
        //调用分享接口
        UMSocialManager.default()?.share(to:platformType, messageObject: messageObject, currentViewController: self, completion: { data, error in
                if (error != nil) {
                    print("************Share fail with error %@*********\(String(describing: error))")
                }else{
                    print("response data is \(String(describing: data))");
                    
                }
            })
    }
    
    lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.preferences = WKPreferences()
        config.preferences.minimumFontSize = 10
        config.preferences.javaScriptEnabled = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = false
        config.processPool = WKProcessPool()
        
        config.userContentController = WKUserContentController()
        config.userContentController.add(self, name: "JsModel")
        let webView: WKWebView = WKWebView(frame: CGRect.zero, configuration: config)
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false

        return webView
    }()
    private let mProgressView: UIProgressView = UIProgressView(frame: CGRect.zero)
    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
        bindWebView()
//        loadWeb()
        
        title = vm.title
//        if let title = UserDefaults.standard.object(forKey: "tabbarTitle") as? String{
//            self.setTabbarTitle(title)
//        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func makeUI() {
        navigationController?.isNavigationBarHidden = self.vm.localUrl == nil
        view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.bottom.equalTo(view.layoutMarginsGuide)
            }
            make.top.equalTo(0)
        }
        mProgressView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        mProgressView.progressTintColor = UIColor(hex: "#FF8300")
        mProgressView.trackTintColor = .white
        mProgressView.alpha = 0
        view.addSubview(mProgressView)
        mProgressView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.height.equalTo(2)
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.top.equalTo(view.layoutMarginsGuide)
            }
        }
    }

    private func bindWebView() {
        webView.rx.observeWeakly(Float.self, "estimatedProgress").subscribe(onNext: { [unowned self] (progress) in
            guard let progress = progress else {
                return
            }
            print(progress)
            self.mProgressView.setProgress(progress, animated: true)
            if progress >= 1.0 {
                UIView.animate(withDuration: 0.5, animations: {
                    self.mProgressView.alpha = 0
                })
            } else {
                self.mProgressView.alpha = 1
            }
          
        }).disposed(by: disposeBag)
        
//        MBProgressHUD.showHUD(addedTo: self.view)
        vm.getWebUrl()
            .bind{[unowned self] url in
//                MBProgressHUD.hide(for: self.view, animated: true)
                self.loadWeb(url)
            }
            .disposed(by: disposeBag)
        
//        vm.tabbarTitle
//            .bind{[unowned self] title in
//                UserDefaults.standard.set(title, forKey: "tabbarTitle")
//                UserDefaults.standard.synchronize()
//                self.setTabbarTitle(title)
//            }
//            .disposed(by: disposeBag)
    }
    
    private func loadWeb(_ url: String) {
        webView.load(URLRequest(url: URL(string: url)!))
    }
    
//    func setTabbarTitle(_ title: String) {
//        if let item = self.tabBarController?.tabBar.items?[1] {
//            item.title = title;
//        }
//    }
}
