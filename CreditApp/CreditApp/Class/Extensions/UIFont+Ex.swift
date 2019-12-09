//
//  UIFont+Ex.swift
//  CreditApp
//
//  Created by 胡骏 on 2018/8/23.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import Foundation

extension UIFont {
    static var smallsmall : UIFont {
        return UIFont.systemFont(ofSize: 12)
    }
    static var small : UIFont {
        return UIFont.systemFont(ofSize: 14)
    }
    static var normal : UIFont {
        return UIFont.systemFont(ofSize: 16)
    }
    static var big : UIFont {
        return UIFont.systemFont(ofSize: 18)
    }
    static var bigbig : UIFont {
        return UIFont.systemFont(ofSize: 20)
    }
    
    var bold : UIFont {
        let size = self.pointSize
        return UIFont.boldSystemFont(ofSize: pointSize)
    }
}

