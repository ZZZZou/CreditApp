//
//  LoginViewModel.swift
//  CreditApp
//
//  Created by w22543 on 2018/11/23.
//  Copyright © 2018年 CreditManager. All rights reserved.
//

import Action
import RealmSwift
import RxSwift
import Foundation

struct LoginViewModel {
    
    let bag = DisposeBag()
    let loginComplete = PublishSubject<Bool>()
    
    let provider: Networking = Networking.newDefaultNetworking()
    let coordinator: SceneCoordinator
    
    init(coordinator: SceneCoordinator) {
        self.coordinator = coordinator
    }
    
    func validateIphoneNum(num: String?) -> Bool {
        guard let num = num else {
            return false
        }
        let regexp = try! NSRegularExpression(pattern: "^(13[0-9]|14[579]|15[0-3,5-9]|16[6]|17[0135678]|18[0-9]|19[89])\\d{8}$", options: .caseInsensitive)
        let result = regexp.rangeOfFirstMatch(in: num, range: NSRange(location: 0, length: num.count))
        
        return result.length == 0 ? false : true
    }
    
    func validateCaptcha(num: String?) -> Bool {
        guard let num = num else {
            return false
        }
        return num.count == 4
    }
    
    func loginAction(iphone: String, captcha: String) -> Observable<Bool> {
        
        let complete = PublishSubject<Bool>()
        self.provider
            .request(.login(iphone: iphone, captcha: captcha))
            .toRawDataDictionary()
            .map{ dataDic -> (String, Dictionary<String, Any>) in
                guard let uuid = dataDic["user_uuid"] as? String else{
                    throw WebError.jsonStruct
                }
                return (uuid, dataDic)
            }.subscribe(onNext:{(uuid, dataDic)  in
                let user = UserModel.currentUser
                let realm = Realm.userRealm()
                try! realm.write{
                    user.user_uuid = uuid
                    user.telephone = iphone
                    user.nickname = dataDic["user_name"] as? String ?? ""
                    user.iconKey = dataDic["user_image"] as? String ?? ""
                    user.createDate = dataDic["create_date"] as? String ?? ""
                }
                Realm.Configuration.defaultConfiguration = realm.configuration
                
                self.coordinator
                    .pop(animated: true)
                    .subscribe{_ in
                        self.loginComplete.onNext(true)
                        complete.onNext(true)
                        print("login view controller did dissmiss")
                    }
                    .disposed(by: self.bag)
                
            }, onError: { error in
                print("login fail \(error)")
                complete.onNext(false)
            })
            .disposed(by: self.bag)
        
        return complete
            .asObserver()
            .take(1)
    }
    
    
    lazy var authCodeAction = { `self` in
        return Action<(String, String), Void> { (arg) -> Observable<Void> in
            let (iphone, keynumber) = arg
            let complete = PublishSubject<Void>()
            self.provider.request(.loginGetAuthCode(iphone: iphone, keyNumber: keynumber)).toRawDataDictionary().catchError({ (error) -> Observable<[String: Any]> in
                return Observable<[String: Any]>.never()
            }).map{_ in }.subscribe().disposed(by: self.bag)
            return complete
                .asObserver()
                .take(1)
        }
    }(self)
    
    func dissAction() -> CocoaAction {
        return Action {
            return self.coordinator.pop(animated: true)
                .asObservable()
                .map{ _ in }
                .do(onCompleted:{
                    self.loginComplete.onNext(false)
                    print("login view controller did dissmiss")
                })
        }
    }
    
    lazy var loadWebAction: Action<Void, Void> = { `self` in
        return Action{
            var vm = BorrowingViewModel()
            vm.localUrl = "http://www.kingcredit.top/#/terms/1"
            vm.title = "用户协议"
            return self.coordinator
                .transition(to: .webBrowser(vm), type: .push)
                .asObservable()
                .map{ _ in }
        }
    }(self)
}
