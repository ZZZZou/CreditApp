//
//  LoadingTableViewCell.swift
//  CreditApp
//
//  Created by 胡骏 on 2018/9/7.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import UIKit
import XCGLogger

class LoadingTableViewCell: UITableViewCell {
    static let Identifier = "LoadingTableViewCell"
    var logg = XCGLogger.default

    @IBOutlet weak var loadingImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func startAnimation() {
        addRotationAnim()
    }
    

    private func addRotationAnim() {
        let rotationAnim = CABasicAnimation(keyPath: "transform.rotation.z")
        
        rotationAnim.fromValue = 0
        rotationAnim.toValue = Double.pi * 2
        rotationAnim.repeatCount = MAXFLOAT
        rotationAnim.duration = 1
        rotationAnim.isRemovedOnCompletion = false
        
        loadingImg.layer.add(rotationAnim, forKey: "moveanimation")
        
    }
}
