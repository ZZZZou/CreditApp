//
//  AboutViewModel.swift
//  CreditApp
//
//  Created by wang on 2019/3/10.
//  Copyright © 2019 CreditManager. All rights reserved.
//

import Foundation

struct MeAboutViewModel {
    
    func call(_ number: String) {
        let url = URL(string: "telprompt:\(number)")!
        UIApplication.shared.openURL(url)
    }
}
