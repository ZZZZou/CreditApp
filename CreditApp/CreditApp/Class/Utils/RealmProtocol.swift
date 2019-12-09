//
//  RealmProtocol.swift
//  CreditApp
//
//  Created by 胡骏 on 2018/8/23.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import Foundation
import RealmSwift

class AdvertiseImgModel: Object {
    @objc dynamic var isLatest: String = ""
    @objc dynamic var ver: String = "0"
    @objc dynamic var start: String?
    @objc dynamic var expire: String?
    @objc dynamic var url: String = ""
    @objc dynamic var picture: Data?
    @objc dynamic var type: String = ""
}

class AuthTimeModel: Object {
    @objc dynamic var nowDate: String = ""
    @objc dynamic var num: Int = 0
}

protocol Prealm: class {
    func realmGetModel<T: Object>(_ type: T.Type) -> Results<(T)>
    func realmAddModel<T: Object>(_ model: T) -> Bool
    func realmDeleteAllModel<T: Object>(_ type: T.Type) -> Bool
    func realmDeleteResultsModel<T: Object>(_ results: Results<(T)>)
    
    func realmMailSearch(_ mail: String) -> Results<(MailModel)>
    
    func realmAuthTimeModelSearch(_ date: String) -> Results<(AuthTimeModel)>

}

extension Prealm {
    
    func realmAuthTimeModelSearch(_ date: String) -> Results<(AuthTimeModel)> {
        let reealm = try! Realm()
        let predicate = NSPredicate(format: "nowDate = %@", date)
        return reealm.objects(AuthTimeModel.self).filter(predicate)
    }

    
    
    func realmMailSearch(_ mail: String) -> Results<(MailModel)> {
        let reealm = try! Realm()
        let predicate = NSPredicate(format: "mail = %@", mail)
        return reealm.objects(MailModel.self).filter(predicate)
    }
    
    func realmGetModel<T: Object>(_ type: T.Type) -> Results<(T)> {
        let reealm = try! Realm()
        
        return reealm.objects(type)
    }
    
    func realmAddModel<T: Object>(_ model: T) -> Bool {
        
        DispatchQueue.global().async {
            let realm = try! Realm()
            realm.beginWrite()
            realm.add(model)
            try! realm.commitWrite()
            print("缓存成功")
        }
        return true
    }
    
    func realmDeleteAllModel<T: Object>(_ type: T.Type) -> Bool {
        let results = realmGetModel(type)
        if results.count == 0 {
            return false
        }
        let realm = try! Realm()
        realm.beginWrite()
        realm.delete(results)
        try! realm.commitWrite()
        print("删除缓存成功")
        return true
    }
    
    func realmDeleteResultsModel<T: Object>(_ results: Results<(T)>) {
        let realm = try! Realm()
        realm.beginWrite()
        realm.delete(results)
        try! realm.commitWrite()
        print("删除缓存成功")
    }
}
