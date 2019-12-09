//
//  BindableType.swift
//  CreditApp
//
//  Created by w22543 on 2018/11/19.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import Foundation
import RxSwift

protocol BindableType {
    associatedtype ViewModelType
    
    var viewModel: ViewModelType! { get set }
    
    func bindViewModel()
}

extension BindableType where Self: UIViewController {
    mutating func bindViewModel(to model: Self.ViewModelType) {
        viewModel = model
        loadViewIfNeeded()
        bindViewModel()
    }
}
