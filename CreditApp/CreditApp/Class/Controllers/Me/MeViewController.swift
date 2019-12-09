//
//  MeViewController.swift
//  CreditApp
//
//  Created by w22543 on 2018/11/21.
//  Copyright © 2018年 CreditManager. All rights reserved.
//

import MBProgressHUD
import RxSwift
import UIKit

class MeViewController: UITableViewController, BindableType {
    
    @IBOutlet weak var headBackgroundView: UIView!
    @IBOutlet weak var userIconBtn: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var userInfoBtn: UIButton!
    
    @IBOutlet weak var addition: UILabel!
    
    
    
    var viewModel: MeViewModel!
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
        if #available(iOS 11.0, *) {
            if UIApplication.shared.statusBarFrame.height == 44 {
                self.tableView.contentInset = UIEdgeInsets(top: -44, left: 0, bottom: 0, right: 0)
            }
        }
        
        let v = UIView()
        tableView.tableFooterView = v
        userIconBtn.layer.cornerRadius = 5
        userIconBtn.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        headBackgroundView.backgroundColor = UIColor(hex: "#6b6f7b")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        headBackgroundView.backgroundColor = UIColor(hex: "#ffffff")
    }
    
    func bindViewModel() {
        
        let user = UserModel.currentUser
        user.userinfoChanged
            .bind{ [unowned self] user in
            self.accountLabel.isHidden = !user.isLogin
            self.accountLabel.text = "账号：\(user.telephone)"
            self.userNameLabel.text = user.isLogin ? user.nickname : "登录/注册"
            self.userIconBtn.setImage(user.icon, for: .normal)
        }.disposed(by: bag)
        
        userInfoBtn.rx.action = viewModel.infoAction()
        userIconBtn.rx.action = viewModel.infoAction()
        
        tableView.rx.itemSelected
            .do(onNext:{ [unowned self] indexPath in
                self.tableView.deselectRow(at: indexPath, animated: true)
            })
            .bind{ indexPath in
                if indexPath.row == 2 {
                    let scene = Scene.me(.setup(SetupViewModel(coordinator: self.viewModel.coordinator)))
                    self.viewModel.coordinator.transition(to: scene, type: .push)
                }else if indexPath.row == 0 {
                    self.viewModel.loadShareWebAction()
                }
                else {
                    MBProgressHUD.showMessage("功能暂未开发")
                }
        }.disposed(by: bag)
        
        user.loginStatus
            .bind{ [unowned self] logined in
                self.addition.text = logined ? "" : "请先登录"
            }
            .disposed(by: bag)
    }

}


