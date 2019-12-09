//
//  LoadingView.swift
//  CreditApp
//
//  Created by 胡骏 on 2018/9/13.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import UIKit

class LoadingView: UIView {

    private let imgView = UIImageView(image: UIImage(named: "paypal_spinner"))

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        addSubview(imgView)
        imgView.contentMode = .scaleToFill
        imgView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.bottom.equalTo(0)
        }
        addRotationAnim()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
       
    }
    func addRotationAnim() {
        let rotationAnim = CABasicAnimation(keyPath: "transform.rotation.z")
        
        rotationAnim.fromValue = 0
        rotationAnim.toValue = Double.pi * 2
        rotationAnim.repeatCount = MAXFLOAT
        rotationAnim.duration = 1
        rotationAnim.isRemovedOnCompletion = false
        
        imgView.layer.add(rotationAnim, forKey: nil)
        
    }
}
