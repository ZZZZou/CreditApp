//
//  MeViewModel.swift
//  CreditApp
//
//  Created by wang on 2018/11/25.
//  Copyright © 2018 CreditManager. All rights reserved.
//

import RealmSwift
import Action
import RxSwift
import Foundation

struct MeViewModel {
    
    let provider: Networking
    let coordinator: SceneCoordinator
    let user: UserModel = UserModel.currentUser
    
    let bag = DisposeBag()
    
    init(provider: Networking = Networking.newDefaultNetworking(), coordinator: SceneCoordinator) {
        self.provider = provider
        self.coordinator = coordinator
        
        requstWhenLogined()
        
    }
    
    func requstWhenLogined(){
        user.loginStatus
            .filter{$0}
            .bind{_ in
                self.requestUserIcon()
            }
            .disposed(by: bag)
    }
    
    func infoAction() ->  CocoaAction{
        return CocoaAction{ _ -> Observable<Void> in
            if self.user.isLogin {
                let vm = MeInfoViewModel(coordinator: self.coordinator)
                return self.coordinator
                    .transition(to: .me(.info(vm)), type: .push)
                    .asObservable()
                    .map{ _ in }
            }else{
                let scene = Scene.login(LoginViewModel(coordinator: self.coordinator))
                return self.coordinator
                    .transition(to: scene, type: .modal)
                    .asObservable()
                    .map{ _ in }
            }
            
        }
    }
    
    func loadShareWebAction() {
        if self.user.isLogin {
            var vm = BorrowingViewModel()
            let phone = UserModel.currentUser.telephone.toLoginNumber()
            vm.localUrl = "http://www.kingcredit.top/#/sharesend?shared=\(phone)"
            vm.title = "邀请好友"
            self.coordinator
                .transition(to: .webBrowser(vm), type: .push)
                .asObservable()
                .map{ _ in }
        }else{
            let scene = Scene.login(LoginViewModel(coordinator: self.coordinator))
            self.coordinator
                .transition(to: scene, type: .modal)
                .asObservable()
                .map{ _ in }
        }
    }
    
    func requestUserIcon() {
        let iconKey = self.user.iconKey
        guard iconKey.count > 0 else{
            return
        }
        self.provider.request(.getImage(key: iconKey))
            .filterSuccessfulStatusCodes()
            .map{ UIImage(data: $0.data)}
            .subscribe(onNext:{
                if let icon = $0 {
                    try! Realm.userRealm().write {
                        self.user.icon = icon
                    }
                }
            })
            .disposed(by: bag)
    }
}
