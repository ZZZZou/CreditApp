//
//  BankBillModel.swift
//  CreditApp
//
//  Created by w22543 on 2018/11/27.
//  Copyright © 2018年 CreditManager. All rights reserved.
//

import RxDataSources
import ObjectMapper
import Foundation

struct BankBillSectionModel: Mappable {
    var consumeName = ""
    var totalFree = 0.0
    var isOpened = true
    var consumeDetails: [BankBillDetailModel] = []
    public init?(map: Map) {
        
    }
    public mutating func mapping(map: Map) {
        consumeName    <- map["consumeName"]
        totalFree    <- map["totlaFree"]
        consumeDetails    <- map["consumeDetails"]
    }
}

struct BankBillDetailModel: Mappable{
    
    var bank = ""
    var trans_date = ""
    var post_date = ""
    var description = ""
    var amount_RMB = 0.0
    var card_num_last_four = ""
    var original_trans_amount = ""
    var country_area = ""
    var consume_type = ""
    var consume_icon_url = ""
    var consume_subhead = ""
    public init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        bank    <- map["bank"]
        trans_date    <- map["trans_date"]
        post_date    <- map["post_date"]
        description    <- map["description"]
        amount_RMB    <- map["amount_RMB"]
        card_num_last_four    <- map["card_num_last_four"]
        original_trans_amount    <- map["original_trans_amount"]
        country_area    <- map["country_area"]
        consume_type    <- map["consume_type"]
        consume_icon_url    <- map["consume_icon_url"]
        consume_subhead    <- map["consume_subhead"]
        
    }
}

enum BankBillSectionItem {
    
    static var counter = 0
    case item(Int, BankBillDetailModel)
    case tip(Int)
    
    static func tip(with identity: Int = BankBillSectionItem.counter) -> BankBillSectionItem{
        BankBillSectionItem.counter += 1
        return .tip(identity)
    }
    
    static func item(with identity: Int = BankBillSectionItem.counter, raw: BankBillDetailModel) -> BankBillSectionItem{
        BankBillSectionItem.counter += 1
        return .item(identity, raw)
    }
}

extension BankBillSectionModel: AnimatableSectionModelType {
    
    var items: [BankBillSectionItem] {
        if isOpened {
            let items = consumeDetails.map{BankBillSectionItem.item(raw: $0)}
            if items.count > 0 {
                return items + [.tip()]
            }
        }
        return []
    }
    
    init(original: BankBillSectionModel, items: [BankBillSectionItem]) {
        self = original
        

        let model = items.compactMap{sectionItem ->BankBillDetailModel? in
            
            switch sectionItem {
            case .item(_, let raw):
                return raw
            case .tip:
                return nil
            }
        }
        self.consumeDetails = model
    }
    
    var identity: String {
        return consumeName
    }
}

extension BankBillSectionItem: IdentifiableType, Equatable {
    
    var identity: Int {
        switch self {
        case .item(let identity, _):
            return identity
        case .tip(let identity):
            return identity
        }
    }
}

func == (lhs: BankBillSectionItem, rhs: BankBillSectionItem) -> Bool {
    return lhs.identity == rhs.identity
}


extension BankBillSectionModel: Equatable {
    
}

func == (lhs: BankBillSectionModel, rhs: BankBillSectionModel) -> Bool {
    return lhs.identity == rhs.identity && lhs.items == rhs.items && lhs.isOpened == rhs.isOpened
}


extension BankBillSectionModel {
    static func demo() -> [BankBillSectionModel] {
        let fileUrl = Bundle.main.path(forResource: "BankBillDemoData.plist", ofType: nil)
        let datas = NSArray(contentsOf: URL(fileURLWithPath: fileUrl!))!
        
        let models = Array<BankBillSectionModel>(JSONArray: datas as! [[String : Any]])
        
        return models
    }
}
