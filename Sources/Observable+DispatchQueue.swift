//
//  ObserveValueProtocol+DispatchQueue.swift
//  Jetpack
//
//  Created by Pavel Sharanda on 20.04.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation

extension ObserveValueProtocol {
    public func delay(timeInterval: TimeInterval, on queue: DispatchQueue) -> Observable<ValueType> {
        return flatMapLatest { value in
            return Observable.delayed(value, timeInterval: timeInterval, on: queue)
        }
    }
    
    public func dispatch(on queue: DispatchQueue) -> Observable<ValueType> {
        return flatMapLatest { value in
            return Observable.dispatched(value, on: queue)
        }
    }
}
