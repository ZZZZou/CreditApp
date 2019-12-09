//
//  UIButton+Ex.swift
//  CreditApp
//
//  Created by 林勇彬 on 2018/8/30.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import Foundation

extension UIButton {
    public func countDown(count: Int){
        // 倒计时开始,禁止点击事件
        isEnabled = false
        
//        // 保存当前的背景颜色
//        let defaultColor = self.backgroundColor
//        // 设置倒计时,按钮背景颜色
//        backgroundColor = UIColor.darkGray
        
        var remainingCount: Int = count {
            willSet {
                setTitle("重新发送(\(newValue))", for: .normal)
                self.sizeToFit()
                if newValue <= 0 {
                    setTitle("发送验证码", for: .normal)
                }
            }
        }
        
        // 在global线程里创建一个时间源
        let codeTimer = DispatchSource.makeTimerSource(queue:DispatchQueue.global())
        // 设定这个时间源是每秒循环一次，立即开始
        codeTimer.schedule(deadline: .now(), repeating: .seconds(1))
        // 设定时间源的触发事件
        codeTimer.setEventHandler(handler: {
            
            // 返回主线程处理一些事件，更新UI等等
            DispatchQueue.main.async {
                // 每秒计时一次
                remainingCount -= 1
                // 时间到了取消时间源
                if remainingCount <= 0 {
//                    self.backgroundColor = defaultColor
                    self.isEnabled = true
                    codeTimer.cancel()
                }
            }
        })
        // 启动时间源
        codeTimer.resume()
    }
}
