//
//  CapDetailTableViewCell.swift
//  CreditApp
//
//  Created by 胡骏 on 2018/9/5.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import UIKit

class CapDetailTableViewCell: UITableViewCell {
    static let Identifier = "CapDetailTableViewCell"

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var freeLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var typeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        nameLabel.font = UIFont.normal
        freeLabel.font = UIFont.normal
        dateLabel.font = UIFont.small
        typeLabel.font = UIFont.small
       
    }

    func viewWithDetailModel(_ model: ConsumeDetailModel) {
        nameLabel.text = model.description
        freeLabel.text = model.amount_RMB.toStringWithPoint() + "元"
        dateLabel.text = model.trans_date
        typeLabel.text = model.consume_type.toTransnameWithType()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
