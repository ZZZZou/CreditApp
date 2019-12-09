//
//  GuideViewController.swift
//  CreditApp
//
//  Created by w22543 on 2019/2/25.
//  Copyright © 2019年 CreditManager. All rights reserved.
//

import UIKit

class GuideViewController: UIViewController {

    
    lazy var scrollView: UIScrollView = { `self` in
        let scroll = UIScrollView()
        scroll.frame = UIScreen.main.bounds
        scroll.showsHorizontalScrollIndicator = false
        scroll.showsVerticalScrollIndicator = false
        scroll.isPagingEnabled = true
        scroll.bounces = false
        
        return scroll
    }(self)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(scrollView)
        addScrollImage()
        // Do any additional setup after loading the view.
    }
    
    func addScrollImage() {
        let actionBtn = createBtn();
        
        let images = ["guide1", "guide2", "guide3", "guide4"]
        images.enumerated().forEach { i, imgName in
            
            let imgView = UIImageView(image: UIImage(named: imgName))
            imgView.frame = CGRect(x: UIScreen.width * CGFloat(i), y: 0, width: UIScreen.width, height: UIScreen.height)
            scrollView.addSubview(imgView)
            
            if i == images.count-1 {
                scrollView.addSubview(actionBtn)
            }
        }
        scrollView.contentSize = CGSize(width: UIScreen.width * CGFloat(images.count), height: 0);
    }
    
    func createBtn() -> UIButton {
        let btn = UIButton(frame: CGRect(x: 3 * UIScreen.width, y: UIScreen.height - 200, width: UIScreen.width, height: 200))
        btn.backgroundColor = .clear
        
        btn.addTarget(self, action: #selector(GuideViewController.btnClick), for: .touchUpInside)
        
        return btn;
        
    }

    @objc func btnClick() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.coordinator = SceneCoordinator(window: delegate.window!)
        let rootScent = Scene.root(delegate.coordinator)
        delegate.coordinator.transition(to: rootScent, type: .root)
    }
}


extension GuideViewController: UIScrollViewDelegate {
    
}
