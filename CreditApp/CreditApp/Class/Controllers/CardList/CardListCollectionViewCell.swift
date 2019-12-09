//
//  CardListCollectionViewCell.swift
//  CreditApp
//
//  Created by w22543 on 2018/11/20.
//  Copyright © 2018年 CreditManager. All rights reserved.
//

import Kingfisher
import UIKit

class CardListCollectionViewCell: UICollectionViewCell {
    static let Identifier = "CardAutoCell"
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var backIcon: UIImageView!
    
    @IBOutlet weak var bankName: UILabel!
    
    @IBOutlet weak var repayDescribe: UILabel!
    
    @IBOutlet weak var repayDay: UILabel!
    
    @IBOutlet weak var refundDay: UILabel!
    
    @IBOutlet weak var paymentDay: UILabel!
    
    @IBOutlet weak var demoIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        contentView.backgroundColor = .red
//        layer.magnificationFilter = .nearest
//        layer.minificationFilter = .nearest
//        contentView.layer.magnificationFilter = .nearest
//        contentView.layer.minificationFilter = .nearest
//        backgroundImage.layer.magnificationFilter = .nearest
//        backgroundImage.layer.minificationFilter = .nearest
        backgroundImage.contentMode = .scaleAspectFit
//        layer.cornerRadius = 20
//        layer.masksToBounds = true
    }
    
    func cellWithModel(_ model: CMTotalCardModel) {
        bankName.text = model.bankName
        repayDescribe.text = "今日刷卡（*\(model.cardNum)）享免息"
        repayDay.text = model.delinquencyDay
        refundDay.text = "账单日 每月" + model.refundDay + "日"
        paymentDay.text = "还款日 每月" + model.paymentDueDay + "日"
        
        let imgUrl = URL(string: model.bankImageurl)
        backgroundImage.kf.setImage(with: imgUrl, placeholder: nil, options: nil, progressBlock: nil) {[unowned self] (img, error, cacheType, url) in
            self.backgroundImage.image = img?.stretchableImage(withLeftCapWidth: 40, topCapHeight: 40)
            
        }
        
        demoIcon.isHidden = !model.isDemo;
        
        
    }
}
