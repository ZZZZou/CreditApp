//
//  EmailLoadingViewController.swift
//  CreditApp
//
//  Created by w22543 on 2019/3/1.
//  Copyright © 2019年 CreditManager. All rights reserved.
//

import UIKit

class EmailLoadingViewController: UIViewController {

    var emailUser: String? {
        set {
            email.text = newValue
        }
        
        get {
            return email.text
        }
    }
    
    private var timer: Timer?
    private let circleLayer = CircleGradientLayer()
    
    
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var circleBackView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        circleBackView.layer.addSublayer(circleLayer)
        timer = Timer(timeInterval: 0.5, target: self, selector: #selector(EmailLoadingViewController.fire), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .default)
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        circleLayer.frame = circleBackView.bounds
    }
    
    func complete() {
        circleLayer.progress = 1
        timer?.invalidate()
        timer = nil
    }
    
    func random()-> CGFloat {//0.1-0.4
        var step = 0
        let p = circleLayer.progress
        if p <= 0.5 {
            step = Int.random(in: 0...10)
        }else if p > 0.5 && p < 0.7 {
            step = Int.random(in: 0...5)
        }else {
            step = Int.random(in: 0...2)
        }
        
        return CGFloat(step) / 100
    }
    
    

    @objc
    func fire() {
        let step = random()
        var progress = circleLayer.progress + step
        if progress > 0.95 {
            progress = 0.95
            timer?.invalidate()
            timer = nil
        }
        circleLayer.progress = progress
        
    }
    
    
     deinit {
        print("EmailLoadingViewController")
    }
    
    

}
