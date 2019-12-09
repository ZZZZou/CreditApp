//
//  MonDetailHeadView.swift
//  CreditApp
//
//  Created by 胡骏 on 2018/9/7.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import UIKit

// 该协议将被分节表头的委托实现； 当分节表被打开关闭时，分节表头将通知发送给委托
protocol SectionHeaderViewDelegate: class, NSObjectProtocol {
    
    func sectionHeaderView(_ sectionHeaderView: UITableViewHeaderFooterView, section: Int, isOpened: Bool)
}


class MonDetailHeadView: UITableViewHeaderFooterView {

    static let Identifier = "MonDetailHeadView"

    weak var delegate: SectionHeaderViewDelegate?

    @IBOutlet weak var leftImageView: UIImageView!
    
    @IBOutlet weak var dataLabel: UILabel!
    
    @IBOutlet weak var freeLabel: UILabel!
    
    private var isopened = false
    
    private var sectionIndex: Int = 0
    
    var monthConsumeBillModel: MonthConsumeBillModel?
    
    override func awakeFromNib() {
        dataLabel.font = UIFont.normal
        freeLabel.font = UIFont.normal
        
        // 建立点击手势识别
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(MonDetailHeadView.toggleOpen(_:)))
        
        self.addGestureRecognizer(tapGesture)
        contentView.backgroundColor = .white
    }
    
    func viewWithDateModel(monthbillModel: MonthConsumeBillModel, section: Int) {
        dataLabel.text = monthbillModel.refund_year + "年" + monthbillModel.refund_month + "月"
        freeLabel.text =  monthbillModel.new_banance_RMB + "元"
        isopened = monthbillModel.isOpened
        sectionIndex = section
        monthConsumeBillModel = monthbillModel
    }

    @objc func toggleOpen(_ sender: UITapGestureRecognizer) {
        if let d = delegate {
            d.sectionHeaderView(self, section: sectionIndex, isOpened: !isopened)
        }
    }
}
