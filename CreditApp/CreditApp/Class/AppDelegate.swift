//
//  AppDelegate.swift
//  CreditApp
//
//  Created by 胡骏 on 2018/7/24.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import Action
import RxSwift
import UIKit
import RealmSwift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coordinator: SceneCoordinator!
    let bag: DisposeBag = DisposeBag()
    let provider = Networking.newDefaultNetworking()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        IQKeyboardManager.shared.enable = true
        
        //UM
        MobClick.setCrashReportEnabled(true)
        UMConfigure.setLogEnabled(true)
        UMConfigure.setEncryptEnabled(true)
        UMConfigure.initWithAppkey("5c9f200f0cafb25479000de1", channel: "appStore");
        // U-Share 平台设置
        configUSharePlatforms()
        confitUShareSettings()
        
        let config = Realm.Configuration(schemaVersion: 3,
                                         migrationBlock: { (_, _) in })
        Realm.Configuration.defaultConfiguration = config
        
        requestIsOnline()
            .bind{ bl in
                UserDefaults.standard.set(bl, forKey: "isOnline")
                UserDefaults.standard.synchronize()
            }
            .disposed(by: bag)

        if needGuide() {
            let guide = GuideViewController()
            window?.rootViewController = guide;
            window?.makeKeyAndVisible()
        }else{
            coordinator = SceneCoordinator(window: window!)
            let rootScent = Scene.root(coordinator)
            coordinator.transition(to: rootScent, type: .root)
        }
        return true
    }
    
    func configUSharePlatforms() {
        /* 设置微信的appKey和appSecret */
        UMSocialManager.default()?.setPlaform(.wechatSession, appKey: "wxb3ccf73fbb57a766", appSecret: "1c7a30b477b77f505b07c6e64cb8745e", redirectURL: "http://mobile.umeng.com/social")
        /*
         * 移除相应平台的分享，如微信收藏
         */
        UMSocialManager.default()?.removePlatformProvider(with: .wechatFavorite)

        /* 设置分享到QQ互联的appID
         * U-Share SDK为了兼容大部分平台命名，统一用appKey和appSecret进行参数设置，而QQ平台仅需将appID作为U-Share的appKey参数传进即可。
         */
//        UMSocialManager.default()?.setPlaform(.QQ, appKey: "1105821097", appSecret: nil, redirectURL: "http://mobile.umeng.com/social")
    }
    
    func confitUShareSettings() {
        
    }
    
    func needGuide() -> Bool {
        let key = "CFBundleShortVersionString";
        let lastVersion = UserDefaults.standard.object(forKey: key) as? String
        let currentVersion = Bundle.main.infoDictionary?[key] as! String
        
        
        if let last = lastVersion, last == currentVersion {
            return false
        }else {
            UserDefaults.standard.set(currentVersion, forKey: key)
            UserDefaults.standard.synchronize()
            return true
        }
    }
    
    func requestIsOnline() -> Observable<Bool>{
        let subject = PublishSubject<Bool>()
        provider.request(.isOnline(), needLogined: false)
            .toRawDataDictionary()
            .do(onNext: { dic in
                if let subDic = dic["function"] as? [String: Any], let title = subDic["loan_title_tab"] as? String{
                    
                    UserDefaults.standard.set(title, forKey: "tabTitle")
                    UserDefaults.standard.synchronize()
                }
            })
            .map{dic -> Bool in
                if let subDic = dic["function"] as? [String: Any], let isOneline = subDic["loan_ios"] as? Bool{
                    return isOneline
                }
                return false
            }
            .subscribe(onNext: {bl in
                subject.onNext(bl)
            }, onError: { _ in
                subject.onNext(false)
            })
            .disposed(by: self.bag)
        
        return subject.asObservable()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let result = UMSocialManager.default()?.handleOpen(url, options: options)
        
        if let r = result {
            
        }
        
        return result ?? false
    }


}

