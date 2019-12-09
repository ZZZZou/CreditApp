//
//  Scene.swift
//  CreditApp
//
//  Created by w22543 on 2018/11/19.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import Foundation

enum Scene {
    case root(SceneCoordinator)
    case login(LoginViewModel)
    case credit(Scene.Credit)
    case email(Scene.Email)
    case me(Scene.Me)
    case webBrowser(BorrowingViewModel)
}

extension Scene {
    enum Credit {
        case container(ContainerViewModel)
        case bankBill(BankBillViewModel)
        case consumeBill(ConsumeBillViewModel)
    }
}

extension Scene {
    enum Email {
        case selectEmail(SelectEmailViewModel)
        case webLogin(WebLoginViewModel)
        case webAutoLogin(WebAutoLoginViewModel)
    }
}

extension Scene {
    enum Me {
        case setup(SetupViewModel)
        case info(MeInfoViewModel)
        case feedback(MeFeedbackViewModel)
        case about(MeAboutViewModel)
        case nickname(MeNicknameSettingViewModel)
        case icon(MeIconViewModel)
    }
}
