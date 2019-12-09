//
//  UserModel.swift
//  CreditApp
//
//  Created by 林勇彬 on 2018/8/30.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import RealmSwift
import RxRealm
import RxSwift
import Foundation
import RealmSwift


class UserModel: Object {
    
    @objc dynamic var id = 0
    @objc dynamic var user_uuid:String? = nil
    @objc dynamic var telephone:String = ""
    @objc dynamic var iconData: Data?
    @objc dynamic var iconKey: String = ""
    @objc dynamic var nickname: String = ""
    @objc dynamic var createDate: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }
    
    override class func ignoredProperties() -> [String] {
        return ["loginStatus", "isLogin", "icon", "userinfoChanged"]
    }
    
    static var currentUser: UserModel {
        get {
            let userRealm = Realm.userRealm()
            if let user = userRealm.objects(UserModel.self).last {
                return user
            }
            let newUser = UserModel()
            Observable.just(newUser)
                .bind(to: userRealm.rx.add())
                .dispose()
            return newUser
        }
        
        set {
            let userRealm = Realm.userRealm()
            Observable.just(newValue)
                .bind(to: userRealm.rx.add())
                .dispose()
        }
    }
    
    func clear() {
        user_uuid = nil
        telephone = ""
        iconData = nil
        iconKey = ""
        nickname = ""
    }
    
    lazy var loginStatus: Observable<Bool> = { `self` in
        return Observable<UserModel>.from(object: self, emitInitialValue: true, properties: ["user_uuid"])
            .map{ $0.user_uuid != nil}
            .share(replay: 1, scope: .whileConnected)
    }(self)
    
    lazy var userinfoChanged: Observable<UserModel> = { `self` in
        return Observable<UserModel>.from(object: self, emitInitialValue: true)
            .share(replay: 1, scope: .whileConnected)
    }(self)
    
    var isLogin: Bool {
        return user_uuid != nil
    }
    
    var icon: UIImage {
        get{
            if let data = iconData, let image = UIImage(data: data) {
                return image
            }
            
            return (UIImage(named: "me"))!
        }
        
        set {
            let data = (newValue.jpegData(compressionQuality: 1))!
            self.iconData = data
        }
    }
}

class MailModel: Object {
    @objc dynamic var inputAccount: String = ""

    @objc dynamic var mail: String = ""
    @objc dynamic var password: String = ""
    @objc dynamic var mailAddress: String = ""

    @objc dynamic var time: Date?
}
