//
//  Single.swift
//  CreditApp
//
//  Created by 胡骏 on 2018/9/11.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import Foundation

class UserSingle: NSObject, Prealm {
    static let sharedInstance = UserSingle()
    var userModel: UserModel = UserModel()
    var isLogined: Bool = false
    private override init() {
        super.init()
        let u = realmGetModel(UserModel.self)
        if let model = u.last {
            let t = UserModel()
            t.telephone = model.telephone
            t.user_uuid = model.user_uuid
            userModel = t
            isLogined = true
        } else {
            print("还没注册")
        }
    }
    
    func logging(m: UserModel) {
        let t = UserModel()
        t.telephone = m.telephone
        t.user_uuid = m.user_uuid
        userModel = t
        isLogined = true
    }
    func outting() {
        isLogined = false
    }
}
