//
//  CMCreditListCell.swift
//  CreditApp
//
//  Created by w22543 on 2018/9/5.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import UIKit

class CMCreditListCell: UITableViewCell {

    static let reuseIdentifier = "cell"
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bankName: UILabel!
    @IBOutlet weak var bankID: UILabel!
    @IBOutlet weak var cost: UILabel!
    @IBOutlet weak var bliiDate: UILabel!
    @IBOutlet weak var repayDate: UILabel!
    @IBOutlet weak var splitLine: UIView!
    @IBOutlet weak var cardUserName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containerView.layer.cornerRadius = 5
        containerView.layer.borderColor = UIColor(hex: "#808080").cgColor
        containerView.layer.borderWidth = 1
        
        bankName.font = UIFont.big.bold
        cost.font = UIFont.bigbig.bold
        
        bankID.textColor = UIColor.textGray
        bliiDate.textColor = UIColor.textGray
        repayDate.textColor = UIColor.textGray
        bankID.font = UIFont.small
        bliiDate.font = UIFont.small
        repayDate.font = UIFont.small
        cardUserName.font = UIFont.normal
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
