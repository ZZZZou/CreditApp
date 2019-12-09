//
//  CaptiveViewController.swift
//  CreditApp
//
//  Created by 胡骏 on 2018/9/4.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import UIKit
import RxSwift
import XCGLogger

struct CapCellStruct {
    let cellLine2Left:CGFloat = 24
}

class CaptiveViewController: UIViewController, HhDownload {
    
    var disposeBag = DisposeBag()
    
    var logg = XCGLogger.default

    fileprivate var capHeadView: UIView = UIView()
    
    fileprivate var reTestButton: UIButton = UIButton()
    fileprivate var toDetailButton = UIButton()
    
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
        
        tableView.register(UINib(nibName: "CapDetailTableViewCell", bundle: nil),
                           forCellReuseIdentifier: CapDetailTableViewCell.Identifier)
        
        let capAmountHeadViewNib: UINib = UINib(nibName: "CapAmountHeadView", bundle: nil)
        tableView.register(capAmountHeadViewNib,
                           forHeaderFooterViewReuseIdentifier: CapAmountHeadView.Identifier)
        return tableView
    }()
    
    fileprivate var bank = ""
    fileprivate var bankName = ""
    fileprivate var totalFree: String = ""{
        didSet {
            logg.debug(totalFree)
            self.totalFreeLabel.text = totalFree
        }
    }
    
    fileprivate var capModelArray: [CapTotalModel] = []
    // MARK: - life cycle
   
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingViewStart()
    }
    private var isFirstLoad = true
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstLoad {
            downCaptiveModelWith(bank: bank, user_name_hello: cardModel.user_name_hello)
            isFirstLoad = false
        }
    }
    
    // MARK: - public methods
    func viewWithCardModel(cardModel: CMTotalCardModel) {
        self.bank = cardModel.bank
        self.bankName = cardModel.bankName
        self.cardModel = cardModel
    }
    
    // MARK: - notification、closume、event response
    @objc func bottonButtonClick(_ sender: UIButton) {
        if sender.tag == 0 {
            // retext
            
        } else {
            // detail
            let detailVC = MonthDetailViewController()
            detailVC.viewWithBank(bank: bank, bankName: bankName, card: cardModel)
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    // MARK: - private methods
    fileprivate func downCaptiveModelWith(bank: String, user_name_hello: String) {
        let user = UserSingle.sharedInstance.userModel

        let parameters = ["userUUID": user.user_uuid, "bank": bank, "user_name_hello": user_name_hello]
        downloadToArrayWithParameters(parameters, url: kGetAmountstatisticsURL,
                                     modeltype: CapTotalModel.self)
            .catchError { [unowned self] (error) -> Observable<[CapTotalModel]> in
                self.logg.debug(error)
                self.tableView.reloadData()
                self.loadingViewStop()
                return Observable.never()
        
            }.map { [unowned self] (modelArray) in
                self.loadingViewStop()
                self.makeUI()
                self.capModelArray = modelArray
                self.tableView.reloadData()
                var free = 0.0
                for model in modelArray {
                    free += model.totlaFree
                }
                let freeString = free.toStringWithPoint()
                self.totalFree = freeString + "元"
        }.subscribe().disposed(by: disposeBag)
    }
    let totalFreeLabel = UILabel()

    fileprivate func makeUI() {
        ddSetTitle("信用卡体检报告")
        
        let bankNameLabel = UILabel()
        bankNameLabel.font = UIFont.normal
        let middleLabel = UILabel()
        middleLabel.font = UIFont.big
        bankNameLabel.textColor = .black
        middleLabel.textColor = .black
        totalFreeLabel.textColor = .black
        middleLabel.textAlignment = .center
        totalFreeLabel.textAlignment = .center
        
        capHeadView.addSubview(bankNameLabel)
        capHeadView.addSubview(middleLabel)
        capHeadView.addSubview(totalFreeLabel)
        
        bankNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.equalTo(10)
            make.right.equalTo(-20)
            make.height.equalTo(50)
        }
        middleLabel.snp.makeConstraints { (make) in
            make.center.equalTo(capHeadView.snp.center)
            make.size.equalTo(CGSize(width: 200, height: 60))
        }
        
        totalFreeLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(-5)
            make.left.right.equalTo(0)
            make.height.equalTo(50)
        }
        bankNameLabel.text = bankName
        middleLabel.text = "累计被信用卡薅了"
        capHeadView.frame = CGRect(x: 0, y: 0, width: kWidth, height: 200)
        tableView.tableHeaderView = capHeadView
        
        view.backgroundColor = UIColor.white
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide).offset(44)
                make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-50)
            } else {
                // Fallback on earlier versions
                make.top.equalTo(view.layoutMarginsGuide).offset(44)
                make.bottom.equalTo(view.layoutMarginsGuide)
            }
            make.left.right.equalTo(0)
        }
        
        [reTestButton, toDetailButton].forEach { (bt) in
            bt.setTitleColor(.white, for: .normal)
            bt.titleLabel?.font = UIFont.normal
            bt.layer.cornerRadius = 2
            bt.layer.masksToBounds = true
            bt.backgroundColor = UIColor(red: 36/255.0, green: 156/255.0, blue: 211/255.0, alpha: 1.0)
            bt.addTarget(self, action: #selector(self.bottonButtonClick(_:)), for: .touchUpInside)
            view.addSubview(bt)
        }
        reTestButton.tag = 0
        toDetailButton.tag = 1
        reTestButton.setTitle("重新体检", for: .normal)
        toDetailButton.setTitle("查看账单详情", for: .normal)
        reTestButton.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.bottom.equalTo(view.layoutMarginsGuide)
            }
            make.width.equalTo(kWidth / 2 - 20)
            make.height.equalTo(50)
        }
        toDetailButton.snp.makeConstraints { (make) in
            make.right.equalTo(0)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.bottom.equalTo(view.layoutMarginsGuide)
            }
            make.width.equalTo(kWidth / 2 - 20)
            make.height.equalTo(50)
        }
    }
}


extension CaptiveViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return capModelArray[section].isOpened ? capModelArray[section].consumeDetails.count : 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return capModelArray.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CapDetailTableViewCell.Identifier, for: indexPath) as! CapDetailTableViewCell
        cell.viewWithDetailModel(capModelArray[indexPath.section].consumeDetails[indexPath.row])
      
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView: CapAmountHeadView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CapAmountHeadView.Identifier) as! CapAmountHeadView
        headView.viewWithCapTotalModel(capModelArray[section], row: section)
        return headView
    }
}
