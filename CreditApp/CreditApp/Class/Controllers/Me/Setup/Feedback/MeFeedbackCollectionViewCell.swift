//
//  MeFeedbackCollectionViewCell.swift
//  CreditApp
//
//  Created by w22543 on 2019/1/9.
//  Copyright © 2019年 CreditManager. All rights reserved.
//

import UIKit

class MeFeedbackCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var img: UIImageView!
    
    func config(with model: MeFeedbackImageModel) {
        if let img = model.underlyingImage {
            self.img.image = img
        }else{
            model.loadUnderlyingImage { img in
                self.img.image = img
            }
        }
    }
}
