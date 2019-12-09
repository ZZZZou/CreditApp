//
//  BankBillViewController.swift
//  CreditApp
//
//  Created by w22543 on 2018/11/27.
//  Copyright © 2018年 CreditManager. All rights reserved.
//

import Charts
import RxDataSources
import RxSwift
import UIKit

class BankBillViewController: UIViewController, BindableType {

    var viewModel: BankBillViewModel!
    let bag = DisposeBag()
    
    @IBOutlet weak var amount: UILabel!
    
    @IBOutlet weak var interest: UILabel!
    @IBOutlet weak var annualFee: UILabel!
    @IBOutlet weak var commission: UILabel!
    @IBOutlet weak var lateFee: UILabel!
    
    @IBOutlet weak var bottomLabel1: UILabel!
    @IBOutlet weak var bottomLabel2: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var chartView: PieChartView!
    
    @IBOutlet weak var bottomBtn: UIButton!
    
    @IBOutlet weak var footerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        chartView.legend.enabled = false
        chartView.holeColor = nil
        bottomLabel1.text = ""
        bottomLabel2.text = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("viewDidLayoutSubViews,\(tableView.contentSize)")
        
        if tableView.contentSize.height < tableView.height {
            footerView.height += tableView.height - tableView.contentSize.height
        }else {
            footerView.height = 112
        }
        tableView.tableFooterView = footerView
    }
    
    func bindViewModel() {
        let lastFour = viewModel.card.card_num_last_four.cardnumlastfour2Normal()
        bottomLabel1.text = viewModel.card.bankName + "（\(lastFour)）上次体检时间" + viewModel.card.last_update_date
        bottomLabel2.text = "账单有效期近2年"
        viewModel.interest
            .map{"利息：\($0)元"}
            .bind(to: interest.rx.text)
            .disposed(by: bag)
        
        viewModel.annualFee
            .map{"年费：\($0)元"}
            .bind(to: annualFee.rx.text)
            .disposed(by: bag)
        
        viewModel.commission
            .map{"手续费：\($0)元"}
            .bind(to: commission.rx.text)
            .disposed(by: bag)
        
        viewModel.lateFee
            .map{"滞纳金：\($0)元"}
            .bind(to: lateFee.rx.text)
            .disposed(by: bag)
        
        viewModel.summary
            .bind(onNext: self.setupPieChartView)
            .disposed(by: bag)
        
        viewModel.amount
            .bind(to: amount.rx.text)
            .disposed(by: bag)
        
        viewModel.bill
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: bag)
        
        bottomBtn.rx.action = viewModel.loadShareWebAction

        UserModel.currentUser.loginStatus
            .bind{[unowned self] logined in
                self.bottomBtn.isHidden = !logined
            }
            .disposed(by: bag)
    }
    
    lazy var dataSource: CellSizeTableViewSectionedAnimatedDataSourcer<BankBillSectionModel> =  {
        return CellSizeTableViewSectionedAnimatedDataSourcer(
            animationConfiguration: AnimationConfiguration(insertAnimation: .none, reloadAnimation: .none, deleteAnimation: .none),
            decideViewTransition: {_, _, _ in .reload},
            
            configureCell: {ds, tableView, indexPath, item in
                switch item {
                case .item(_, let model):
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! BankBillTableViewCell
                    cell.title.text = model.description
                    cell.date.text = model.trans_date
                    cell.amount.text = "\(model.amount_RMB)元"
                    cell.type.text = ""
                    return cell
                    
                case .tip:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "tipCell") as! BankBillTipTableViewCell
                    cell.content.text = self.viewModel.tipTitle[indexPath.section];
                    return cell
                }
        })
    }()
    
    func setupPieChartView(values: [Double]) {
        let isAllZero = !values.contains{$0 != 0}
        var entries = values.map{ value in
            PieChartDataEntry(value: value, label: nil)
        }
        var colors = [UIColor.mainOrange, UIColor(hex: "0x5BA7FF"), UIColor(hex: "0x7A84D1"), UIColor(hex: "0xF97988")]
        if isAllZero {
            entries = [PieChartDataEntry(value: 1, label: nil)]
            colors = [UIColor.white]
        }
        
        let set = PieChartDataSet(values: entries, label: "")
        set.drawIconsEnabled = false
        set.sliceSpace = 0
        set.colors = colors
        set.drawValuesEnabled = false
        set.selectionShift = 0
        set.formLineWidth = 4
        
        let data = PieChartData(dataSet: set)
        
        
        chartView.noDataText = ""
        chartView.holeRadiusPercent = 0.9
        chartView.data = data
    }
    
    deinit {
        print("bank bill view controller didinit")
    }
    
}

extension BankBillViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionView = Bundle.main.loadNibNamed("BankBillSectionView", owner: nil, options: nil)?.first as? BankBillSectionView else {
            return nil
        }
        
        let sectionModel = dataSource[section]
        sectionView.title.text = sectionModel.consumeName
        sectionView.amount.text = "\(sectionModel.totalFree)元"
        
        sectionView.foldBtn.rx.action = viewModel.foldAction(section)
        
        return sectionView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 77
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        let sectionModel = self.viewModel.bill.value[indexPath.section]
        if indexPath.row == sectionModel.consumeDetails.count {
            self.viewModel.loadWebAction.execute(indexPath.section)
        }
    }
}
