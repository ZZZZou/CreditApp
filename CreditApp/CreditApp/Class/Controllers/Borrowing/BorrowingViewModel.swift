//
//  BorrowingViewModel.swift
//  CreditApp
//
//  Created by wang on 2019/3/23.
//  Copyright © 2019 CreditManager. All rights reserved.
//
import RealmSwift
//import RxRealm
import RxSwift
import Action
import UIKit
import Foundation

struct BorrowingViewModel {
    let provider: Networking
    let bag = DisposeBag()
    
    var title: String?
    var localUrl: String?
    
    init(provider: Networking = Networking.newDefaultNetworking()) {
        self.provider = provider
        
        
    }
    
//    func requestIsOnline() -> Observable<Bool>{
//
//        let subject = PublishSubject<Bool>()
//        provider.request(.isOnline(), needLogined: false)
//            .toRawDataDictionary()
//            .do(onNext: { dic in
//                if let subDic = dic["function"] as? [String: Any], let title = subDic["loan_title_tab"] as? String{
//                    self.tabbarTitle.onNext(title)
//                }
//            })
//            .map{dic -> Bool in
//                if let subDic = dic["function"] as? [String: Any], let isOneline = subDic["loan_ios"] as? Bool{
//                    return isOneline
//                }
//                return false
//            }
//            .subscribe(onNext: {bl in
//                subject.onNext(bl)
//            }, onError: { _ in
//                subject.onNext(false)
//            })
//            .disposed(by: self.bag)
//
//        return subject.asObservable()
//    }
    
    func getWebUrl() -> Observable<String>{
        if let url = self.localUrl  {
            return Observable<String>.just(url)
        }else {
//            let subject = PublishSubject<String>()
//            requestIsOnline()
//                .bind{ isOnline in
//                    if isOnline {
//                        subject.onNext("http://www.kingcredit.top/#/borrowing")
//                    }else {
//                        subject.onNext("http://www.kingcredit.top/#/aboutus")
//                    }
//                }
//                .disposed(by: self.bag)
            let isOnline = UserDefaults.standard.object(forKey: "isOnline") as? Bool
            
            let bl = isOnline != nil && isOnline!
            
            let url: String = bl ? "http://www.kingcredit.top/#/borrowing" : "http://www.kingcredit.top/#/aboutus"
            return Observable<String>.just(url)
        }
    }
}
