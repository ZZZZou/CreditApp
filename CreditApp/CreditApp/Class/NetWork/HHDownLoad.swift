//
//  HHDownLoad.swift
//  CreditApp
//
//  Created by 胡骏 on 2018/9/5.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import Foundation
import UIKit
import XCGLogger
import Alamofire
import RxSwift
import ObjectMapper
import AlamofireObjectMapper


public class TestInfoError: Error {
    var info = ""
    init(info: String) {
        self.info = info
    }
}

struct ordina<U: Mappable>: Mappable {
    var data: [U]?
    var header: [String: String] = [:]
    
    init?(map: Map) {
        
    }
    mutating func mapping(map: Map) {
        data    <- map["data"]
        header    <- map["header"]
    }
}

struct ordidict<U: Mappable>: Mappable {
    var data: U?
    var header: [String: String] = [:]
    
    init?(map: Map) {
        
    }
    mutating func mapping(map: Map) {
        data    <- map["data"]
        header    <- map["header"]
    }
}


public struct CapTotalModel: Mappable {
    var consumeName = ""
    var totlaFree = 0.0
    var isOpened = true
    var consumeDetails: [ConsumeDetailModel] = []
    public init?(map: Map) {
        
    }
    public mutating func mapping(map: Map) {
        consumeName    <- map["consumeName"]
        totlaFree    <- map["totlaFree"]
        consumeDetails    <- map["consumeDetails"]
    }
}


protocol HhDownload {
    func downloadToArrayWithParameters<T: Mappable>(_ parameters: [String: Any], url: String, modeltype: T.Type) -> Observable<[T]>
    func downloadToDictWithParameters<T: Mappable>(_ parameters: [String: Any], url: String, modeltype: T.Type) -> Observable<T>
}

extension HhDownload {
    func downloadToArrayWithParameters<T: Mappable>(_ parameters: [String: Any], url: String, modeltype: T.Type) -> Observable<[T]> {
        
        return Observable
            .create { observable in
                let request =  Alamofire
                    .request(url, method: .post, parameters: parameters)
                    .responseObject(completionHandler: { (response: DataResponse<ordina<T>>) in
                        let forecast = response.result.value
                        if let status = forecast?.header {
                            let statusString = status["status"] ?? "002"
                            if toConfiguration(statusString) == false {
                                observable.onError(TestInfoError.init(info: statusString))
                                observable.onCompleted()
                                return
                            }
                        }
                        if let data = forecast?.data {
                            observable.onNext(data)
                            observable.onCompleted()
                        } else {
                            observable.onError(TestInfoError.init(info: "999"))
                            observable.onCompleted()
                            return
                            
                        }
                    })
                return Disposables.create {
                    request.cancel()
                }
        }
    }
    
    func downloadToDictWithParameters<T: Mappable>(_ parameters: [String: Any], url: String, modeltype: T.Type) -> Observable<T> {
        
        return Observable.create { observable in
            let request = Alamofire
                .request(url, method: .post, parameters: parameters)
                .responseObject(completionHandler: { (response: DataResponse<ordidict<T>>) in
                    let forecast = response.result.value
                    if let status = forecast?.header {
                        let statusString = status["status"] ?? "002"
                        if toConfiguration(statusString) == false {
                            observable.onError(TestInfoError.init(info: statusString))
                            observable.onCompleted()
                            return
                        }
                    }
                    if let data = forecast?.data {
                        observable.onNext(data)
                        observable.onCompleted()
                    } else {
                        observable.onError(TestInfoError.init(info: "999"))
                        observable.onCompleted()
                        return
                    }
                })
            return Disposables.create {
                request.cancel()
            }
        }
    }
}
