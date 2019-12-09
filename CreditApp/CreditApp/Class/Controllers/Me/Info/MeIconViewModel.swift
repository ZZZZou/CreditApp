//
//  MeIconViewModel.swift
//  CreditApp
//
//  Created by w22543 on 2019/1/11.
//  Copyright © 2019年 CreditManager. All rights reserved.
//

import RealmSwift
import RxCocoa
import RxSwift
import Action
import UIKit

struct MeIconViewModel {
    
    let user = UserModel.currentUser
    let provider: Networking
    let coordinator: SceneCoordinator
    let bag = DisposeBag()
    
    init(provider: Networking = Networking.newDefaultNetworking(), coordinator: SceneCoordinator) {
        self.provider = provider
        self.coordinator = coordinator
    }
    
    func backAction() -> CocoaAction {
        return CocoaAction{
            return self.coordinator
                .pop(animated: true)
                .asObservable()
                .map{_ in}
        }
    }
    
//    lazy var uploadImageAction: Action<UIImage, Void> = {`self` in
//        return Action{image in
//            if
//
//            return Observable.empty()
//        }
//    }(self)
    
    func uploadImageAction(_ img: UIImage) -> Observable<Bool> {
        
        
        if let data = img.pngData(){
            
            let subject = PublishSubject<Bool>()
            self.provider.request(.uploadImage(imageData: data))
                .toRawDataDictionary()
                .map{dic -> String? in
                    if let key = dic["user_image"] as? String {
                        return key
                    }
                    return nil
                }
                .do(onNext:{ key in
                    if key != nil {
                        try! Realm.userRealm().write {
                            self.user.iconKey = key!
                            self.user.icon = img
                        }
                    }
                })
                .map{$0 != nil}
                .subscribe(onNext: {bl in
                    subject.onNext(bl)
                }, onError: { _ in
                    subject.onNext(false)
                })
                .disposed(by: self.bag)
            
            return subject.asObservable()
        }
        return Observable.just(false)
    }
}
