//
//  UIDevice+Ex.swift
//  CreditApp
//
//  Created by 胡骏 on 2018/8/23.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import Foundation


extension UIDevice {
    public func isX() -> Bool {
        if UIScreen.main.bounds.height == 812 {
            return true
        }
        
        return false
    }
    
    public func is5s() -> Bool {
        if UIScreen.main.bounds.height == 568 {
            return true
        }
        
        return false
    }
}

let kWidth = UIScreen.main.bounds.size.width
let kHight = UIScreen.main.bounds.size.height
