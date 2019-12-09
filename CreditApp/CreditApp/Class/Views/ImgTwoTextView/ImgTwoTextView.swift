//
//  ImgTwoTextView.swift
//  CreditApp
//
//  Created by 胡骏 on 2018/10/25.
//  Copyright © 2018 hujuun. All rights reserved.
//

import UIKit
class ImgTwoTextView: UIView {
    let topLabel = UILabel()
    let bottomLabel = UILabel()
    let imgView = UIImageView()
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        addSubview(topLabel)
        addSubview(bottomLabel)
        addSubview(imgView)
        
        
    }
    
}
