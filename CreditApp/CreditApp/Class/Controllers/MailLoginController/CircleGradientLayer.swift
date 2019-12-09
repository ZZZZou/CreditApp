//
//  CircleGradientLayer.swift
//  CreditApp
//
//  Created by w22543 on 2019/3/1.
//  Copyright © 2019年 CreditManager. All rights reserved.
//

import UIKit

class CircleGradientLayer: CALayer {

    var circleForegroundColor = UIColor.mainOrange {
        didSet {
            forgroundLayer.backgroundColor = circleForegroundColor.cgColor
        }
    }
    var circleBackgroundColor = UIColor.backgroundGray {
        didSet {
            backgroundLayer.backgroundColor = circleBackgroundColor.cgColor
        }
    }
    var progress: CGFloat = 0.0 {
        didSet {
            addAnimation(with: progress)
        }
    }
    var lineWidth: CGFloat = 6 {
        didSet {
            circleShapeLayer.lineWidth = self.lineWidth;
        }
    }
    
    fileprivate let backgroundLayer = CALayer()
    fileprivate let forgroundLayer = CALayer()
    fileprivate let circleShapeLayer = CAShapeLayer()
    
    override init() {
        super.init()
        initSublayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        
        print("layoutSublayers")
        setupSublayer()
        
    }
    
    override func display() {
        super.display()
        print("displayIfNeeded")
    }
    
    fileprivate func initSublayer() {
        addSublayer(backgroundLayer)
        addSublayer(forgroundLayer)
        
        circleShapeLayer.fillColor = UIColor.clear.cgColor
        circleShapeLayer.strokeColor = UIColor.white.cgColor
        circleShapeLayer.lineJoin = .round
        circleShapeLayer.lineCap = .round
        
//        backgroundColor = UIColor.black.cgColor
        forgroundLayer.backgroundColor = circleForegroundColor.cgColor
        backgroundLayer.backgroundColor = circleBackgroundColor.cgColor
        circleShapeLayer.lineWidth = lineWidth;
    }
    
    fileprivate func copyShapeLayer(layer: CAShapeLayer) -> CAShapeLayer{
        let copy = CAShapeLayer()
        copy.fillColor = layer.fillColor
        copy.strokeColor = layer.strokeColor
        copy.lineJoin = layer.lineJoin
        copy.lineCap = layer.lineCap
        copy.lineWidth = layer.lineWidth
        copy.path = layer.path
        
        copy.frame = layer.frame
        
        return copy
    }
    
    fileprivate func setupSublayer() {
        
        forgroundLayer.frame = bounds
        backgroundLayer.frame = bounds
        circleShapeLayer.frame = bounds
        
        let path = UIBezierPath()
        let radius = CGFloat.minimum(self.bounds.size.width, self.bounds.size.height)/2 - lineWidth;
        path.addArc(withCenter: circleShapeLayer.position, radius: radius, startAngle: CGFloat(CGFloat(Float.pi)), endAngle: CGFloat(Float.pi*3), clockwise: true)
        circleShapeLayer.path = path.cgPath;
        
        let backgroundMask = copyShapeLayer(layer: circleShapeLayer)
        backgroundLayer.mask = backgroundMask
        circleShapeLayer.strokeEnd = 0
        forgroundLayer.mask = circleShapeLayer
    }
    
    fileprivate func addAnimation(with p: CGFloat) {
        
        var progress = p
        if progress >= 1 {
            progress = 1;
        }
        if progress < 0 {
            progress = 0;
        }
        
        let lastToValue = circleShapeLayer.presentation()!.strokeEnd
        let animation = CABasicAnimation()
        animation.keyPath = "strokeEnd"
        animation.duration = 0.5
        animation.fromValue = lastToValue
        animation.toValue = progress
        animation.delegate = self
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode(rawValue: "forwards")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName(rawValue: "easeInEaseOut"))
        circleShapeLayer.removeAllAnimations()
        circleShapeLayer.add(animation, forKey: "key")
        
    }
    
}

extension CircleGradientLayer: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
//        circleShapeLayer.strokeEnd = circleShapeLayer.presentation()!.strokeEnd
        
    }
}
