//
//  SetupViewController.swift
//  CreditApp
//
//  Created by w22543 on 2018/11/26.
//  Copyright © 2018年 CreditManager. All rights reserved.
//

import RealmSwift
import RxRealm
import RxSwift
import UIKit

class SetupViewController: UITableViewController, BindableType {

    @IBOutlet weak var exitBtn: UIButton!
    @IBOutlet weak var switchAccount: UIButton!
    
    var viewModel: SetupViewModel!
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func bindViewModel() {
        
        UserModel.currentUser.loginStatus
            .bind{ [unowned self] bl in
                self.exitBtn.isHidden = !bl
                self.switchAccount.isHidden = !bl
        }.disposed(by: bag)
        
        exitBtn.rx.action = viewModel.exitAction()
        
        switchAccount.rx.action = viewModel.switchAction()
        
        tableView.rx.itemSelected
            .bind{[unowned self] indexPath in
                self.tableView.deselectRow(at: indexPath, animated: true)
                if indexPath.row == 0 {
                    self.viewModel.pushToFeedback()
                }else if indexPath.row == 1 {
                    self.viewModel.pushToAbout()
                }
            }
            .disposed(by: bag)
        
    }
    
    deinit {
        print("setup view controller deinit")
    }

    
}

