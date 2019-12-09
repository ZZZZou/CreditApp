//
//  MonthDetailViewController.swift
//  CreditApp
//
//  Created by 胡骏 on 2018/9/7.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import UIKit
import RxSwift
import XCGLogger

class MonthDetailViewController: UIViewController, HhDownload {
    var disposeBag = DisposeBag()
    
    var logg = XCGLogger.default
    
    fileprivate var monthHeadView: UIView = UIView()
    fileprivate var cardModel: CMTotalCardModel!

    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.bounces = true
        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 50
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        
        tableView.register(UINib(nibName: "LoadingTableViewCell", bundle: nil),
                            forCellReuseIdentifier: LoadingTableViewCell.Identifier)
        
        tableView.register(UINib(nibName: "MonthNoDetailTableViewCell", bundle: nil),
                           forCellReuseIdentifier: MonthNoDetailTableViewCell.Identifier)

        tableView.register(UINib(nibName: "MonDetailTableViewCell", bundle: nil),
                           forCellReuseIdentifier: MonDetailTableViewCell.Identifier)
        
        let capAmountHeadViewNib: UINib = UINib(nibName: "MonDetailHeadView", bundle: nil)
        tableView.register(capAmountHeadViewNib,
                           forHeaderFooterViewReuseIdentifier: MonDetailHeadView.Identifier)
        return tableView
    }()
    
    fileprivate var bank = "PCCC"
    fileprivate var bankName = ""
    fileprivate var monthArray: [MonthConsumeBillModel] = [MonthConsumeBillModel]()
    fileprivate var consumeDetailDict: [String: [ConsumeDetailModel]] = [:]
    // MARK: - life cycle
   
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingViewStart()
      
    }
    private var isFirstLoad = true

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstLoad {
            makeUI()
            downMonthBill(bank: bank)
            isFirstLoad = false
        }
      
    }
    // MARK: - public methods
    func viewWithBank(bank: String, bankName: String, card: CMTotalCardModel) {
        self.bank = bank
        self.bankName = bankName
        self.cardModel = card
    }
    // MARK: - notification、closume、event response
    // MARK: - private methods
    fileprivate func makeUI() {
        ddSetTitle("信用卡账单详情")

        let detailView = MonthTableHeadView.monthTableHeadView()
        detailView.viewWithData(carModel: cardModel)
        monthHeadView.addSubview(detailView)
        detailView.snp.makeConstraints { (make) in
            make.top.equalTo(44)
            make.left.equalTo(30)
            make.bottom.right.equalTo(0)
        }
        monthHeadView.frame = CGRect(x: 0, y: 0, width: kWidth, height: 200)
        tableView.tableHeaderView = monthHeadView
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide).offset(44)
                make.bottom.equalTo(view.safeAreaLayoutGuide)
            } else {
                // Fallback on earlier versions
                make.top.equalTo(view.layoutMarginsGuide).offset(44)
                make.bottom.equalTo(view.layoutMarginsGuide)
            }
            make.left.right.equalTo(0)
        }
    }
    
    fileprivate func downMonthBill(bank: String) {
        let user = UserSingle.sharedInstance.userModel

        let parameters = ["userUUID": user.user_uuid, "bank": bank,
                          "user_name_hello": cardModel.user_name_hello,
                          "from_mail": cardModel.from_mail]
        downloadToArrayWithParameters(parameters,
                                      url: kGetAllMonthBillURL,
                                      modeltype: MonthConsumeBillModel.self)
            .catchError { [unowned self] (error) -> Observable<[MonthConsumeBillModel]> in
                self.loadingViewStop()
                self.logg.debug(error)
                return Observable.never()
                
            }.map { [unowned self] (modelArray) in
                self.loadingViewStop()
                self.makeUI()
                self.monthArray = modelArray
                self.tableView.reloadData()
            }.subscribe().disposed(by: disposeBag)
    }
    
    fileprivate func downMonthConsumes(bank: String, refund_year: String, refund_month: String, card_num_last_four: String,section: Int) {
        let dateString = refund_year + refund_month
        tableView.reloadData()

        let d = consumeDetailDict[dateString]

        if d != nil {
            return
        }
        
        let user = UserSingle.sharedInstance.userModel
        let parameters = ["userUUID": user.user_uuid, "bank": bank,
                          "refund_year": refund_year,
                          "card_num_last_four": card_num_last_four,
                          "refund_month": refund_month]
        downloadToArrayWithParameters(parameters,
                                      url: kGetMonthConsumeURL,
                                      modeltype: ConsumeDetailModel.self)
            .catchError { [unowned self] (error) -> Observable<[ConsumeDetailModel]> in
                let e = error as! TestInfoError
                self.monthArray[section].is_consumption_detail = -1
                self.tableView.reloadData()
                self.logg.debug(e.info)
                return Observable.never()
                                        
            }.map { [unowned self] (modelArray) in
                self.consumeDetailDict[dateString] = modelArray
                self.tableView.reloadData()
            }.subscribe().disposed(by: disposeBag)
    }
}


extension MonthDetailViewController: UITableViewDelegate, UITableViewDataSource, SectionHeaderViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let m = monthArray[section]
        var count = 0
        if m.isOpened {
            let dateString = m.refund_year + m.refund_month
            let d = consumeDetailDict[dateString]
            if let consumeArray = d {
                count = consumeArray.count
            } else {
                count = 1
            }
        }
        return count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return monthArray.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let monthbillModel = monthArray[indexPath.section]
        let dateString = monthbillModel.refund_year + monthbillModel.refund_month
        let d = consumeDetailDict[dateString]
        if let consumeArray = d {
             let cell = tableView.dequeueReusableCell(withIdentifier: MonDetailTableViewCell.Identifier, for: indexPath) as! MonDetailTableViewCell
            let model = consumeArray[indexPath.row]
            cell.viewWithConsumeDetailModel(model: model)
            return cell

        } else {
            if monthbillModel.is_consumption_detail == -1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: MonthNoDetailTableViewCell.Identifier, for: indexPath) as! MonthNoDetailTableViewCell
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: LoadingTableViewCell.Identifier, for: indexPath) as! LoadingTableViewCell
//                cell.viewStartRotation()
                return cell
            }
           
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView: MonDetailHeadView = tableView.dequeueReusableHeaderFooterView(withIdentifier: MonDetailHeadView.Identifier) as! MonDetailHeadView
        let monthbillModel = monthArray[section]
        headView.delegate = self
        headView.viewWithDateModel(monthbillModel: monthbillModel, section: section)
        return headView
    }
    
    func sectionHeaderView(_ sectionHeaderView: UITableViewHeaderFooterView, section: Int, isOpened: Bool) {
        if isOpened == false {
            monthArray[section].isOpened = false
            tableView.scrollToNearestSelectedRow(at: .none, animated: false)
//            tableView.scrollToRow(at: IndexPath.init(row: 0, section: section), at: .middle, animated: false)
            tableView.reloadData()
            return
        }
        for index in 0 ..< monthArray.count {
            if index == section {
                 monthArray[index].isOpened = true
            } else {
                 monthArray[index].isOpened = false
            }
        }
        if let sectionheadView = sectionHeaderView as? MonDetailHeadView, let billModel = sectionheadView.monthConsumeBillModel {
            downMonthConsumes(bank: bank, refund_year: billModel.refund_year, refund_month: billModel.refund_month, card_num_last_four: billModel.card_num_last_four, section: section)
        }
    }
}
