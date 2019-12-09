//
//  Realm.swift
//  CreditApp
//
//  Created by wang on 2018/11/24.
//  Copyright © 2018 CreditManager. All rights reserved.
//

import RealmSwift
import Foundation

extension Realm {
    
    class func userRealm() -> Realm{
        var config = Realm.Configuration()
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("user.realm")
        return try! Realm(configuration: config)
    }
    
    class func realm(with user: UserModel = UserModel.currentUser) -> Realm?{
        
        guard let uuid = user.user_uuid else { return nil}
        
        var config = Realm.Configuration()
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(uuid).realm")
        return try! Realm(configuration: config)
    }
}
