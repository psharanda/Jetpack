//
//  Created by Pavel Sharanda on 22.09.16.
//  Copyright © 2016 SnipSnap. All rights reserved.
//

import Foundation

extension Observable where T: Comparable {
    
    public var min: Observable<T> {
        let signal = Signal<T>()
        
        var minValue: T? = nil
        
        subscribe { result in
            
            if let minValueNonNil = minValue {
                if result < minValueNonNil {
                    minValue = result
                    signal.update(result)
                }
            } else {
                minValue = result
                signal.update(result)
            }
        }
        return signal
    }
    
    public var max: Observable<T> {
        let signal = Signal<T>()
        
        var maxValue: T? = nil
        
        subscribe { result in
            
            if let minValueNonNil = maxValue {
                if result > minValueNonNil {
                    maxValue = result
                    signal.update(result)
                }
            } else {
                maxValue = result
                signal.update(result)
            }
        }
        return signal
    }
}

extension Observable {
    public var count: Observable<Int> {
        let signal = Signal<Int>()
        
        var count = 0
        
        subscribe { result in
            count += 1
            signal.update(count)
        }
        return signal
    }
    
    @discardableResult
    public func count(_ f: @escaping (T)->Bool) -> Observable<Int> {
        let signal = Signal<Int>()
        
        var count = 0
        
        subscribe { result in
            if f(result) {
                count += 1
                signal.update(count)
            }
        }
        
        return signal
    }
}

public protocol BooleanType {
    var boolValue: Bool {get}
}

extension Bool: BooleanType {
    public var boolValue: Bool {
        return self
    }
}

public extension Observable where T: BooleanType {
    
    @discardableResult
    public func and(_ observable: Observable<Bool>) -> Observable<Bool> {
        return combine(observable).map {
            if let s0 = $0.0, let s1 = $0.1 {
                return s0.boolValue && s1
            } else {
                return false
            }
        }
    }
    
    @discardableResult
    public func or(_ observable: Observable<Bool>) -> Observable<Bool> {
        return combine(observable).map {
            if let s0 = $0.0, s0.boolValue {
                return true
            } else if let s1 = $0.1, s1 {
                return true
            } else {
                return false
            }
        }
    }
    
    public var not: Observable<Bool> {
        return map { !$0.boolValue }
    }
}


