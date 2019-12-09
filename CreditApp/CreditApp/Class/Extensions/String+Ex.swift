//
//  String+Ex.swift
//  CreditApp
//
//  Created by 胡骏 on 2018/8/23.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import Foundation
import UIKit


extension String {
    
    func ht_sizeWithfont(_ font: CGFloat, isFollowSystem: Bool = true) -> CGSize {
        let attributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: font)
        ]
        return self.size(withAttributes: attributes)
    }
    
    func ht_sizeWithfont(_ font: CGFloat, width: CGFloat, isFollowSystem: Bool = true) -> CGSize {
        let attributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: font)
        ]
        let size = CGSize(width: width, height: 1000)
        let s = self as NSString
        let result = s.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        return result.size
    }
    
    func ht_separatedBusPlate() -> [String]? {
        
        if self.count == 0 {
            return nil
        } else {
            return self.components(separatedBy: ",")
        }
    }
    
    func ht_AddingPercentEncoding() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
    }
    
    /// 手机号码验证
    ///
    /// - Parameter phoneStr: 手机号码
    /// - Returns: 是与否
    func validateMobile() -> Bool {

        let MOBILE = "0?(13|14|15|17|18|19)[0-9]{9}"
     

        let regextestmobile = NSPredicate(format: "SELF MATCHES %@", MOBILE)
       
        if (regextestmobile.evaluate(with: self) == true)
           
        {
            return true;
        }
        else
        {
            return false;
        }
    }
//    TODO
    func toTransnameWithType() -> String {
        var name = self
        switch self {
        case "11":
            name = "利息"
        case "12":
            name = "手续费"
        case "13":
            name = "年费"
        case "14":
            name = "滞纳金"
        case "21":
            name = "微信支付"
        case "31":
            name = "支付宝"
        default:
            break
        }
        return name
    }
    
    func cardnumlastfour2Normal() -> String {
        let arr = self.split(separator: "_")
        var result = ""
        for index in 0 ..< arr.count {
            let numString = String(arr[index])
            if numString.count < 2 {
                continue
            }
            if index == arr.count - 1 {
                result += numString
            } else {
                result = result + numString + ","
            }
            
        }
      return result
    }
    
    func toLoginNumber() -> String {
        var result = ""
        var num = [String]()
        for ch in self {
            num.append(String(ch))
        }
        for index in 0 ..< 50 {
            switch index {
            case 43:
                result += Int(num[0])!.toOneNumberString()
            case 26:
                result += Int(num[1])!.toOneNumberString()
            case 47:
                result += Int(num[2])!.toOneNumberString()
            case 38:
                result += Int(num[3])!.toOneNumberString()
            case 46:
                result += Int(num[4])!.toOneNumberString()
            case 4:
                result += Int(num[5])!.toOneNumberString()
            case 29:
                result += Int(num[6])!.toOneNumberString()
            case 39:
                result += Int(num[7])!.toOneNumberString()
            case 31:
                result += Int(num[8])!.toOneNumberString()
            case 20:
                result += Int(num[9])!.toOneNumberString()
            case 3:
                result += Int(num[10])!.toOneNumberString()
            default:
                let i = Int.random(in: 0 ..< 10)
                result += "\(i)"
            }
        }
        return result
    }
}

extension Int {
    func toOneNumberString() -> String {
        return "\((self + 1) % 10)"
    }
}
