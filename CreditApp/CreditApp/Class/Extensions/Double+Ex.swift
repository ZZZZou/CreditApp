//
//  Double+Ex.swift
//  CreditApp
//
//  Created by 胡骏 on 2018/9/6.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import Foundation

extension Double {
    func toStringWithPoint(point: Int = 2) -> String {
        return String(format: "%.\(point)f", self)
    }
}
