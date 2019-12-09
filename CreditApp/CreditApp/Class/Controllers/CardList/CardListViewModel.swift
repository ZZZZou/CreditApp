//
//  CMListViewModel.swift
//  CreditApp
//
//  Created by w22543 on 2018/11/13.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import RealmSwift
import RxRealm
import RxCocoa
import Moya
import ObjectMapper
import RxSwift
import RxDataSources
import Action
import Foundation

class CardListViewModel: Prealm {
    let provider: Networking
    let user: UserModel
    let coordinator: SceneCoordinator
    
    fileprivate var bag = DisposeBag()
    fileprivate var _cards = BehaviorRelay<[CMTotalCardModel]>(value: [])
    fileprivate let allLocalLatestMonthDatas = BehaviorRelay<[ConsumeBillModel]>(value: [])
    fileprivate var defaultCards: [CMTotalCardModel] {
        return [.demo(), .empty()]
    }
    fileprivate var _numOfItem: Int {
        return _cards.value.count
    }
    
    let currentLatestMonthData = BehaviorRelay<ConsumeBillModel?>(value: nil)
    
    let itemIndexSwitched = BehaviorRelay(value: 0)
    var refreshComplete = PublishSubject<Void>()
    
    var cards: Observable<[CMTotalCardModel]> {
        return _cards.asObservable()
    }

    var currentCard: CMTotalCardModel {
        return _cards.value[itemIndexSwitched.value]
    }
    
    func card(with index: Int) -> CMTotalCardModel{
        return _cards.value[index]
    }
    
    init(provider: Networking = Networking.newDefaultNetworking(), user: UserModel = UserModel.currentUser, coordinator: SceneCoordinator) {
        self.provider = provider
        self.user = user
        self.coordinator = coordinator
        
        getCardsFromLocal()
        getLatestMonthDatasFromLocal()
        getCardsFromWeb()
     
        observeLoginStatus()
        internalBind()
    }
    
    func internalBind() {
        _cards
            .filter{$0.count > 0}
            .map{_ in 0}
            .bind(to: itemIndexSwitched).disposed(by: bag)
        
        Observable.combineLatest(itemIndexSwitched, allLocalLatestMonthDatas){($0, $1)}
            .map{ [unowned self] index, allMonthDatas -> ConsumeBillModel? in
                guard self.indexIsValid(index) else{
                    return nil
                }
                let card = self._cards.value[index]
                if card.isDemo {return .demoOne()}
                if card.isEmpty {return nil}
                
                let filtedModel = allMonthDatas.filter{ $0.realmKey == card.realmKey}.first
                return filtedModel
            }
            .do(onNext: { [unowned self] in
                let index = self.itemIndexSwitched.value
                if ($0 == nil || $0!.isTimeOut()) && self.indexIsValid(index) {
                    let card = self._cards.value[index]
                    if !card.isEmpty && !card.isDemo{
                        self.requestMouthsData(with: card)
                    }
                }
            })
            .bind(to: currentLatestMonthData)
            .disposed(by: bag)
    }
    
    func indexIsValid(_ index: Int) -> Bool{
        return index >= 0 && index < self._numOfItem
    }
    
    func loginStatus() -> Observable<Bool> {
        return user.loginStatus
    }
    
    func observeLoginStatus() {
        loginStatus()
            .bind{[unowned self] bl in
                if !bl {
                    self._cards.accept(self.defaultCards)
                    self.allLocalLatestMonthDatas.accept([])
                }
            }.disposed(by: bag)
    }
    
    func getLatestMonthDatasFromLocal() {
        loginStatus()
            .filter{ $0 }
            .bind{[unowned self] _ in
                let realm = Realm.realm()!
                let result = realm.objects(ConsumeBillModel.self)
                Observable.array(from: result)
                    .bind{ o in
                        print("realm update")
                        self.allLocalLatestMonthDatas.accept(o)
                    }
                    .disposed(by: self.bag)
            }.disposed(by: bag)
        
    }
    
    func getCardsFromLocal() {
        
        loginStatus()
            .filter{ $0 }
            .bind{[unowned self] _ in
                let realm = Realm.realm()!
                let result = realm.objects(CMTotalCardModel.self).sorted(byKeyPath: "delinquencyDay", ascending: false)
                Observable.array(from: result)
                    .bind{ o in
                        var finalCards = o
                        if finalCards.count == 0 {
                            finalCards = self.defaultCards
                        }
                        self._cards.accept(finalCards)
                    }
                    .disposed(by: self.bag)
        }.disposed(by: bag)
        
        
    }
    
