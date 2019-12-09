//
//  AboutViewController.swift
//  CreditApp
//
//  Created by wang on 2019/3/10.
//  Copyright © 2019 CreditManager. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit

class MeAboutViewController: UIViewController, BindableType {
    
    
    let bag = DisposeBag()
    @IBOutlet weak var iphoneBtn: UIButton!
    
    var viewModel: MeAboutViewModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        iphoneBtn.rx.tap
            .bind{[unowned self] in
                self.viewModel.call(self.iphoneBtn.currentTitle!)
            }
            .disposed(by: self.bag)
    }
    
    func bindViewModel() {
        
    }


}
