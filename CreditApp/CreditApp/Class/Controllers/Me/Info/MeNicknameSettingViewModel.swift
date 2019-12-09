//
//  MeNicknameSettingViewModel.swift
//  CreditApp
//
//  Created by w22543 on 2019/1/11.
//  Copyright © 2019年 CreditManager. All rights reserved.
//

import RealmSwift
//import RxRealm
import RxSwift
import Action
import UIKit

struct MeNicknameSettingViewModel {
    
    let provider: Networking
    
    let coordinator: SceneCoordinator
    
    let user = UserModel.currentUser
    let bag = DisposeBag()
    
    init(provider: Networking = Networking.newDefaultNetworking(), coordinator: SceneCoordinator) {
        self.provider = provider
        self.coordinator = coordinator
    }
    
    func saveAction(_ nickname: String) -> Observable<Bool>{
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
//            try! Realm.userRealm().write {
//                self.user.nickname = nickname
//            }
//
//            self.coordinator.pop()
//        }
        
        let subject = PublishSubject<Bool>()
        provider.request(.changeUsername(userName: nickname))
            .toRawDataDictionary()
            .map{dic -> String? in
                if let key = dic["user_name"] as? String {
                    return key
                }
                return nil
            }
            .do(onNext:{ key in
                if key != nil {
                    try! Realm.userRealm().write {
                        self.user.nickname = key!
                    }
                }
            })
            .map{$0 != nil}
            .subscribe(onNext: {bl in
                subject.onNext(bl)
                if bl {self.coordinator.pop()}
            }, onError: { _ in
                subject.onNext(false)
            })
            .disposed(by: self.bag)
        
        return subject.asObservable()
        
    }
    
    
}
