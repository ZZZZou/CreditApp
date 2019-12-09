//
//  ConsumeBillModel.swift
//  CreditApp
//
//  Created by w22543 on 2018/11/30.
//  Copyright © 2018年 CreditManager. All rights reserved.
//

import RealmSwift
import RxDataSources
import ObjectMapper
import Foundation

class ConsumeBillModel:Object, Mappable {
    
    static var counter = 0
    @objc dynamic var id: Int = 0
    @objc dynamic var realmKey: String = ""//user_name_hello + bank + card_num_last_four
    @objc dynamic var lastModified: TimeInterval = 0
    
    @objc dynamic var user_name_hello = ""
    @objc dynamic var refund_year = ""
    @objc dynamic var refund_month = ""
    @objc dynamic var refund_day = ""
    @objc dynamic var payment_due_date_month = ""
    @objc dynamic var payment_due_date_day = ""
    @objc dynamic var banance_RMB = ""
    @objc dynamic var mini_payment_RMB = ""
    @objc dynamic var banance_USD = ""
    
    @objc dynamic var mini_payment_USD = ""
    @objc dynamic var credit_limit = ""
    @objc dynamic var bank = ""
    @objc dynamic var card_num_last_four = ""
    @objc dynamic var is_consumption_detail: Int = 0
    
    //
    @objc dynamic var total_free: Float = 0.0
    
    @objc dynamic var isOpened = false
    var consumeDetails: [ConsumeBillItem] = []
    
    required convenience init?(map: Map) {
        self.init()
        id = ConsumeBillModel.counter
        ConsumeBillModel.counter += 1
    }
    
    required convenience init(original: ConsumeBillModel, items: [ConsumeBillItem]) {
        self.init()
        id = original.id
        user_name_hello = original.user_name_hello
        refund_year = original.refund_year
        refund_month = original.refund_month
        refund_day = original.refund_day
        payment_due_date_month = original.payment_due_date_month
        payment_due_date_day = original.payment_due_date_day
        banance_RMB = original.banance_RMB
        mini_payment_RMB = original.mini_payment_RMB
        
        banance_USD = original.banance_USD
        mini_payment_USD = original.mini_payment_USD
        credit_limit = original.credit_limit
        card_num_last_four = original.card_num_last_four
        bank = original.bank
        is_consumption_detail = original.is_consumption_detail
        
        
        consumeDetails = items
    }
    
    func mapping(map: Map) {
        user_name_hello    <- map["user_name_hello"]
        refund_year    <- map["refund_year"]
        refund_month    <- map["refund_month"]
        refund_day    <- map["refund_day"]
        payment_due_date_month    <- map["payment_due_date_month"]
        payment_due_date_day    <- map["payment_due_date_day"]
        banance_RMB    <- map["new_banance_RMB"]
        mini_payment_RMB    <- map["mini_payment_RMB"]
        
        banance_USD    <- map["new_banance_USD"]
        mini_payment_USD    <- map["mini_payment_USD"]
        credit_limit    <- map["credit_limit"]
        card_num_last_four    <- map["card_num_last_four"]
        bank    <- map["bank"]
        is_consumption_detail    <- map["is_consumption_detail"]
        total_free <- map["captiveAmount.total_free"]
    }
    
    override class func ignoredProperties() -> [String] {
        return ["consumeDetails"]
    }
    
    override class func primaryKey() -> String? { return "realmKey" }
    
    func generateRealmKey() {
        realmKey = user_name_hello + bank
    }
}

extension ConsumeBillModel {
    func updateLastModifiedTime() {
        lastModified = Date().timeIntervalSince1970
    }
    
    func isTimeOut() -> Bool {
        let interval = Date().timeIntervalSince1970 - lastModified
        return interval > 60
    }
}


struct ConsumeDetailModel: Mappable{
    
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
    
    public mutating func mapping(map: Map) {
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

enum ConsumeBillItem {
    
    static var counter = 0
    case loading(Int)
    case noData(Int)
    case item(Int, ConsumeDetailModel)
    
    static func loading(with identity: Int = ConsumeBillItem.counter) -> ConsumeBillItem{
        ConsumeBillItem.counter += 1
        return .loading(identity)
    }
    
    static func noData(with identity: Int = ConsumeBillItem.counter) -> ConsumeBillItem{
        ConsumeBillItem.counter += 1
        return .noData(identity)
    }
    
    static func item(with identity: Int = ConsumeBillItem.counter, raw: ConsumeDetailModel) -> ConsumeBillItem{
        ConsumeBillItem.counter += 1
        return .item(identity, raw)
    }
}


extension ConsumeBillModel: AnimatableSectionModelType {

    var items: [ConsumeBillItem] {
        return isOpened ? consumeDetails : []
    }
    
    var identity: Int {
        return id
    }
}

extension ConsumeBillModel {
    static func == (lhs: ConsumeBillModel, rhs: ConsumeBillModel) -> Bool {
        return lhs.identity == rhs.identity
    }
}

extension ConsumeBillItem: IdentifiableType, Equatable{
    static func == (lhs: ConsumeBillItem, rhs: ConsumeBillItem) -> Bool {
        return lhs.identity == rhs.identity
    }
    
    var identity: Int {
        switch self {
        case .loading(let identity):
            return identity
        case .noData(let identity):
            return identity
        case .item(let identity, _):
            return identity
        }
    }
}


extension ConsumeBillModel {
    static func demoOne() -> ConsumeBillModel {
        let demo = ConsumeBillModel()
        demo.realmKey = "demo"
        demo.refund_year = "2018"
        demo.refund_month = "12"
        demo.payment_due_date_month = "12"
        demo.total_free = 896.18
        demo.banance_RMB = "9619.18"
        return demo
    }
    
    static func demoTwo() -> [ConsumeBillModel] {
        
        let mapper = Mapper<ConsumeBillModel>(context: nil, shouldIncludeNilValues: false)
        let one = mapper.mapArray(JSONfile: "ConsumeDetail.geojson")
        
        let mapper2 = Mapper<ConsumeDetailModel>(context: nil, shouldIncludeNilValues: false)
        let two = mapper2.mapArray(JSONfile: "MonthConsumes.geojson")
        
        guard let models = one, let oneMonth = two else {
            return []
        }
        
        let items = oneMonth.map {ConsumeBillItem.item(raw: $0)}
        models.forEach {$0.consumeDetails = items}
        
        return models
    }
    
    var isDemo: Bool {
        return realmKey == "demo"
    }
}
