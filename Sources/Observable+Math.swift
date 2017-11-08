//
//  Created by Pavel Sharanda on 22.09.16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

extension ObservableProtocol where ValueType: Comparable {
    
    public var min: Observable<ValueType> {
        return Observable { observer in
            var minValue: ValueType? = nil
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
    
    public var max: Observable<ValueType> {
        return Observable { observer in
            var maxValue: ValueType? = nil
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

extension ObservableProtocol {
    
    public var count: Observable<Int> {
        return count {_ in true }
    }
    
    public func count(_ f: @escaping (ValueType)->Bool) -> Observable<Int> {
        return Observable { observer in
            var count = 0
            return self.subscribe { result in
                if f(result) {
                    count += 1
                    observer(count)
                }
            }
        }
    }
}

extension ObservableProtocol where ValueType == Bool {
    
    public func and<T: ObservableProtocol>(_ observable: T) -> Observable<Bool> where T.ValueType == ValueType {
        return combine(observable).map {
            if let s0 = $0.0, let s1 = $0.1 {
                return s0 && s1
            } else {
                return false
            }
        }
    }

    public func or<T: ObservableProtocol>(_ observable:T) -> Observable<Bool> where T.ValueType == ValueType {
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
    
    public var not: Observable<Bool> {
        return map { !$0 }
    }
}


