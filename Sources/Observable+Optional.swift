//
//  Created by Pavel Sharanda on 16.02.17.
//  Copyright © 2017. All rights reserved.
//

import Foundation

public protocol Optionable {
    associatedtype Wrapped
    init(_ some: Wrapped)
    func flatMap<U>(_ f: (Wrapped) throws -> U?) rethrows -> U?
}

extension Optional: Optionable  {
    
}

extension ObservableProtocol where ValueType: Optionable {
    
    public var someOnly: Observable<ValueType.Wrapped> {
        return flatMap { $0.flatMap {$0} }
    }
    
    public var noneOnly: Observable<Void> {
        return flatMap {
            $0.flatMap {_ -> Void? in nil } ?? ()
        }
    }
    
    public var isNone: Observable<Bool> {
        return map { ($0.flatMap { _ in return false }) ?? true }
    }
    
    public var isSome: Observable<Bool> {
        return map { ($0.flatMap { _ in return true }) ?? false }
    }
}

extension ObservableProtocol {
    public var optionalized: Observable<ValueType?> {
        return map { Optional.some($0) }
    }
}

extension ObservableProtocol where ValueType: Optionable, ValueType.Wrapped: Equatable  {
    
    public var distinct: Observable<ValueType> {
        
        return Observable<ValueType> { observer in
            var lastValue: ValueType?
            
            func test(_ result: ValueType) -> ValueType? {
                if let lv = lastValue {
                    return (lv.flatMap { $0 } == result.flatMap { $0 }) ? nil : result
                } else {
                    lastValue = result
                    return result
                }
            }
            
            return self.subscribe { result in
                if let newValue = test(result) {
                    observer(newValue)
                }
            }
        }
    }
}

