//
//  UIView+Ex.swift
//  CreditApp
//
//  Created by w22543 on 2018/9/5.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import Foundation

extension UIView {
    var size : CGSize {
        get {
            return self.frame.size
        }
        set {
            var frame = self.frame
            frame.size = newValue
            self.frame = frame
        }
    }
    
    var height : CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
    }
    
    var width: CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
    }
    
    var origin: CGPoint {
        get {
            return self.frame.origin
        }
        set {
            var frame = self.frame
            frame.origin = newValue
            self.frame = frame
        }
    }
    
    var x: CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }
    
    var y: CGFloat {
        get {
            return self.frame.origin.y
        }
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }
    
    func systemLayoutHeightFitting(fixedWidth : CGFloat) -> CGFloat {
        
        let widthConstraint = self.widthAnchor.constraint(equalToConstant: fixedWidth)
        widthConstraint.isActive = true
        let height = self.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        widthConstraint.isActive = false
        return height
    }
    
    func systemLayoutWidthFitting(fixedHeight : CGFloat) -> CGFloat {
        
        let heightConstraint = self.heightAnchor.constraint(equalToConstant: fixedHeight)
        heightConstraint.isActive = true
        let width = self.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).width
        heightConstraint.isActive = false
        return width
    }
    
}
