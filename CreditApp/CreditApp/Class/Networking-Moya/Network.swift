//
//  Network.swift
//  CreditApp
//
//  Created by w22543 on 2018/11/13.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import ObjectMapper
import Moya
import RxSwift
import Alamofire
import Foundation

enum WebError: Error {
    case jsonStruct
    case serverStatus(status: String)
    
    case noNetwork
    
    case notLogin
    
}

class OnlineProvider<Target> where Target: Moya.TargetType {
    fileprivate let online: Observable<Bool>
    fileprivate let provider: MoyaProvider<Target>
    
    init(endpointCloure: @escaping MoyaProvider<Target>.EndpointClosure = MoyaProvider<Target>.defaultEndpointMapping,
         requestClosure: @escaping MoyaProvider<Target>.RequestClosure = MoyaProvider<Target>.defaultRequestMapping,
         stubClosure: @escaping MoyaProvider<Target>.StubClosure = MoyaProvider.neverStub,
         manager: Manager = MoyaProvider<Target>.defaultAlamofireManager(),
         plugins: [PluginType] = [NetworkLoggerPlugin(verbose: true)],
         trackInflights: Bool = false,
         online: Observable<Bool> = connectedToInternet()) {
        self.online = online
        self.provider = MoyaProvider(endpointClosure: endpointCloure, requestClosure: requestClosure, stubClosure: stubClosure, manager: manager, plugins: plugins, trackInflights: trackInflights)
    }
    
    func request(_ target: Target) -> Observable<Moya.Response> {
        let single = provider.rx.request(target)
        return online
            .flatMap{ isOnline -> Observable<Bool> in
                let subject = PublishSubject<Bool>()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
                    if isOnline {
                        subject.onNext(true)
                    }else{
                        subject.onNext(false)
                    }
                })
                return subject.asObservable()
            }
            .filter{
                if !$0 {throw WebError.noNetwork}
                return true
            }
            .take(1)
            .flatMap{ _ in
                return single
            }
    }
}


struct Networking {
    let provider: OnlineProvider<CreditAPI>
    
    func request(_ target: CreditAPI, needLogined: Bool) -> Observable<Moya.Response> {
        
        switch target {
        case .login, .loginGetAuthCode:
            return self.provider.request(target)
            
        default:
            
            let isLogin = UserModel.currentUser.isLogin
            if needLogined && !isLogin {
                let coordinator = (UIApplication.shared.delegate as! AppDelegate).coordinator!
                let loginVM = LoginViewModel(coordinator: coordinator)
                let scene = Scene.login(loginVM)
                coordinator
                    .transition(to: scene, type: .modal)
                
                return loginVM.loginComplete
                    .filter{
                        guard $0 else {
                            throw WebError.notLogin
                        }
                        return true
                    }
                    .take(1)
                    .flatMap{ _ in
                        return self.provider.request(target)
                    }
            }else{
                return self.provider.request(target)
            }
        }
    }
    
    func request(_ target: CreditAPI) -> Observable<Moya.Response> {
        return request(target,  needLogined: true)
    }
}

// Static methods
extension Networking {
    
    static func newDefaultNetworking() -> Networking {
        return Networking(provider: OnlineProvider())
    }

}



struct WrapperModelArray<U: Mappable>: Mappable {
    var data: [U]?
    var header: [String: String] = [:]
    
    init?(map: Map) {
        
    }
    mutating func mapping(map: Map) {
        data    <- map["data"]
        header    <- map["header"]
    }
}

struct WrapperModel<U: Mappable>: Mappable {
    var data: U?
    var header: [String: String] = [:]
    
    init?(map: Map) {
        
    }
    mutating func mapping(map: Map) {
        data    <- map["data"]
        header    <- map["header"]
    }
}

struct WrapperRawArray: Mappable {
    var data:[Any] = []
    var header: [String: String] = [:]
    
    init?(map: Map) {
        
    }
    mutating func mapping(map: Map) {
        data    <- map["data"]
        header    <- map["header"]
    }
}

struct WrapperRawDictionary: Mappable {
    var data:[String: Any] = [:]
    var header: [String: String] = [:]
    
    init?(map: Map) {
        
    }
    mutating func mapping(map: Map) {
        data    <- map["data"]
        header    <- map["header"]
    }
}


extension ObservableType where E == Response{
    
    func toRawDataDictionary() -> Observable<[String: Any]> {
        return filterSuccessfulStatusCodes()
            .mapJSON(failsOnEmptyData: false)
            .flatMap { json -> Observable<[String: Any]> in
                guard let jsonDic = json as? [String: Any], let wapper = WrapperRawDictionary(JSON: jsonDic) else {
                    throw WebError.jsonStruct
                }
                if let status = wapper.header["status"] {
                    if  !toConfiguration(status) {
                        throw WebError.serverStatus(status: status)
                    }
                } else {
                    throw WebError.jsonStruct
                }
                return Observable.just(wapper.data)
        }
    }
    
    func toRawDataArray() -> Observable<[Any]> {
        return filterSuccessfulStatusCodes()
            .mapJSON(failsOnEmptyData: false)
            .flatMap { json -> Observable<[Any]> in
                guard let jsonDic = json as? [String: Any], let wapper = WrapperRawArray(JSON: jsonDic) else {
                    throw WebError.jsonStruct
                }
                if let status = wapper.header["status"] {
                    if  !toConfiguration(status) {
                        throw WebError.serverStatus(status: status)
                    }
                } else {
                    throw WebError.jsonStruct
                }
                return Observable.just(wapper.data)
        }
    }
    
    func toModel<T: Mappable>() -> Observable<T?> {
        return filterSuccessfulStatusCodes()
            .mapJSON(failsOnEmptyData: false)
            .flatMap { json -> Observable<T?> in
                guard let jsonDic = json as? [String: Any], let wapper = WrapperModel<T>(JSON: jsonDic) else {
                    throw WebError.jsonStruct
                }
                if let status = wapper.header["status"] {
                    if  !toConfiguration(status) {
                        throw WebError.serverStatus(status: status)
                    }
                } else {
                    throw WebError.jsonStruct
                }
                return Observable.just(wapper.data)
        }
    }
    
    func toModelArray<T: Mappable>() -> Observable<[T]?> {
        return filterSuccessfulStatusCodes()
            .mapJSON(failsOnEmptyData: false)
            .flatMap { json -> Observable<[T]?> in
                print(json)
                guard let jsonDic = json as? [String: Any], let wapper = WrapperModelArray<T>(JSON: jsonDic) else {
                    throw WebError.jsonStruct
                }
                if let status = wapper.header["status"] {
                    if  !toConfiguration(status) {
                        throw WebError.serverStatus(status: status)
                    }
                } else {
                    throw WebError.jsonStruct
                }
                return Observable.just(wapper.data)
        }
    }
}

