//
//  Observable+DispatchQueue.swift
//  Jetpack
//
//  Created by Pavel Sharanda on 20.04.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation

extension Observable {
    public func delay(timeInterval: TimeInterval, queue: DispatchQueue = .main) ->  Observer<ValueType> {
        return flatMapLatest { value in
            return Observer.delayed(value, timeInterval: timeInterval, queue: queue)
        }
    }
    
    public func dispatchIn(queue: DispatchQueue) ->  Observer<ValueType> {
        return flatMapLatest { value in
            return Observer.dispatched(value, in: queue)
        }
    }
}
