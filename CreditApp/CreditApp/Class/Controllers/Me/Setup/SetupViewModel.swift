//
//  SetupViewModel.swift
//  CreditApp
//
//  Created by w22543 on 2018/11/26.
//  Copyright © 2018年 CreditManager. All rights reserved.
//

import RealmSwift
import Action
import RxSwift
import Foundation

struct SetupViewModel {
    
    let coordinator: SceneCoordinator
    
    let bag = DisposeBag()
    
    init(coordinator: SceneCoordinator) {
        self.coordinator = coordinator
    }
    
    func pushToFeedback() {
        let vm = MeFeedbackViewModel(coordinator: coordinator)
        coordinator.transition(to: .me(.feedback(vm)), type: .push)
    }
    
    func pushToAbout() {
        let vm = MeAboutViewModel()
        coordinator.transition(to: .me(.about(vm)), type: .push)
        
    }
    
    func exitAction() -> CocoaAction {
        return CocoaAction{
            let userRealm = Realm.userRealm()
            try! userRealm.write {
                UserModel.currentUser.clear()
            }
            return self.coordinator
                    .popToRoot(animated: true)
                    .asObservable()
                    .map{_ in}
            
        }
    }
    
    func switchAction() -> CocoaAction {
        return CocoaAction{
            let userRealm = Realm.userRealm()
            try! userRealm.write {
                UserModel.currentUser.clear()
            }
            self.coordinator
                .popToRoot(animated: false)
                .subscribe{ _ in
                    self.coordinator.transition(to: .login((LoginViewModel(coordinator: self.coordinator))), type: .modal)
                }
                .disposed(by: self.bag)
            
            return Observable.empty()
        }
    }
    
}
