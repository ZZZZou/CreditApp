//
//  BankBillViewModel.swift
//  CreditApp
//
//  Created by w22543 on 2018/11/27.
//  Copyright © 2018年 CreditManager. All rights reserved.
//

import Action
import RxSwift
import RxCocoa
import Foundation

class BankBillViewModel: Prealm {
    
    let provider: Networking
    
    let coordinator: SceneCoordinator
    
    let card: CMTotalCardModel
    
    var bill = BehaviorRelay<[BankBillSectionModel]>(value: [])
    
    let bag = DisposeBag()
    
    let tipUrls = ["http://www.kingcredit.top/#/terms/3", "http://www.kingcredit.top/#/terms/4" ,"http://www.kingcredit.top/#/terms/5" ,"http://www.kingcredit.top/#/terms/6"]
    let tipTitle = ["如何节省利息?", "如何节省手续费?" ,"如何节省年费?", "如何节省滞纳金?"]
    
    init(provider: Networking = Networking.newDefaultNetworking(), coordinator: SceneCoordinator, card: CMTotalCardModel) {
        self.coordinator = coordinator
        self.provider = provider
        self.card = card
        
        if card.isDemo {
            bill.accept(BankBillSectionModel.demo())
        }else{
//            requestInterestData()
            requestInterestData()
        }
        
    }
    
    var isDemo: Bool {
        return card.isDemo
    }
    
    var interest: Observable<String> {
        return bill.map{ models -> String in
            let filted = models.filter{ $0.consumeName == "利息" }
            guard let model = filted.first else {
                return ""
            }
            return String(model.totalFree)
        }
    }
    
    var annualFee: Observable<String> {
        return bill.map{ models -> String in
            let filted = models.filter{ $0.consumeName == "年费" }
            guard let model = filted.first else {
                return ""
            }
            return String(model.totalFree)
        }
    }
    
    var commission: Observable<String> {
        return bill.map{ models -> String in
            let filted = models.filter{ $0.consumeName == "手续费" }
            guard let model = filted.first else {
                return ""
            }
            return String(model.totalFree)
        }
    }
    
    var lateFee: Observable<String> {
        return bill.map{ models -> String in
            let filted = models.filter{ $0.consumeName == "滞纳金" }
            guard let model = filted.first else {
                return ""
            }
            return String(model.totalFree)
        }
    }
    
    var summary: Observable<[Double]> {
        return bill.map{ models -> [Double] in
            let interest = models.filter{ $0.consumeName == "利息" }.first?.totalFree ?? 0
            let commission = models.filter{ $0.consumeName == "手续费" }.first?.totalFree ?? 0
            let annualFee = models.filter{ $0.consumeName == "年费" }.first?.totalFree ?? 0
            let lateFee = models.filter{ $0.consumeName == "滞纳金" }.first?.totalFree ?? 0
            
            return [interest, commission, annualFee, lateFee]
        }
    }
    
    var amount: Observable<String> {
        return bill.map{ models -> String in
            let sum = models.reduce(0.0){ sum, model in
                return sum + model.totalFree
            }
            return String(sum)
        }
    }
    
    func foldAction(_ section: Int) -> CocoaAction {
        
        return CocoaAction{ [unowned self] _ in
            
            var rawData = self.bill.value
            var model = rawData[section]
            if model.consumeDetails.count != 0 {
                model.isOpened = !model.isOpened
                rawData.replaceSubrange(section...section, with: [model])
                self.bill.accept(rawData)
            }
            
            return Observable.empty()
        }
    }
    
    func detailAction() -> CocoaAction {
        return CocoaAction { [unowned self] _ in
            let vm = ConsumeBillViewModel(coordinator: self.coordinator, card: self.card)
            return self.coordinator
                .transition(to: .credit(.consumeBill(vm)), type: .push)
                .asObservable()
                .map{ _ in }
        }
    }
    
    func restartAction() -> CocoaAction {
        return CocoaAction{ [unowned self] in
            let res = self.realmMailSearch(self.card.from_mail)
            if let m = res.last {
                let vm = WebAutoLoginViewModel(email: self.card.address, autoModel: m, coordinator: self.coordinator)
                return self.coordinator.transition(to: .email(.webAutoLogin(vm)), type: .push).asObservable().map{ _ in }
            } else {
                print(self.card.from_mail)
                let vm = WebLoginViewModel(email: self.card.address, coordinator: self.coordinator)
                return self.coordinator.transition(to: .email(.webLogin(vm)), type: .push).asObservable().map{ _ in }

            }
        }
    }
    
    lazy var loadWebAction: Action<Int, Void> = { `self` in
        return Action{ selectedIndex in
            var title = self.tipTitle[selectedIndex]
            let url = self.tipUrls[selectedIndex]
            var vm = BorrowingViewModel()
            vm.localUrl = url
            vm.title = title
            return self.coordinator
                .transition(to: .webBrowser(vm), type: .push)
                .asObservable()
                .map{ _ in }
        }
    }(self)
    
    lazy var loadShareWebAction: Action<Void, Void> = { `self` in
        return Action{
            
            var vm = BorrowingViewModel()
            let phone = UserModel.currentUser.telephone.toLoginNumber()
            vm.localUrl = "http://www.kingcredit.top/#/sharesend?shared=\(phone)"
            vm.title = "邀请好友"
            return self.coordinator
                .transition(to: .webBrowser(vm), type: .push)
                .asObservable()
                .map{ _ in }
        }
    }(self)
    
    func requestInterestData(){
        
        self.provider.request(.bankBill(bank: card.bank, user_name_hello: card.user_name_hello))
            .toModelArray()
            .map{ models -> [BankBillSectionModel] in
                models ?? []
            }
            .catchErrorJustReturn([])
            .bind(to: bill)
            .disposed(by: bag)
    }
    
    
}
