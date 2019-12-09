//
//  MonDetailTableViewCell.swift
//  CreditApp
//
//  Created by 胡骏 on 2018/9/7.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import UIKit
import AlamofireImage

class MonDetailTableViewCell: UITableViewCell {
    static let Identifier = "MonDetailTableViewCell"
    
    @IBOutlet weak var consumeIcon: UIImageView!
    
    @IBOutlet weak var leftImageView: NSLayoutConstraint!
    
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var dateTypeLabel: UILabel!
    
    @IBOutlet weak var freeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        descLabel.font = UIFont.normal
        dateTypeLabel.font = UIFont.small
        freeLabel.font = UIFont.normal
    }

    func viewWithConsumeDetailModel(model: ConsumeDetailModel) {
        descLabel.text = model.description
        dateTypeLabel.text = model.consume_subhead
        freeLabel.text = model.amount_RMB.toStringWithPoint()
        if let url = URL(string: model.consume_icon_url) {
            consumeIcon.af_setImage(withURL: url)
        }
    }
}
