//
//  CMTotalCardModel.swift
//  CreditApp
//
//  Created by 胡骏 on 2018/9/13.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import UIKit
import ObjectMapper
import Realm
import RealmSwift



class CMTotalCardModel:Object, Mappable{
    
    @objc dynamic var realmKey: String = ""//user_name_hello + bank + card_num_last_four
    
    @objc dynamic var bank = ""
    @objc dynamic var bankName = ""
    @objc dynamic var refundDay = ""
    @objc dynamic var paymentDueDay = ""
    @objc dynamic var user_name_hello = ""
    @objc dynamic var credit_limit = ""
    @objc dynamic var from_mail = ""
    @objc dynamic var repaymentCycle = ""
    @objc dynamic var totalCaptiveFree = 0.0
    @objc dynamic var delinquencyDay = ""
    @objc dynamic var bankImageurl = ""
    @objc dynamic var bankIconurl = ""
    @objc dynamic var address = ""
    @objc dynamic var card_num_last_four = ""
    @objc dynamic var cardNum = ""
    @objc dynamic var last_update_date = ""
    
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    
    func mapping(map: Map) {
        bank    <- map["bank"]
        bankName    <- map["bankName"]
        refundDay    <- map["refundDay"]
        paymentDueDay    <- map["paymentDueDay"]
        user_name_hello    <- map["user_name_hello"]
        credit_limit    <- map["credit_limit"]
        from_mail    <- map["from_mail"]
        totalCaptiveFree    <- map["totalCaptiveFree"]
        repaymentCycle    <- map["repaymentCycle"]
        delinquencyDay <- map["delinquencyDay"]
        bankIconurl <- map["bankIconurl"]
        bankImageurl <- map["bankImageurl"]
        address <- map["address"]
        card_num_last_four <- map["card_num_last_four"]
        last_update_date <- map["last_update_date"]

        cardNum = card_num_last_four.cardnumlastfour2Normal()
    }
    
    
    override class func primaryKey() -> String? { return "realmKey" }
    
    func generateRealmKey() {
        realmKey = user_name_hello + bank
    }
}

extension CMTotalCardModel {
    static func empty() -> CMTotalCardModel {
        return CMTotalCardModel()
    }
    
    var isEmpty: Bool {
        return realmKey == ""
    }
}

extension CMTotalCardModel {
    static func demo() -> CMTotalCardModel {
        let demo = CMTotalCardModel()
        demo.realmKey = "demo"
        demo.bank = "PCCC"
        demo.bankName = "交通银行"
        
        demo.refundDay = "21"
        demo.paymentDueDay = "15"
        
        demo.user_name_hello = "王小明"
        demo.from_mail = "caobingo@qq.com"
        
        demo.cardNum = "6446"
        demo.card_num_last_four = "_6446"
        demo.delinquencyDay = "50"
        demo.bankImageurl = "http://47.92.86.63/img/bankback/PCCC.png"
        
        
        demo.totalCaptiveFree = 2299.99
        demo.credit_limit = "20000"
        
        return demo
    }
    
    var isDemo: Bool {
        return realmKey == "demo"
    }
}
