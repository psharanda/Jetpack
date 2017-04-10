//
//  Created by Pavel Sharanda on 22.09.16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

extension Observable where ValueType: Comparable {
    
    public var min: Observer<ValueType> {
        var minValue: ValueType? = nil
        
        return Observer { observer in
            return self.subscribe { result in
                if let minValueNonNil = minValue {
                    if result < minValueNonNil {
                        minValue = result
                        observer(result)
                    }
                } else {
                    minValue = result
                    observer(result)
                }
            }
        }
    }
    
    public var max: Observer<ValueType> {
        var maxValue: ValueType? = nil
        
        return Observer { observer in
            return self.subscribe { result in
                if let minValueNonNil = maxValue {
                    if result > minValueNonNil {
                        maxValue = result
                        observer(result)
                    }
                } else {
                    maxValue = result
                    observer(result)
                }
            }
        }
    }
}

extension Observable {
    
    public var count: Observer<Int> {
        return count {_ in true }
    }
    
    public func count(_ f: @escaping (ValueType)->Bool) -> Observer<Int> {
        var count = 0
        
        return Observer { observer in
            return self.subscribe { result in
                if f(result) {
                    count += 1
                    observer(count)
                }
            }
        }
    }
}

public extension Observable where ValueType == Bool {
    
    public func and<U: Observable>(_ observable: U) -> Observer<Bool> where U.ValueType == ValueType {
        return combine(observable).map {
            if let s0 = $0.0, let s1 = $0.1 {
                return s0 && s1
            } else {
                return false
            }
        }
    }

    public func or<U: Observable>(_ observable: U) -> Observer<Bool> where U.ValueType == ValueType {
        return combine(observable).map {
            if let s0 = $0.0, s0 {
                return true
            } else if let s1 = $0.1, s1 {
                return true
            } else {
                return false
            }
        }
    }
    
    public var not: Observer<Bool> {
        return map { !$0 }
    }
}


