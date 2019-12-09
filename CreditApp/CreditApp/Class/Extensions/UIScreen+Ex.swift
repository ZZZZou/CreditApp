//
//  UIScreen.swift
//  CreditApp
//
//  Created by w22543 on 2018/9/4.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import Foundation

extension UIScreen {
    class var width : CGFloat{
        get{
            return main.bounds.width
        }
    }
    
    class var height : CGFloat{
        get{
            return main.bounds.height
        }
    }
    
    class var size : CGSize{
        get{
            return main.bounds.size
        }
    }
    
}
