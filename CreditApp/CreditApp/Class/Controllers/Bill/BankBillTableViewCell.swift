//
//  BankBillTableViewCell.swift
//  CreditApp
//
//  Created by w22543 on 2018/11/27.
//  Copyright © 2018年 CreditManager. All rights reserved.
//

import UIKit

class BankBillTableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var type: UILabel!

    
    func configCell(with item: BankBillDetailModel, indexPath: IndexPath) {
        title.text = item.description
        amount.text = "\(item.amount_RMB)元"
        type.text = item.consume_type
        
        let dateString = item.post_date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let optionalDate = dateFormatter.date(from: dateString)
        if var date = optionalDate {
            var interval = date.timeIntervalSinceReferenceDate
            if indexPath.section == 0 {
                interval -= 86400 * 35
                date = Date(timeIntervalSinceReferenceDate: interval)
            }else if indexPath.section == 1 || indexPath.section == 2 {
                interval -= 86400 * 69
                date = Date(timeIntervalSinceReferenceDate: interval)
            }else if indexPath.section == 3 {
                interval -= 86400 * 80
                date = Date(timeIntervalSinceReferenceDate: interval)
            }
            
            self.date.text = dateFormatter.string(from: date)
        }
        
        
        
        self.date.text = dateString
    }
}


class BankBillTipTableViewCell: UITableViewCell {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var content: UILabel!
}
