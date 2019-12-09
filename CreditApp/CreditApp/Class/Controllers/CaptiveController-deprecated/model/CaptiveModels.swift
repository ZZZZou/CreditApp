//
//  CaptiveModels.swift
//  CreditApp
//
//  Created by 胡骏 on 2018/9/7.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import Foundation

import UIKit
import XCGLogger
import Alamofire
import RxSwift
import ObjectMapper
import AlamofireObjectMapper
///
public struct MonthConsumeBillModel: Mappable{
    var user_name_hello = ""
    var refund_year = ""
    var refund_month = ""
    var refund_day = ""
    var payment_due_date_month = ""
    var payment_due_date_day = ""
    var new_banance_RMB = ""
    var mini_payment_RMB = ""
    var new_banance_USD = ""
    
    var mini_payment_USD = ""
    var credit_limit = ""
    var bank = ""
    var card_num_last_four = ""
    var is_consumption_detail: Int = 0

    var isOpened = false
    
    public init?(map: Map) {
        
    }
    
    public mutating func mapping(map: Map) {
        user_name_hello    <- map["user_name_hello"]
        refund_year    <- map["refund_year"]
        refund_month    <- map["refund_month"]
        refund_day    <- map["refund_day"]
        payment_due_date_month    <- map["payment_due_date_month"]
        payment_due_date_day    <- map["payment_due_date_day"]
        new_banance_RMB    <- map["new_banance_RMB"]
        mini_payment_RMB    <- map["mini_payment_RMB"]
        
        new_banance_USD    <- map["new_banance_USD"]
        mini_payment_USD    <- map["mini_payment_USD"]
        credit_limit    <- map["credit_limit"]
        card_num_last_four    <- map["card_num_last_four"]
        bank    <- map["bank"]
        is_consumption_detail    <- map["is_consumption_detail"]
    }
}


public struct CaptiveAmountModel: Mappable{
    var interest = 0.0
    var commission = 0.0
    var annual_fee = 0.0
    var overdue_tax = 0.0
    var total_free = 0.0

    
    public init?(map: Map) {
        
    }
    
    public mutating func mapping(map: Map) {
        interest    <- map["interest"]
        commission    <- map["commission"]
        annual_fee    <- map["annual_fee"]
        overdue_tax    <- map["overdue_tax"]
        total_free    <- map["total_free"]
        
    }
}

