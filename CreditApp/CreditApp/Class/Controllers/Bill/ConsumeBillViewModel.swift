//
//  ConsumeBillViewModel.swift
//  CreditApp
//
//  Created by w22543 on 2018/11/30.
//  Copyright © 2018年 CreditManager. All rights reserved.
//

import Action
import RxSwift
import RxCocoa
import Foundation

class ConsumeBillViewModel {

    let card: CMTotalCardModel
    
    let provider: Networking
    
    let coordinator: SceneCoordinator
    
    let bag = DisposeBag()
    
    let allMonthData = BehaviorRelay<[ConsumeBillModel]>(value: [])
    
    init(provider: Networking = Networking.newDefaultNetworking(), coordinator: SceneCoordinator, card: CMTotalCardModel) {
        self.coordinator = coordinator
        self.provider = provider
        self.card = card
        
        if card.isDemo {
            self.allMonthData.accept(ConsumeBillModel.demoTwo())
        }else{
            self.requestMouthsData()
        }
    }
    
    lazy var sectionAction: Action<Int, Void> = {`self` in
        return Action { section in
            let sectionModel = self.allMonthData.value[section]
            guard sectionModel.is_consumption_detail == 1 else {
                return Observable.empty()
            }
            
            if sectionModel.consumeDetails.count == 0 {
             
                sectionModel.isOpened = !sectionModel.isOpened
                self.updateDetailConsumeData(section: section, detailConsumes: [.loading()])
                
                return self.requestDetailConsumeData(section: section)
                    .asObservable()
                    .map{ _ in }
            }else{
                self.updateToggleState(section: section)
        
                return Observable.empty()
            }
            
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
    
    
    func requestMouthsData() {
   
        provider.request(.cardAllMonthsBill(bank: card.bank, user_name_hello: card.user_name_hello, from_mail: card.from_mail, is_first_bill: false))
            .toModelArray()
            .map{ $0 ?? [] }
            .catchErrorJustReturn([])
            .bind(to: allMonthData)
            .disposed(by: bag)
    }
    
    func requestDetailConsumeData(section: Int) -> Completable{
        
        let sectionModel = self.allMonthData.value[section]
        let subject = PublishSubject<Void>()
        provider.request(.detailBillOfOneMonth(bank: sectionModel.bank, year: sectionModel.refund_year , month: sectionModel.refund_month, cardIDLastFour: sectionModel.card_num_last_four))
            .toModelArray()
            .map{ items -> [ConsumeDetailModel] in
                items ?? []
            }
            .map{ items -> [ConsumeBillItem] in
                items.map{ConsumeBillItem.item(raw: $0)}
            }
            .catchErrorJustReturn([])
            .bind{ items in
                
                self.updateDetailConsumeData(section: section, detailConsumes: (items.count != 0) ? items : [.noData()])
                
                subject.onCompleted()
            }
            .disposed(by: bag)
        
        return subject.take(1)
            .ignoreElements()
        
    }
    
    func updateDetailConsumeData(section: Int, detailConsumes: [ConsumeBillItem]) {
        var sectionModels = self.allMonthData.value
        let model = sectionModels[section]
        model.consumeDetails = detailConsumes
        sectionModels[section] = model
        
        self.allMonthData.accept(sectionModels)
    }
    
    func updateToggleState(section: Int) {
        var sectionModels = self.allMonthData.value
        let model = sectionModels[section]
        model.isOpened = !model.isOpened
        sectionModels[section] = model
        
        self.allMonthData.accept(sectionModels)
    }
}
