//
//  MeInfoViewModel.swift
//  CreditApp
//
//  Created by w22543 on 2019/1/8.
//  Copyright © 2019年 CreditManager. All rights reserved.
//

import Action
import Foundation

struct MeInfoViewModel {
    let provider: Networking
    let coordinator: SceneCoordinator
    let user: UserModel = UserModel.currentUser
    
    init(provider: Networking = Networking.newDefaultNetworking(), coordinator: SceneCoordinator) {
        self.provider = provider
        self.coordinator = coordinator
    }
    
    func nicknameAction() -> CocoaAction {
        return CocoaAction{
            let vm = MeNicknameSettingViewModel(coordinator: self.coordinator)
            return self.coordinator
                .transition(to: .me(.nickname(vm)), type: .push)
                .asObservable()
                .map{_ in}
        }
    }
    
    func iconAction() -> CocoaAction {
        return CocoaAction{
            let vm = MeIconViewModel(coordinator: self.coordinator)

            return self.coordinator
                .transition(to: .me(.icon(vm)), type: .push)
                .asObservable()
                .map{_ in}
        }
    }
    
}
