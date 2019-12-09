//
//  SceneCoordinator.swift
//  CreditApp
//
//  Created by w22543 on 2018/11/19.
//  Copyright © 2018年 CreditManager. All rights reserved.
//

import RxSwift
import Foundation

class SceneCoordinator: SceneCoordinatorType {
    
    fileprivate var window: UIWindow
    var currentViewController: UIViewController
    fileprivate let bag = DisposeBag()
    
    required init(window: UIWindow) {
        self.window = window
        self.currentViewController = window.rootViewController!
    }
    
    static func topViewController(for viewController: UIViewController) -> UIViewController {
        if let nav = viewController as? UINavigationController {
            if let lastVC = nav.viewControllers.last {
                return self.topViewController(for: lastVC)
            }else{
                print("NO Sub ViewController of nav")
                return nav
            }
        } else if let tab = viewController as? UITabBarController {
            if let presentedVC = tab.presentedViewController {
                return self.topViewController(for:presentedVC)
            }else if let selectedVC = tab.selectedViewController {
                return self.topViewController(for: selectedVC)
            }else if let lastVC = tab.viewControllers?.last{
                return self.topViewController(for: lastVC)
            }else{
                print("NO Sub ViewController of tab")
                return tab
            }
        }else {
            return viewController
        }
    }
    
    @discardableResult
    func transition(to scene: Scene, type: SceneTransitionType) -> Completable {
        
        let subject = PublishSubject<Void>()
        let viewController = scene.viewController()
        
        switch type {
        case .root:
            let tabVC = viewController as! UITabBarController
            window.rootViewController = tabVC
            currentViewController = SceneCoordinator.topViewController(for: tabVC)
            tabVC.rx.didSelect
                .bind{ [unowned self] vc in
                    self.currentViewController = SceneCoordinator.topViewController(for:vc)
            }.disposed(by: bag)
            subject.onCompleted()
            
        case .push:
            guard let nav = currentViewController.navigationController else {
                fatalError("can't push a view controller which's super controller is not navigation controller")
            }
            _ = nav.rx.willShow
                .map{ _ in }
                .bind(to: subject)
            
            nav.pushViewController(viewController, animated: true)
            
        case .modal:
            currentViewController.present(viewController, animated: true) {
                subject.onCompleted()
            }
            currentViewController = SceneCoordinator.topViewController(for: viewController)
        }
        
        return subject.asObserver().take(1).ignoreElements()
    }
    
    @discardableResult
    func pop(animated: Bool) -> Completable {
        let subject = PublishSubject<Void>()
       if let nav = currentViewController.navigationController, nav.viewControllers.count > 1 {
            _ = nav.rx.willShow
                .map{ _ in }
                .bind(to: subject)
            
            guard let _ = nav.popViewController(animated: animated) else {
                fatalError("can't navigate back from \(currentViewController)")
            }
            
        }else if let presenter = currentViewController.presentingViewController {
            currentViewController.dismiss(animated: animated) {
                self.currentViewController = SceneCoordinator.topViewController(for: presenter)
                subject.onCompleted()
                
            }
        }else {
            fatalError("Not a moal, no navigation controller: can't navigate back from \(currentViewController)")
        }
        
        return subject.asObservable()
            .take(1)
            .ignoreElements()
    }

    @discardableResult
    func popToRoot(animated: Bool) -> Completable {
        let subject = PublishSubject<Void>()
        if let nav = currentViewController.navigationController {
            _ = nav.rx.didShow
                .map{ _ in }
                .bind(to: subject)
            
            guard let _ = nav.popToRootViewController(animated: animated) else {
                fatalError("can't navigate back from \(currentViewController)")
            }
        }else {
            fatalError("Not a moal, no navigation controller: can't navigate back from \(currentViewController)")
        }
        
        return subject.asObservable()
            .take(1)
            .ignoreElements()
    }
    
    func resetCurrentViewControllerWhenNavDidShow( _ vc: UIViewController) {
        currentViewController = SceneCoordinator.topViewController(for: vc)
    }
}

