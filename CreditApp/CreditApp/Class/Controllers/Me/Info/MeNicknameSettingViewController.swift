//
//  MeNicknameSettingViewController.swift
//  CreditApp
//
//  Created by w22543 on 2019/1/11.
//  Copyright © 2019年 CreditManager. All rights reserved.
//

import MBProgressHUD
import RxSwift
import RxCocoa
import UIKit

class MeNicknameSettingViewController: UIViewController, BindableType {

    
    @IBOutlet weak var nickname: UITextField!
    
    
    var viewModel: MeNicknameSettingViewModel!
    let bag = DisposeBag()
    
    var oldNickname: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let item = UIBarButtonItem(title: "保存", style: .plain, target: nil, action: nil)
        item.tintColor = UIColor.mainOrange
        self.navigationItem.rightBarButtonItem = item
        
        self.nickname.text = viewModel.user.nickname
        self.oldNickname = self.nickname.text
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.nickname.becomeFirstResponder()
    }
    
    func bindViewModel() {
        nickname.rx.controlProperty(
            editingEvents: .editingDidEnd,
            getter: {$0},
            setter: {_, _ in }
            )
            .bind {$0.resignFirstResponder()}
            .disposed(by: bag)
    
        nickname.rx.text
            .bind{[unowned self] text in
                
                let rightItem = self.navigationItem.rightBarButtonItem
                if text?.count == 0 || text == self.oldNickname {
//                    rightItem?.tintColor = UIColor.textGray
                    rightItem?.isEnabled = false
                }else{
//                    rightItem?.tintColor = UIColor.mainOrange
                    rightItem?.isEnabled = true
                }
            }
            .disposed(by: bag)
        
        self.navigationItem.rightBarButtonItem?.rx.tap
            .bind{ [unowned self] in
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                MBProgressHUD.showHUD(addedTo: self.view)
                let nickname = self.nickname.text!
                self.viewModel.saveAction(nickname)
                    .bind{ result in
                        if result {
                            MBProgressHUD.hide(for: self.view, animated: true)
                        }else {
                            MBProgressHUD.showError("昵称修改失败", addedTo: self.view)
                        }
                    }
                    .disposed(by: self.bag)
            }
            .disposed(by: bag)
        
    }
    
    
    
    deinit{
        print("me nickname setting deini")
    }

}
