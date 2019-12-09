//
//  SelectEmailViewModel.swift
//  CreditApp
//
//  Created by wang on 2018/11/25.
//  Copyright © 2018 CreditManager. All rights reserved.
//

import Action
import RxSwift
import Foundation

struct SelectEmailViewModel {
    
    let coordinator: SceneCoordinator
    let items = ["qq", "163", "126", "139"]
    
    lazy var selectEmail: Action<String, Never> = { this in
        return Action {  email in
            let vm = WebLoginViewModel(email: email, coordinator: this.coordinator)
            return this.coordinator
                .transition(to: .email(.webLogin(vm)), type: .push)
                .asObservable()
        }
    }(self)
    
    init(coordinator: SceneCoordinator) {
        self.coordinator = coordinator
    }
    
    lazy var loadWebAction: Action<Void, Void> = { `self` in
        return Action{
            var vm = BorrowingViewModel()
            vm.localUrl = "http://www.kingcredit.top/#/terms/2"
            vm.title = "服务协议"
            return self.coordinator
                .transition(to: .webBrowser(vm), type: .push)
                .asObservable()
                .map{ _ in }
        }
    }(self)
}
