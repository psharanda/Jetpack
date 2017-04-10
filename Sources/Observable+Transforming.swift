//
//  Created by Pavel Sharanda on 20.09.16.
//  Copyright © 2016 SnipSnap. All rights reserved.
//

import Foundation

extension Observable {
    
    @discardableResult
    public func map<U>(_ f: @escaping (T) -> U) -> Observable<U> {
        let signal = Signal<U>()
        subscribe { result in
            signal.update(f(result))
        }
        return signal
    }
    
    @discardableResult
    public func reduce<U>(_ initial: U, f: @escaping (U, T) -> U) -> Observable<U> {
        let signal = Signal<U>()
        var reduced: U = initial
        subscribe { result in
            reduced = f(reduced, result)
            signal.update(reduced)
        }
        return signal
    }
    
    @discardableResult
    public func just<U>(_ value: U) -> Observable<U>{
        return map { _ in
            return value
        }
    }
    
    public var just: Observable<Void>{
        return map { _ in }
    }
    
    @discardableResult
    public func findIndex(_ f: @escaping ((T) -> Bool)) -> Observable<Int> {
        let signal = Signal<Int>()
        var idx = 0
        subscribe { result in
            if  f(result) {
                signal.update(idx)
            }
            idx += 1
        }
        return signal
    }
}

extension Observable where T: Equatable {
    
    @discardableResult
    public func findIndex(of value: T) -> Observable<Int> {
        let signal = Signal<Int>()
        var idx = 0
        subscribe { result in
            if  result == value {
                signal.update(idx)
            }
            idx += 1
        }
        return signal
    }
}


