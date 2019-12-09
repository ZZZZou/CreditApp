//
//  BillDetailSectionView.swift
//  CreditApp
//
//  Created by wang on 2018/11/22.
//  Copyright © 2018 CreditManager. All rights reserved.
//

import UIKit

class ConsumeBillSectionView: UITableViewHeaderFooterView {

    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var money: UILabel!
    @IBOutlet weak var foldIcon: UIImageView!
    @IBOutlet weak var foldBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = UIColor.white
    }

    func config(with model: ConsumeBillModel) {
        date.text = model.refund_year + "年" + model.refund_month + "月"
        money.text =  model.banance_RMB + "元"
        foldIcon.isHidden = model.is_consumption_detail == 0
    }
}
