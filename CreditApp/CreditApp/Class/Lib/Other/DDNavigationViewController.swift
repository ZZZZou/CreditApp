//
//  DDNavigationViewController.swift
//  CreditApp
//
//  Created by 胡骏 on 2018/9/13.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import Foundation
import UIKit

class DDNavigationViewController: UINavigationController {
    
    fileprivate let backButton = UIButton()
    // MARK: - life cycle
    fileprivate let loadingView = LoadingView()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.setNavigationBarHidden(true, animated: true)
        interactivePopGestureRecognizer?.delegate = self
        makeUI()
    }
    
    // MARK: - public methods
    func loadingStart() {
        view.addSubview(loadingView)
        loadingView.snp.remakeConstraints { (make) in
            make.center.equalTo(view.snp.center)
            make.size.equalTo(CGSize(width: 32, height: 32))
        }
    }
    func loadingStop() {
        loadingView.removeFromSuperview()
    }
    // MARK: - notification、closume、event response
    @objc func backButtonClick() {
        _ = popViewController(animated: true)
    }
    // MARK: - private methods
    fileprivate func makeUI() {
        backButton.isHidden = true
        backButton.setImage(UIImage(named: "paypal_back_arrow"), for: .normal)
        backButton.imageView?.contentMode = .center
        backButton.addTarget(self, action: #selector(self.backButtonClick), for: .touchUpInside)
        self.view.addSubview(backButton)
        backButton.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.top.equalTo(view.layoutMarginsGuide)
            }
            make.left.equalTo(8)
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension UIViewController {
    func ddSetTitle(_ titleName: String) {
        if let _ = self.navigationController as? DDNavigationViewController {
            let topTitle = UILabel()
            topTitle.text = titleName
            topTitle.textColor = .black
            topTitle.textAlignment = .center
            topTitle.font = UIFont.big
            self.view.addSubview(topTitle)
            topTitle.snp.makeConstraints { (make) in
                if #available(iOS 11.0, *) {
                    make.top.equalTo(view.safeAreaLayoutGuide)
                } else {
                    make.top.equalTo(view.layoutMarginsGuide)
                }
                make.centerX.equalTo(view.snp.centerX)
                make.size.equalTo(CGSize(width: kWidth - 104, height: 44))
            }
        }
    }
    
    func loadingViewStart() {
        view.backgroundColor = UIColor.white
        if let navi = self.navigationController as? DDNavigationViewController {
            navi.loadingStart()
        }
    }
    func loadingViewStop() {
        if let navi = self.navigationController as? DDNavigationViewController {
            navi.loadingStop()
        }
    }
}

extension DDNavigationViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
    }
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let count = navigationController.viewControllers.count
        if count == 1 {
            backButton.isHidden = true
        } else {
            backButton.isHidden = false
        }
    }
    override func popViewController(animated: Bool) -> UIViewController? {
        loadingStop()

        return super.popViewController(animated: animated)
    }
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        loadingStop()
        return super.popToRootViewController(animated: animated)
    }
}
