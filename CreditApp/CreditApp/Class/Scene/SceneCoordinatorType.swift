//
//  SceneCoordinatorType.swift
//  CreditApp
//
//  Created by w22543 on 2018/11/19.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import RxSwift
import Foundation

protocol SceneCoordinatorType {
    
    @discardableResult
    func transition(to scene: Scene, type: SceneTransitionType) -> Completable
    
    @discardableResult
    func pop(animated: Bool) -> Completable
    
}

extension SceneCoordinatorType {
    @discardableResult
    func pop() -> Completable {
        return pop(animated: true)
    }
}
