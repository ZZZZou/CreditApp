//
//  WebLogin126ViewController.swift
//  CreditApp
//
//  Created by 胡骏 on 2018/9/10.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import UIKit

import XCGLogger
import Alamofire
import SwiftyJSON

class WebLogin126ViewController: UIViewController {

    weak var delegate: WebLoginViewControllerDelegate?
    
    
    var webView: UIWebView = UIWebView()
    var logg = XCGLogger.default
    
    var upDict: [String: Any] = [String: Any]()
    var userMail = ""
    private var isLogin = false
    private let loadingView = LoadingView()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(loadingView)
        loadingView.snp.makeConstraints { (make) in
            make.center.equalTo(view.center)
            make.size.equalTo(CGSize(width: 32, height: 32))
        }
        
        webView.isHidden = true
        webView.delegate = self
        webView.frame = CGRect(x: 0, y: 0, width: kWidth, height: kHight)
        view.addSubview(webView)
        let url = URL(string: "https://passport.126.com/ydzj/maildl?product=mail126&pdconf=yddl_mail126_conf&mc=146E1F&curl=https%3A%2F%2Fmail.126.com%2Fentry%2Fcgi%2Fntesdoor%3Ffrom%3Dsmart%26language%3D0%26style%3D11%26destip%3D192.168.202.48%26allssl%3Dfalse%26df%3Dsmart_ios")
        webView.loadRequest(URLRequest(url: url!))
        
    }
    
    deinit {
        print("WebLogin126ViewController gun@@@@@@@")
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
        let userjs = "document.getElementsByName('account')[0].value;"
        let passwordjs = "document.getElementsByTagName('input')[1].value;"
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
        
        let userjs = "var userput = document.getElementsByName('account')[0];"
            + "userput.focus();" + "userput.value='" + mailstring + "';"
            + "var evt = document.createEvent('HTMLEvents');evt.initEvent('input', false, true);"
            + "userput.dispatchEvent(evt);"
        
        let passwordjs = "var passput = document.getElementsByTagName('input')[1];" + "passput.focus();" + "passput.value='" + passwordstring + "';" + "passput.dispatchEvent(evt);"
        logg.debug(userjs)
        logg.debug(passwordjs)
        
        _ = web.stringByEvaluatingJavaScript(from: userjs)
        SwiftTools.timeDelayWithTmer(0.5) {
            _ = web.stringByEvaluatingJavaScript(from: passwordjs)
        }
        let loadjs = "document.getElementsByTagName('button')[0].click()"
        SwiftTools.timeDelayWithTmer(1) {
            _ = web.stringByEvaluatingJavaScript(from: loadjs)
        }
    }
    fileprivate var isFirstLoad = true
    fileprivate var isAutoLoadSuccess = false
}


extension WebLogin126ViewController: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if isFirstLoad {
            let hidhd = "var hdyou = document.getElementsByClassName('g-hd hd-you')[0];hdyou.style='display: none;';"
            _ = webView.stringByEvaluatingJavaScript(from: hidhd)
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
            logg.debug(relativeUrl)
            let predicate = NSPredicate(format: "SELF MATCHES %@", "https?:\\/\\/mail\\.126.com\\/m\\/main\\.jsp\\?sid=.*df=\\w{5,12}")
            getWebUserPassword(webView)
            let isurl = predicate.evaluate(with: relativeUrl)
            if !isurl || isLogin {
                return true
            }
            isLogin = true
            if let cookies = cookies{
                var ca = [[String : Any]]()
                for c in cookies {
                    let domain = c.domain
                    let name = c.name
                    let value = c.value
                    let path = c.path
                    let dict = ["domain": domain, "name": name, "value": value, "path": path, "secure": false] as [String : Any]
                    ca.append(dict)
                    if c.name == "MAIL_PINFO" || c.name == "P_INFO" {
                        let regex = try! NSRegularExpression(pattern: "[A-Za-z0-9\\u4e00-\\u9fa5]+@[a-zA-Z0-9_-]+(\\.[a-zA-Z0-9_-]+)+", options: NSRegularExpression.Options.dotMatchesLineSeparators)
                        let results = regex.matches(in: c.value, options: NSRegularExpression.MatchingOptions.init(rawValue: 0), range: NSRange.init(location: 0, length: c.value.count))
                        for str in results {
                            let nsStr = c.value as  NSString  //可以方便通过range获取子串
                            let r = nsStr.substring(with: str.range)
                            userMail = r
                            break
                        }
                    }
                }
                logg.debug("上传cookie")
                isAutoLoadSuccess = true
                NotificationCenter.default.post(name: Notification.Name(rawValue: kNotifications.EmailAutoLoadDefaults.rawValue), object: nil, userInfo: [kNotifications.EmailAutoLoadStatus: true])

                
                let user = UserModel.currentUser

                let resdic = ["userEmail": userMail, "url": relativeUrl, "data": ca, "address": "126", "userNumber": user.telephone, "userUUID": user.user_uuid!] as [String : Any]
                let manager = AFHTTPSessionManager(sessionConfiguration: URLSessionConfiguration.default)
                manager.requestSerializer = AFJSONRequestSerializer.init()
                upDict = resdic
                if let d = delegate {
                    d.WebLoginViewControllerFindCookies(self, cookies: resdic, mail: userMail, password: mailPass, address: "126", inputAccount: inputAccount)
                }
            }
        }
        return true
    }
    
}

