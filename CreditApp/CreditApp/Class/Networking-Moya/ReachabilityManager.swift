//
//  ReachabilityManager.swift
//  CreditApp
//
//  Created by w22543 on 2018/11/13.
//  Copyright © 2018年 hujuun. All rights reserved.
//

import RxSwift
import Reachability
import Foundation


private let reachabilityManager = ReachabilityManager()

func connectedToInternet() -> Observable<Bool> {
    if let reach = reachabilityManager?.reach {
        return reach
    }
    return Observable.just(true)
}

private class ReachabilityManager {
    
    private let reachability: Reachability
    
    let _reach = ReplaySubject<Bool>.create(bufferSize: 1)
    var reach: Observable<Bool> {
        return _reach.asObservable()
    }
    
    init?() {
        guard let r = Reachability() else {
            return nil
        }
        self.reachability = r
        
        do {
            try self.reachability.startNotifier()
        } catch {
            return nil
        }
        
        self._reach.onNext(self.reachability.connection != .none)
        
        self.reachability.whenReachable = { _ in
            DispatchQueue.main.async { self._reach.onNext(true) }
        }
        
        self.reachability.whenUnreachable = { _ in
            DispatchQueue.main.async { self._reach.onNext(false) }
        }
    }
    
    deinit {
        reachability.stopNotifier()
    }
}
