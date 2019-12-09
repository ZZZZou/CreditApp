//
//  WebLoadViewController.swift
//  CreditApp
//
//  Created by 胡骏 on 2019/3/13.
//  Copyright © 2019 CreditManager. All rights reserved.
//

import UIKit
import WebKit
import RxSwift
import RxCocoa

class WebLoadViewController: UIViewController, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
    }
    
    private var webTitle = ""
    private var webURL = ""

    let disposeBag = DisposeBag()
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
        loadWeb()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = true

    }
    
    func viewWith(title: String, url: String) {
        webTitle = title
        webURL = url
    }
    
    private func makeUI() {
        title = webTitle
        view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide)
                make.bottom.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.top.equalTo(view.layoutMarginsGuide)
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
    }
    
    private func loadWeb() {
        webView.load(URLRequest(url: URL(string: webURL) ?? URL(fileURLWithPath: "")))
    }
}
