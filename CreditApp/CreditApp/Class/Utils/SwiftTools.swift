//
//  SwiftTools.swift
//  CreditApp
//
//  Created by 胡骏 on 2018/8/23.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import Foundation




class SwiftTools {
    class func timeDelayWithTmer(_ timer: TimeInterval, todo: @escaping () -> Void) {
        let delay = DispatchTime.now() + Double(Int64(timer * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delay) { () -> Void in
            todo()
        }
        
    }
}


public func toConfiguration(_ status: String) -> Bool {
    switch status {
    case "000":
        return true
    case "001":
        print("请求使用GET方法")
        return false
    case "002":
        print("请求缺少参数action或者使用未知的action类型")
        return false
    case "003":
        print("查找不到对应的数据， 即无数据")
        return false
    case "998":
        print("接口还没准备好")
        return false
    case "999":
        print("未知错误，需要进一步检查")
        return false
    default:
        print("Not a safe place for humans")
        return false
    }
}
