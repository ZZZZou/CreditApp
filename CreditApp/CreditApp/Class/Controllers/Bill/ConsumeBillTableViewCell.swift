//
//  ConsumeBillTableViewCell.swift
//  CreditApp
//
//  Created by w22543 on 2018/11/30.
//  Copyright © 2018年 CreditManager. All rights reserved.
//

import Kingfisher
import UIKit

class ConsumeBillTableViewCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var amount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(with model: ConsumeDetailModel) {
        icon.kf.setImage(with: URL(string: model.consume_icon_url))
        title.text = model.description
        subTitle.text = model.consume_subhead
        amount.text = String(-model.amount_RMB)
    }

}
