//
//  CapAmountHeadView.swift
//  CreditApp
//
//  Created by 胡骏 on 2018/9/5.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import UIKit

class CapAmountHeadView: UITableViewHeaderFooterView {

    static let Identifier = "CapAmountHeadView"
    
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var totalFreeLabel: UILabel!
    
    @IBOutlet weak var openedButton: UIButton!
    
    override func awakeFromNib() {
        nameLabel.font = UIFont.normal
        totalFreeLabel.font = UIFont.normal
    }
    
    func viewWithCapTotalModel(_ model: CapTotalModel, row: Int) {
        nameLabel.text = model.consumeName
        totalFreeLabel.text = model.totlaFree.toStringWithPoint()
        topView.isHidden = row == 0
    }

}
