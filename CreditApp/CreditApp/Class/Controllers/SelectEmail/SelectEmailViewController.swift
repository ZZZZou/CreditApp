//
//  SelectEmailViewController.swift
//  CreditApp
//
//  Created by w22543 on 2018/11/21.
//  Copyright © 2018年 CreditManager. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class SelectEmailViewController: UIViewController, BindableType {

    let bag = DisposeBag()
    var viewModel: SelectEmailViewModel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var agreementBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func bindViewModel() {
        
        Observable.just(viewModel.items).bind(to: tableView.rx.items){tableView, index, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "emailCell") as! SelectEmailTableViewCell
            
            cell.emailIcon.image = UIImage(named: item)
            return cell
            }.disposed(by: bag)
        
        tableView.rx.itemSelected
            .do(onNext: { [unowned self] indexPath in
                self.tableView.deselectRow(at: indexPath, animated: false)
                
            })
            .map { [unowned self] indexPath in
                self.viewModel.items[indexPath.row]
            }
            .subscribe(viewModel.selectEmail.inputs)
//            .subscribe(onNext: { [unowned self] str in
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let vc = storyboard.instantiateViewController(withIdentifier: "emailLoading") as! EmailLoadingViewController
//
//                self.addChild(vc)
//                self.view.addSubview(vc.view)
//            })
            .disposed(by: bag)
        agreementBtn.rx.action = viewModel.loadWebAction
    }

    deinit {
        
        print("SelectEmailViewController")
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)

    }
}

