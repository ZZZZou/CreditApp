//
//  ContainerViewController.swift
//  CreditApp
//
//  Created by wang on 2019/4/24.
//  Copyright © 2019 CreditManager. All rights reserved.
//

import Foundation

import Action
import SnapKit
import RxSwift
import UIKit

class ContainerViewController: UIViewController, BindableType {
    
    var viewModel: ContainerViewModel!
    let bag = DisposeBag()
    
    var leftView: UIView!
    var rightView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var leftBtn: UIButton!
    
    @IBOutlet weak var rightBtn: UIButton!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewConstraintTop: NSLayoutConstraint!
    
    
    weak var leftTableView: UITableView!
    weak var rightTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        selectLeft()
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.isTranslucent = false;
        
        navigationController?.navigationBar.hideNavLine()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize:18)]
        if viewModel.isLeft {
            navigationController?.navigationBar.barTintColor = UIColor(hex: "6B6F7B")
        }else {
            navigationController?.navigationBar.barTintColor = UIColor(hex: "6569F2")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.barTintColor = UIColor.white
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.textBlack, NSAttributedString.Key.font: UIFont.systemFont(ofSize:18)]
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //scrollview
        scrollView.contentSize = CGSize(width: scrollView.width*2, height: scrollView.height)
        leftView.frame = CGRect(x: 0, y: 0, width: scrollView.width, height: scrollView.height)
        rightView.frame = CGRect(x: scrollView.width, y: 0, width: scrollView.width, height: scrollView.height)
    }
    
    func bindViewModel() {
        leftBtn.rx.tap
            .bind{ [unowned self] in
                self.viewModel.isLeft = true
                self.selectLeft()
                
            }
            .disposed(by: bag)
        
        
        rightBtn.rx.tap
            .bind{ [unowned self] in
                self.viewModel.isLeft = false
                self.selectRight()
            }
            .disposed(by: bag)
        

        
    }
    
    func selectLeft() {
        self.leftBtn.backgroundColor = UIColor.white
        self.leftBtn.setTitleColor(UIColor.textBlack, for: .normal)
        self.rightBtn.backgroundColor = UIColor(hex: "0#6B6F7B")
        self.rightBtn.setTitleColor(UIColor.white, for: .normal)
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        self.navigationController?.navigationBar.barTintColor = UIColor(hex: "6B6F7B")
        self.topViewConstraintTop.constant = 24
        
    }
    
    func selectRight() {
        self.rightBtn.backgroundColor = UIColor.white
        self.rightBtn.setTitleColor(UIColor.textBlack, for: .normal)
        self.leftBtn.backgroundColor = UIColor(hex: "0#6569F2")
        self.leftBtn.setTitleColor(UIColor.white, for: .normal)
        self.scrollView.setContentOffset(CGPoint(x: self.scrollView.width, y: 0), animated: false)
        self.navigationController?.navigationBar.barTintColor = UIColor(hex: "6569F2")
        self.topViewConstraintTop.constant = 24
        
    }
    
    
    func setupUI() {
        //nav
        if viewModel.card.address.count > 0 {
            let innerBtn = UIButton()
            innerBtn.setTitle("重新体验", for: .normal)
            innerBtn.setTitleColor(.white, for: .normal)
            innerBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            innerBtn.addTarget(self, action: #selector(ContainerViewController.reload), for: .touchUpInside)
            let rightItem = UIBarButtonItem(customView: innerBtn)
            navigationItem.rightBarButtonItem = rightItem
        }
        
        //
        scrollView.isScrollEnabled = false
        //
        self.topView.layer.borderColor = UIColor.white.cgColor
        self.topView.layer.borderWidth = 1
        self.topView.layer.cornerRadius = 5
        self.topView.layer.masksToBounds = true
    }
    
    @objc
    func reload() {
        viewModel.restartAction().execute()
    }
}

extension UINavigationBar {
    func hideNavLine(in sView: UIView? = nil) {
        var superView: UIView! = sView
        if superView == nil {
            superView = self
        }
        
        for view in superView.subviews {
            if view is UIImageView && view.height == 0.5 {
                view.isHidden = true
            }else{
                hideNavLine(in: view)
            }
            
        }
    }
}

extension BankBillViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let svc = self.parent as? ContainerViewController{
            svc.topViewConstraintTop.constant = 24 - scrollView.contentOffset.y
            
            
        }
    }
}

extension ConsumeBillViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let svc = self.parent as? ContainerViewController{
            svc.topViewConstraintTop.constant = 24 - scrollView.contentOffset.y

        }
    }
}
