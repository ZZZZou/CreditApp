//
//  ContainerViewModel.swift
//  CreditApp
//
//  Created by wang on 2019/4/24.
//  Copyright © 2019 CreditManager. All rights reserved.
//

import Action
import RxSwift
import Foundation

struct ContainerViewModel {
    let provider: Networking
    
    let coordinator: SceneCoordinator
    
    let card: CMTotalCardModel
    
    let bankBillVM: BankBillViewModel
    let consumeBillVM: ConsumeBillViewModel
    
    var isLeft = true
    
    init(provider: Networking = Networking.newDefaultNetworking(), coordinator: SceneCoordinator, card: CMTotalCardModel) {
        self.coordinator = coordinator
        self.provider = provider
        self.card = card
        
        
        self.bankBillVM = BankBillViewModel(provider: provider, coordinator: coordinator, card: card)
        self.consumeBillVM = ConsumeBillViewModel(provider: provider, coordinator: coordinator, card: card)
    }
    
    func restartAction() -> CocoaAction {
        return bankBillVM.restartAction()
    }
}
