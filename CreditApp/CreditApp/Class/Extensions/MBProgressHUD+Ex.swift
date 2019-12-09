//
//  MBProgressHUD+Ex.swift
//  CreditApp
//
//  Created by w22543 on 2019/1/9.
//  Copyright © 2019年 CreditManager. All rights reserved.
//

import MBProgressHUD
import UIKit

extension MBProgressHUD {
    @discardableResult
    static func showHUD(_ title: String = "", addedTo originView: UIView? = nil) -> MBProgressHUD{
        
        
        let indicator = UIActivityIndicatorView.appearance(whenContainedInInstancesOf: [MBProgressHUD.self])
        indicator.style = .whiteLarge
        
        var view: UIView! = originView
        if view == nil {view = UIApplication.shared.keyWindow}
        
        var hud: MBProgressHUD! = MBProgressHUD(for: view)
        if hud == nil {
            hud = MBProgressHUD.showAdded(to: view, animated: true)
        }
        
        hud.label.text = title;
        hud.label.numberOfLines = 0;
        hud.label.font = UIFont.systemFont(ofSize: 14) ;
        hud.contentColor = .white;
        
        hud.bezelView.style = .solidColor;
        if title.count > 0 {
            hud.backgroundView.color = .clear
            hud.bezelView.color = UIColor(hex: "0x333333")
        }else {
            hud.backgroundView.color = UIColor(white: 0.0, alpha: 0.5)
            hud.bezelView.color = UIColor.clear
        }
        
        hud.graceTime = 1
        hud.removeFromSuperViewOnHide = true;
        
        return hud
    }
    
    @discardableResult
    static func showHUD(addedTo originView: UIView? = nil, title: String = "", icon: String, duration: Double = 1) -> MBProgressHUD {
        var view: UIView! = originView
        if view == nil {view = UIApplication.shared.keyWindow}
        var hud: MBProgressHUD! = MBProgressHUD(for: view)
        if hud == nil {
            hud = MBProgressHUD.showAdded(to: view, animated: true)
        }
        
        hud.label.text = title;
        hud.label.numberOfLines = 0;
        hud.contentColor = UIColor.white;
        
        hud.customView = UIImageView(image: UIImage(named: "MBProgressHUD.bundle/\(icon)"))
        hud.mode = .customView;
        
        hud.bezelView.style = .solidColor;
//        hud.bezelView.color = UIColor(hex: "0x333333")
        if title.count > 0 {
            hud.backgroundView.color = .clear
            hud.bezelView.color = UIColor(hex: "0x333333")
        }else {
            hud.backgroundView.color = UIColor(white: 0.0, alpha: 0.5)
            hud.bezelView.color = UIColor.clear
        }
        
        hud.removeFromSuperViewOnHide = true;
        hud.hide(animated: true, afterDelay: duration)
        
        return hud
    }
    
    static func showError(_ error: String, addedTo view: UIView? = nil) {
        showHUD(addedTo: view, title: error, icon: "error.png")
    }
    
    static func showSuccess(_ success: String, addedTo view: UIView? = nil) {
        showHUD(addedTo: view, title: success, icon: "success.png")
    }
    
    static func showMessage(_ msg: String, addedTo originView: UIView? = nil) {
        
        var view: UIView! = originView
        if view == nil {view = UIApplication.shared.keyWindow}
        var hud: MBProgressHUD! = MBProgressHUD(for: view)
        if hud == nil {
            hud = MBProgressHUD.showAdded(to: view, animated: true)
        }
        
        hud.label.text = msg;
        hud.label.numberOfLines = 0;
        hud.mode = .text;
        hud.contentColor = UIColor.white;
        
        hud.bezelView.style = .solidColor;
        hud.bezelView.color = UIColor(hex: "0x333333")
        
        hud.removeFromSuperViewOnHide = true;
        hud.hide(animated: true, afterDelay: 1)
        
    }
    
    static func showBottomMessage(_ msg: String) {
        let view = UIApplication.shared.keyWindow!
        var hud: MBProgressHUD! = MBProgressHUD(for: view)
        if hud == nil {
            hud = MBProgressHUD.showAdded(to: view, animated: true)
        }
        
        hud.label.text = msg;
        hud.label.numberOfLines = 0;
        hud.mode = .text;
        hud.contentColor = UIColor.white;
        
        hud.bezelView.style = .solidColor;
        hud.bezelView.color = UIColor(hex: "0x333333")
        
        hud.offset = CGPoint(x: 0, y: UIScreen.height/2-64-44);
        hud.minSize = CGSize(width: 100, height: 44);
        hud.margin = 10;
        
        hud.removeFromSuperViewOnHide = true;
        hud.hide(animated: true, afterDelay: 1)
        
    }
}
