//
//  MonthTableHeadView.swift
//  CreditApp
//
//  Created by 胡骏 on 2018/9/14.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import UIKit

class MonthTableHeadView: UIView {

    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var label6: UILabel!
    @IBOutlet weak var label7: UILabel!
    @IBOutlet weak var label8: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func viewWithData(carModel: CMTotalCardModel) {
        label1.text = carModel.bankName
        label2.text = carModel.user_name_hello
        label3.text = carModel.refundDay
        label6.text = carModel.paymentDueDay
        label7.text = carModel.repaymentCycle
        label8.text = carModel.credit_limit
    }
    
    class func monthTableHeadView() -> MonthTableHeadView {
        return  (Bundle.main.loadNibNamed("MonthTableHeadView", owner: nil, options: nil)!.first as? MonthTableHeadView)!
    }
}
