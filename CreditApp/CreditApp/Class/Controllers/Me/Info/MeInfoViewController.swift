//
//  MeInfoViewController.swift
//  CreditApp
//
//  Created by w22543 on 2019/1/8.
//  Copyright © 2019年 CreditManager. All rights reserved.
//

import RxSwift
import Action
import UIKit

class MeInfoViewController: UIViewController, BindableType {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var nickname: UILabel!
    
    @IBOutlet weak var iconBtn: UIButton!
    @IBOutlet weak var nicknameBtn: UIButton!
    
    let bag = DisposeBag()
    var viewModel: MeInfoViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hidesBottomBarWhenPushed = true

        icon.layer.cornerRadius = 5
        icon.layer.masksToBounds = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func bindViewModel() {
        nicknameBtn.rx.action = viewModel.nicknameAction()
        iconBtn.rx.action = viewModel.iconAction()
        
        viewModel.user.userinfoChanged
            .bind{[unowned self] user in
                self.nickname.text = user.nickname
                self.icon.image = user.icon
            }
            .disposed(by: bag)
    }

}
