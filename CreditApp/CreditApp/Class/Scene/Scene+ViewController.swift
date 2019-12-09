//
//  Scene+ViewController.swift
//  CreditApp
//
//  Created by w22543 on 2018/11/19.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import RealmSwift
import RxRealm
import RxSwift
import Action
import Foundation


extension Scene {
    func viewController() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        switch self {
        case .root(let coordinator):
            
            let vc = storyboard.instantiateInitialViewController() as! UITabBarController
            let isOnline = UserDefaults.standard.object(forKey: "isOnline") as? Bool
            if isOnline == nil || !isOnline! {
                vc.viewControllers?.remove(at: 1)
            }else {
                
                let title = UserDefaults.standard.object(forKey: "tabTitle") as? String
                if let item = vc.tabBar.items?[1] {
                    item.title = title ?? "借款";
                }
            }
            var nav = vc.viewControllers!.first as! UINavigationController
            var cardListVC = nav.viewControllers[0] as! CardListViewController
            let cardListVM = CardListViewModel(coordinator: coordinator);
            cardListVC.bindViewModel(to: cardListVM)
            
            
            nav = vc.viewControllers!.last as! UINavigationController
            var meVC = nav.viewControllers[0] as! MeViewController
            let meVM = MeViewModel(coordinator: coordinator);
            meVC.bindViewModel(to: meVM)
            if vc.viewControllers?.count == 3 {
                
            }
            
            for nav in vc.viewControllers!{
                self.setupNavigationController(nav as! UINavigationController, coordinator: coordinator)
            }
      
            for item in vc.tabBar.items! {
                item.selectedImage = item.selectedImage?.withRenderingMode(.alwaysOriginal)
                item.image = item.image?.withRenderingMode(.alwaysOriginal)
                item.setTitleTextAttributes([.foregroundColor: UIColor.textBlack], for: .normal)
                item.setTitleTextAttributes([.foregroundColor: UIColor.mainOrange], for: .selected)
            }
            return vc
        case .login(let vm):
            var vc = storyboard.instantiateViewController(withIdentifier: "login") as! LoginViewController
            vc.bindViewModel(to: vm)
            let nav = UINavigationController(rootViewController: vc)
            setupNavigationController(nav, coordinator: vm.coordinator)
            return nav
            
        case .email(let subScene):
            switch subScene {
            case .selectEmail(let vm):
                var vc = storyboard.instantiateViewController(withIdentifier: "selectEmail") as! SelectEmailViewController
                vc.bindViewModel(to: vm)
                return vc
            case .webLogin(let vm):
                var vc = WebLoginViewController()
                vc.hidesBottomBarWhenPushed = true
                vc.viewWithWebLoginAddress(address: vm.email)
                vc.bindViewModel(to: vm)
                return vc
            case .webAutoLogin(let vm):
                var vc = WebLoginViewController()
                vc.hidesBottomBarWhenPushed = true
                vc.viewWithWebLoginAddress(address: vm.email)
                vc.viewWithAutoLoad(mailModel: vm.autoModel)
                vc.bindViewModel(to: vm)
                return vc
            }
        case .credit(let subScene):
            switch subScene {
            case .container(let vm):
                var vc = storyboard.instantiateViewController(withIdentifier: "container") as! ContainerViewController
                vc.bindViewModel(to: vm)
                
                var bankBill = storyboard.instantiateViewController(withIdentifier: "bankBill") as! BankBillViewController
                bankBill.bindViewModel(to: vm.bankBillVM)
                
                var consumeBill = storyboard.instantiateViewController(withIdentifier: "consumeBill") as! ConsumeBillViewController
                consumeBill.bindViewModel(to: vm.consumeBillVM)
                
                vc.addChild(bankBill)
                vc.scrollView.addSubview(bankBill.view)
                vc.leftView = bankBill.view
                
                vc.addChild(consumeBill)
                vc.scrollView.addSubview(consumeBill.view)
                vc.rightView = consumeBill.view
                
                vc.leftTableView = bankBill.tableView
                vc.rightTableView = consumeBill.tableView
                
                return vc
            case .bankBill(let vm):
                var vc = storyboard.instantiateViewController(withIdentifier: "bankBill") as! BankBillViewController
                vc.bindViewModel(to: vm)
                return vc
            case .consumeBill(let vm):
                var vc = storyboard.instantiateViewController(withIdentifier: "consumeBill") as! ConsumeBillViewController
                vc.bindViewModel(to: vm)
                return vc
            }
        case .me(let subScene):
            switch subScene{
            case .setup(let vm):
                var vc = storyboard.instantiateViewController(withIdentifier: "me.setup") as! SetupViewController
                vc.bindViewModel(to: vm)
                return vc
            case .info(let vm):
                var vc = storyboard.instantiateViewController(withIdentifier: "me.info") as! MeInfoViewController
                vc.bindViewModel(to: vm)
                return vc
            case .feedback(let vm):
                var vc = storyboard.instantiateViewController(withIdentifier: "me.feedback") as! MeFeedbackViewController
                vc.bindViewModel(to: vm)
                return vc
            case .about(let vm):
                var vc = storyboard.instantiateViewController(withIdentifier: "me.about") as! MeAboutViewController
                vc.bindViewModel(to: vm)
                return vc
            case .nickname(let vm):
                var vc = storyboard.instantiateViewController(withIdentifier: "me.nickname") as! MeNicknameSettingViewController
                vc.bindViewModel(to: vm)
                return vc
            case .icon(let vm):
                var vc = storyboard.instantiateViewController(withIdentifier: "me.icon") as! MeIconViewController
                vc.bindViewModel(to: vm)
                return vc
                
            }
        
        case .webBrowser(let vm):
            let vc = storyboard.instantiateViewController(withIdentifier: "webBrowser") as! BorrowingViewController
            vc.hidesBottomBarWhenPushed = true
            vc.vm = vm
            return vc
        }
        
    }
}

extension Scene {
    func setupNavigationController(_ nav: UINavigationController, coordinator: SceneCoordinator) {
        
        let action = CocoaAction{
            coordinator.pop(animated: true).asObservable().map{ _ in }
            
        }
        _ = nav.rx.willShow
            .takeUntil(nav.rx.deallocated)
            .bind{ (vc, animated) in
                vc.addLeftNavItem(with: action)
            }
        
        _ = nav.rx.willShow
            .takeUntil(nav.rx.deallocated)
            .bind{ vc, animated in
                if let firstVC = nav.viewControllers.first, firstVC == vc {
                    nav.interactivePopGestureRecognizer?.delegate = vc
                }
                
                if let tab = nav.tabBarController {
                    coordinator.resetCurrentViewControllerWhenNavDidShow(tab)
                }else{
                    coordinator.resetCurrentViewControllerWhenNavDidShow(nav)
                }
            }
        
    }
}

extension UIViewController {
    func addLeftNavItem(with action: CocoaAction) {
        
        let iconName = leftNavigationItemIconName
        var leftItem = UIBarButtonItem(image: UIImage(named: iconName)?.withRenderingMode(.alwaysOriginal), style: .plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = leftItem
        
//        _ = leftItem.rx.tap.bind(to: action.inputs)
        leftItem.rx.action = action
    }
}

@objc
protocol NavigationLeftIcon {
    var leftNavigationItemIconName: String {get}
}

extension UIViewController: NavigationLeftIcon {
    var leftNavigationItemIconName: String {
        return "<";
    }
}

extension ContainerViewController {
    override var leftNavigationItemIconName: String {
        return "white-back"
    }
}


extension UIViewController: UIGestureRecognizerDelegate {}
