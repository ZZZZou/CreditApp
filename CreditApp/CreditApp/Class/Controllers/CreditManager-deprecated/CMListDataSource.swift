//
//  CMListDataSource.swift
//  CreditApp
//
//  Created by w22543 on 2018/9/5.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import RxSwift
import UIKit

class CMListDataSource: NSObject, UITableViewDataSource, HhDownload{
   
    var modelArray: [CMTotalCardModel] = [] {
        didSet{
            self.tableView.reloadData()
        }
    }
    
    var tableView : UITableView!
    func registerCells(with tableView : UITableView) {
        self.tableView = tableView
        tableView.register(UINib.init(nibName: "CMCreditListCell", bundle: nil), forCellReuseIdentifier: CMCreditListCell.reuseIdentifier)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CMCreditListCell.reuseIdentifier, for: indexPath) as! CMCreditListCell
        cell.selectionStyle = .none
        let model = self.modelArray[indexPath.row]
        cell.bankName.text = model.bankName
//        cell.bankID.text = model.bank
        cell.repayDate.text = String(format: "账单日 每月\(model.refundDay)号")
        cell.bliiDate.text = String(format: "还款日 每月\(model.paymentDueDay)号")
        cell.cardUserName.text = model.user_name_hello
        cell.cost.text = model.totalCaptiveFree.toStringWithPoint()
        return cell
    }

    
}
