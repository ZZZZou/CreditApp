//
//  GraphBackView.swift
//  CreditApp
//
//  Created by 胡骏 on 2018/10/24.
//  Copyright © 2018 hujuun. All rights reserved.
//

import UIKit

class GraphBackView: UIView {

    var startColor: UIColor = UIColor(hex: "#6B6F7B")
    var endColor: UIColor = UIColor(hex: "#393C45")
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        let colors = [startColor.cgColor, endColor.cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations: [CGFloat] = [0.0, 1.0]

        let gradient = CGGradient(colorsSpace: colorSpace,
                                  colors: colors as CFArray,
                                  locations: colorLocations)!
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x: self.bounds.width, y: self.bounds.height)
        context.drawLinearGradient(gradient,
                                   start: startPoint,
                                   end: endPoint,
                                   options: CGGradientDrawingOptions(rawValue: 0))
        
    }
 

}
