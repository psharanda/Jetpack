//
//  ObservableProtocol+DispatchQueue.swift
//  Jetpack
//
//  Created by Pavel Sharanda on 20.04.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation

extension ObservableProtocol {
    public func delay(timeInterval: TimeInterval, queue: DispatchQueue = .main) ->  Observable<ValueType> {
        return flatMapLatest { value in
            return Observable.delayed(value, timeInterval: timeInterval, queue: queue)
        }
    }
    
    public func dispatchIn(queue: DispatchQueue) ->  Observable<ValueType> {
        return flatMapLatest { value in
            return Observable.dispatched(value, in: queue)
        }
    }
}
