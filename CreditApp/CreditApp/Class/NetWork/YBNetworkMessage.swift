//
//  YBNetworkMessage.swift
//  swift-sina
//
//  Created by 林勇彬 on 2018/3/9.
//  Copyright © 2018年 林勇彬. All rights reserved.
//

import UIKit

enum YBHTTPMethod {
    case GET
    case POST
}

class YBNetworkMessage: AFHTTPSessionManager {
    //单例，静态，常量
    //第一次加载的时候，会把结果保存在内存中
    static let shared:YBNetworkMessage = {
        let instant = YBNetworkMessage()
        instant.responseSerializer.acceptableContentTypes = ["text/html","application/json"]
        return instant
    }()
    
    
    func requestToken(method:YBHTTPMethod = .GET, URLString:String,parameters:[String:Any]?,completion:@escaping(_ json:Any?,_ isSuccess:Bool) ->()) {
        
        //判断参数字典是否存在，如果为nil，则应该新建一个字典
        var parameters = parameters
        if parameters == nil {
            parameters = [String:Any]()
        }
        
        request(method: method, URLString: URLString, parameters: parameters!, completion: completion)
    }
    
    
    func request(method:YBHTTPMethod = .GET, URLString:String,parameters:[String:Any],completion:@escaping(_ json:Any?,_ isSuccess:Bool) ->()) {
        
        let success = {(task:URLSessionDataTask,json:Any?) ->() in
            print("请求成功\n参数:\n\(parameters)\n结果:\n\(String(describing: json))")
            completion(json, true)
        }
        let failure = {(task:URLSessionDataTask?,error:Error) ->() in
            
            completion(nil,false)
        }
        
        if method == .GET {
            get(URLString, parameters: parameters, progress: nil, success: success, failure: failure)
        }else{
            post(URLString, parameters: parameters, progress: nil, success: success, failure: failure)
        }
    }
}
