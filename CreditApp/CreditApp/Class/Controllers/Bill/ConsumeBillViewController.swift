//
//  ConsumeBillViewController.swift
//  CreditApp
//
//  Created by w22543 on 2018/11/27.
//  Copyright © 2018年 CreditManager. All rights reserved.
//

import RxDataSources
import RxSwift
import UIKit

class ConsumeBillViewController: UIViewController, BindableType {

//    @IBOutlet weak var bankIcon: UIImageView!
    @IBOutlet weak var bankName: UILabel!
    @IBOutlet weak var cardNum: UILabel!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var bankName2: UILabel!
    @IBOutlet weak var cardType: UILabel!
    @IBOutlet weak var dateForAccount: UILabel!
    @IBOutlet weak var dateForRepay: UILabel!
    @IBOutlet weak var latestDateForRepay: UILabel!
    @IBOutlet weak var amountsForRepay: UILabel!
    @IBOutlet weak var limit: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var bottomBtn: UIButton!
    
    var viewModel: ConsumeBillViewModel!
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "LoadingTableViewCell", bundle: nil), forCellReuseIdentifier: "loading")
        self.configHeadView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("viewDidLayoutSubViews,\(tableView.contentSize)")
        if tableView.contentSize.height < tableView.height {
            footerView.height += tableView.height - tableView.contentSize.height
        }else {
            footerView.height = 74
        }
        tableView.tableFooterView = footerView
    }

    func bindViewModel() {
        
        viewModel.allMonthData
            .do(onNext: { [unowned self] (arr) in
                if let s = arr.first?.payment_due_date_month {
                    self.latestDateForRepay.text = "\(s)月" + "\(self.viewModel.card.paymentDueDay)日"
                }
                if let m = arr.first?.banance_RMB {
                    self.amountsForRepay.text = "￥\(m)"
                }

            })
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: bag)
        
        bottomBtn.rx.action = viewModel.loadShareWebAction
        
        UserModel.currentUser.loginStatus
            .bind{[unowned self] logined in
                self.bottomBtn.isHidden = !logined
            }
            .disposed(by: bag)
    }
    
    
    lazy var dataSource = {
       return CellSizeTableViewSectionedAnimatedDataSourcer<ConsumeBillModel>(
            animationConfiguration: AnimationConfiguration(insertAnimation: .none, reloadAnimation: .none, deleteAnimation: .none),
            decideViewTransition: {_, _, _ in .reload},
            configureCell: {ds, tableView, indexPath, item in
                switch item {
                case .loading:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "loading") as! LoadingTableViewCell
                    cell.startAnimation()
                    return cell
                    
                case .noData:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "noData")
                    return cell!
                    
                case .item(_, let model):
                    let cell = tableView.dequeueReusableCell(withIdentifier: "item") as! ConsumeBillTableViewCell
                    cell.config(with: model)
                    return cell
                }
                
        })
    }()
    
    func configHeadView() {
//        self.bankIcon.image = UIImage(named: "placehold")
        self.bankName.text = viewModel.card.bankName
        self.cardNum.text = viewModel.card.cardNum
        
        self.name.text = viewModel.card.user_name_hello
        self.bankName2.text = viewModel.card.bankName
        self.cardType.text = "--"
        self.dateForAccount.text = "\(viewModel.card.refundDay)日"
        self.dateForRepay.text = "\(viewModel.card.paymentDueDay)日"
        if viewModel.card.credit_limit.count == 0 {
            self.limit.text = "--"
        } else {
            self.limit.text = "￥\(viewModel.card.credit_limit)"
        }
        
        let imgUrl = URL(string: self.viewModel.card.bankIconurl)
//        self.bankIcon.kf.setImage(with: imgUrl)
    }
    
    deinit {
        print("consume bill view controller didinit")
    }

}

extension ConsumeBillViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let sectionView = Bundle.main.loadNibNamed("ConsumeBillSectionView", owner: nil, options: nil)?.first as? ConsumeBillSectionView else {
            return nil
        }
        
        let sectionModel = dataSource[section]
        sectionView.config(with: sectionModel)
        sectionView.foldBtn.rx.tap
            .withLatestFrom(Observable.just(section)){$1}
            .bind(to: viewModel.sectionAction.inputs)
            .disposed(by: bag)

        return sectionView
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

        let item = dataSource[indexPath]

        switch item {
        case .loading:
            return 44
        case .noData:
            return 44
        case .item :
            return 88
        }
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let sectionHeaderHeight = CGFloat(57.0)
//        if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0) {
//            scrollView.contentInset = UIEdgeInsets(top: -scrollView.contentOffset.y, left: 0, bottom: 0, right: 0);
//        } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
//            scrollView.contentInset = UIEdgeInsets(top: -sectionHeaderHeight, left: 0, bottom: 0, right: 0);
//        }
//    }
}
