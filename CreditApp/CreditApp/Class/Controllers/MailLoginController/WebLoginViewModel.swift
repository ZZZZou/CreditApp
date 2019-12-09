//
//  WebLoginViewModel.swift
//  CreditApp
//
//  Created by wang on 2018/11/25.
//  Copyright © 2018 CreditManager. All rights reserved.
//

import Foundation

protocol WebLoginViewModelProtocol {
    var email: String {get set}
    var coordinator: SceneCoordinator {get set}
}

struct WebLoginViewModel: WebLoginViewModelProtocol {
    
    var email: String
    var coordinator: SceneCoordinator
    
    init(email: String, coordinator: SceneCoordinator) {
        self.email = email
        self.coordinator = coordinator
    }
}

struct WebAutoLoginViewModel: WebLoginViewModelProtocol {
    
    var email: String
    var coordinator: SceneCoordinator
    var autoModel: MailModel
    
    init(email: String, autoModel: MailModel, coordinator: SceneCoordinator) {
        self.email = email
        self.autoModel = autoModel
        self.coordinator = coordinator
    }
}
