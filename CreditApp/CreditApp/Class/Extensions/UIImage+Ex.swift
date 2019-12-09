//
//  UIImage+Ex.swift
//  CreditApp
//
//  Created by 林勇彬 on 2018/8/30.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    /// 创建头像图像
    ///
    /// - parameter size:      尺寸
    /// - parameter backColor: 背景颜色
    ///
    /// - returns: 裁切后的图像
    func cz_avatarImage(size: CGSize?, backColor: UIColor = UIColor.white, lineColor: UIColor = UIColor.lightGray) -> UIImage? {
        
        var size = size
        if size == nil {
            size = self.size
        }
        let rect = CGRect(origin: CGPoint(), size: size!)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
        //背景填充
        backColor.setFill()
        UIRectFill(rect)
        //实例化一个圆形的路径
        let path = UIBezierPath(ovalIn: rect)
        //进行路径裁剪
        path.addClip()
        
        draw(in: rect)
        //绘制填充边框
        let ovalPath = UIBezierPath(ovalIn: rect)
        ovalPath.lineWidth = 2
        ovalPath.stroke()
        lineColor.setStroke()
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return result
    }
    
    /// 生成指定大小的不透明图象
    ///
    /// - parameter size:      尺寸
    /// - parameter backColor: 背景颜色
    ///
    /// - returns: 图像
    func cz_image(size: CGSize? = nil, backColor: UIColor = UIColor.white) -> UIImage? {
        
        var size = size
        if size == nil {
            size = self.size
        }
        let rect = CGRect(origin: CGPoint(), size: size!)
        //获得上下文
        /*
         size:绘图的尺寸
         不透明:false(不透明)/true(透明)
         scale：屏幕分辨率，如果指定0,则会返回屏幕当前的分辨率
         */
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
        //背景填充
        backColor.setFill()
        UIRectFill(rect)
        //绘图drawIn
        draw(in: rect)
        //取得结果
        let result = UIGraphicsGetImageFromCurrentImageContext()
        //关闭上下文
        UIGraphicsEndImageContext()
        //返回结果
        return result
    }
}