    func getCardsFromWeb() {
        loginStatus()
            .filter{ $0 }
            .bind{[unowned self] _ in
                self.requestCardsData()
            }
            .disposed(by: self.bag)
    }
    
     func requestCardsData(){
        let request =
            self.provider.request(.cardsList(isAllUpdate: true))
            .toModelArray()
            .map{ models -> [CMTotalCardModel] in
                models ?? []
            }
        request
            .catchError{[unowned self] error -> Observable<[CMTotalCardModel]> in
                self.refreshComplete.onNext(())
                return Observable.empty()
            }
            .bind{[unowned self] models in
                models.forEach{$0.generateRealmKey()}
                let realm = Realm.realm()!
                Observable.just(models)
                    .bind(to: realm.rx.add(update: true))
                    .disposed(by: self.bag)
            
                self.refreshComplete.onNext(())
                
            }
            .disposed(by: bag)
    }
    
    func requestMouthsData(with card: CMTotalCardModel) {
       
        provider.request(.cardAllMonthsBill(bank: card.bank, user_name_hello: card.user_name_hello, from_mail: card.from_mail, is_first_bill: true))
            .toModelArray()
            .map{ models -> [ConsumeBillModel] in
                models ?? []
            }
            .catchError{ error -> Observable<[ConsumeBillModel]> in
                return Observable.empty()
            }
            .bind{[unowned self] models in
                models.forEach{
                    $0.generateRealmKey()
                    if $0.isTimeOut() {
                        $0.updateLastModifiedTime()
                    }
                }
                let realm = Realm.realm()!
                Observable.just(models)
                    .bind(to: realm.rx.add(update: true))
                    .disposed(by: self.bag)
            }
            .disposed(by: bag)
    }
    
    lazy var detailAction: Action<Int, Void> = { `self` in
        return Action{ selectedIndex in
//            let bl = self.user.isLogin
//            let model = self._cards.value[selectedIndex]
//            if !bl && !model.isDemo {
//                return self.pushToLogin{ logined in
//
//                    if logined {
//                        self.requestCardsData()
////                        self.pushToDetail(selectedIndex)
//                    }
//                }
//            }
            return self.pushToDetail(selectedIndex)
        }
    }(self)
    
    lazy var addAction: CocoaAction = { `self` in
        return Action { _ in
            let bl = self.user.isLogin
            if bl {
                return self.pushToAddingMail()
            }else{
                
                return self.pushToLogin{logined in
                    if logined {
                        self.requestCardsData()
                        self.pushToAddingMail()
                    }
                }
                
            }
            
        }
    }(self)
    
    func refreshAction() -> CocoaAction {
        return Action { _ in
            self.requestCardsData()
            
            return self.refreshComplete.take(1)
        }
    }
    
    lazy var restartAction: Action<Int, Void> = { `self` in
        return Action{ selectedIndex in
            let card = self._cards.value[selectedIndex]
            let res = self.realmMailSearch(card.from_mail)
            if let m = res.last {
                let vm = WebAutoLoginViewModel(email: card.address, autoModel: m, coordinator: self.coordinator)
                return self.coordinator
                    .transition(to: .email(.webAutoLogin(vm)), type: .push)
                    .asObservable()
                    .map{ _ in }
            } else {
                print(card.from_mail)
                let vm = WebLoginViewModel(email: card.address, coordinator: self.coordinator)
                return self.coordinator
                    .transition(to: .email(.webLogin(vm)), type: .push)
                    .asObservable()
                    .map{ _ in }
                
            }
        }
    }(self)
    
    @discardableResult
    func pushToDetail(_ selectedIndex: Int) -> Observable<Void>{
        let model = self._cards.value[selectedIndex]
        let vm = ContainerViewModel(coordinator: self.coordinator, card: model)
        
        return self.coordinator
            .transition(to: .credit(.container(vm)), type: .push)
            .asObservable()
            .map{ _ in }
    }
    
    @discardableResult
    func pushToAddingMail() -> Observable<Void>{
        let scene = Scene.email(.selectEmail(SelectEmailViewModel(coordinator: self.coordinator)))
        return self.coordinator
            .transition(to: scene, type: .push)
            .asObservable()
            .map{ _ in }
    }
    
    @discardableResult
    func pushToLogin(_ complete: @escaping (Bool) -> Void) -> Observable<Void> {
        let loginVM = LoginViewModel(coordinator: self.coordinator)
        let scene = Scene.login(loginVM)
        self.coordinator
            .transition(to: scene, type: .modal)
        
        return loginVM.loginComplete
            .take(1)
            .do(onNext:{ logined in
                complete(logined)
            })
            .map{ _ in }
    }
    
}



