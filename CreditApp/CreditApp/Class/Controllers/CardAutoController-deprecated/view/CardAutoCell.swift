//
//  CardAutoCell.swift
//  CreditApp
//
//  Created by 胡骏 on 2018/10/24.
//  Copyright © 2018 hujuun. All rights reserved.
//

import UIKit

class CardAutoCell: UICollectionViewCell {

    static let Identifier = "CardAutoCell"

    @IBOutlet weak var bankName: UILabel!
    
    @IBOutlet weak var repayDescribe: UILabel!
    
    @IBOutlet weak var repayDay: UILabel!
    
    @IBOutlet weak var refundDay: UILabel!
    
    @IBOutlet weak var paymentDay: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .red
    }

    func cellWithModel(model: CMTotalCardModel) {
        bankName.text = model.bankName
        repayDescribe.text = "今日刷卡（*8869）享免息"
        repayDay.text = model.repaymentCycle
        refundDay.text = "账单日 每月" + model.refundDay
        paymentDay.text = "还款日 每月" + model.paymentDueDay
    }
}
