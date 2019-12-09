//
//  CreditAPI.swift
//  CreditApp
//
//  Created by w22543 on 2018/9/12.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import Moya
import Foundation

enum CreditAPI {
    case login(iphone: String, captcha: String)
    case cardsList(isAllUpdate: Bool)
    case cardAllMonthsBill(bank: String, user_name_hello: String, from_mail: String, is_first_bill: Bool)
    case detailBillOfOneMonth(bank: String, year: String, month: String, cardIDLastFour: String)
    case bankBill(bank: String, user_name_hello: String)
    case loginGetAuthCode(iphone: String, keyNumber: String)
    case uploadImage(imageData: Data)
    case getImage(key: String)
    case changeUsername(userName: String)
    case feedback(text: String)
    case isOnline()
}


extension CreditAPI : TargetType{
    
    /// The target's base `URL`.
    var baseURL: URL {
        return URL(string: "http://www.kingcredit.top:8106")!
//        return URL(string: "http://192.168.2.3:8081")!

    }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        switch self {
        case .login:
            return "/ja/api/register/v1"
        case .cardsList:
            return "/ja/api/card/total"
        case .cardAllMonthsBill:
            return "/ja/api/card/detail"
        case .detailBillOfOneMonth:
            return "/ja/api/card/monthconsumes"
        case .bankBill:
            return "/ja/api/card/amountstatistics"
        case .loginGetAuthCode:
            return "/ja/api/msgSend"
        case .uploadImage:
            return "ja/api/userimg/upload"
        case .getImage:
            return "ja/api/userimg"
        case .changeUsername:
            return "ja/api/userNameChange"
        case .feedback:
            return "ja/api/update/credipAppFeedback"
        case .isOnline:
            return "ja/api/config"
        }
        
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        return.post
    }
    
    var parameters: [String: Any]? {
        
        switch self {
            
        case .login(let iphone, let captcha):
            return ["userNumber": iphone, "authCode": captcha, "mobile": "ios"]
        case .cardsList(let isAllUpdate):
            return ["userUUID": UserModel.currentUser.user_uuid!,
                "isAllUpdate": isAllUpdate]
            
        case .cardAllMonthsBill(let bank, let user_name, let mail, let is_first_bill):
            return [
                "userUUID": UserModel.currentUser.user_uuid!,
                "bank": bank,
                "user_name_hello": user_name,
                "from_mail": mail,
                "is_first_bill": is_first_bill
                ]
            
        case .detailBillOfOneMonth(let bank, let year, let month, let cardIDLastFour):
            return [
                "userUUID": UserModel.currentUser.user_uuid!,
                "bank": bank,
                "refund_year": year,
                "refund_month": month,
                "card_num_last_four": cardIDLastFour
            ]
        case .bankBill(let bank, let user_name_hello):
            return ["userUUID": UserModel.currentUser.user_uuid!,
                    "bank": bank, "user_name_hello":user_name_hello]
        case .loginGetAuthCode(let iphone, let keyNumber):
            return ["userNumber": iphone, "mobile": "ios", "keyNumber": keyNumber]
        case .uploadImage:
            return [:]
        case .getImage(let key):
            return ["get-image-file": key]
        case .changeUsername(let userName):
            return [
                "userUUID": UserModel.currentUser.user_uuid!,
                "userName": userName
            ]
        case .feedback(let text):
            return [
                "userUUID": UserModel.currentUser.user_uuid!,
                    "feedback": text
            ]
        case .isOnline():
            return [:]
        }
    }
    
    /// The type of HTTP task to be performed.
    var task: Task {
        
        switch self {
        case .uploadImage(let imageData):
            let uuid = UserModel.currentUser.user_uuid!
            
            let bodyPart_uuid = MultipartFormData(provider: .data(uuid.data(using: .utf8)!), name: "userUUID")
            let bodyPart_data = MultipartFormData(provider: .data(imageData), name: "editormd-image-file", fileName: "userIcon.png", mimeType: "image/png")
            return .uploadMultipart([bodyPart_uuid, bodyPart_data])
        default:
            break
        }
        
        let encoding: ParameterEncoding = URLEncoding.default
        if let requestParameters = parameters {
            return .requestParameters(parameters: requestParameters, encoding: encoding)
        }
        return .requestPlain
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    /// Provides stub data for use in testing.
    var sampleData: Data {
        return Data()
    }

}

// MARK: - Provider support

func stubbedResponse(_ filename: String) -> Data! {
    @objc class TestClass: NSObject { }
    
    let bundle = Bundle(for: TestClass.self)
    let path = bundle.path(forResource: filename, ofType: "json")
    return (try? Data(contentsOf: URL(fileURLWithPath: path!)))
}
