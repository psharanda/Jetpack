//
//  Jetpack - Minimalistic FRP lib
//  Created by Pavel Sharanda
//  Copyright (c) 2016 SnipSnap. All rights reserved.
//

import Foundation


fileprivate struct TaggedObserver<T> {
    let token: Observable<T>.Token
    let observer: (T)->Void
}

///for observing only, can't be modified manually "var x: Bool? { return nil|true|false }"
public class Observable<T> {
    
    internal var _value: T?
    
    private var observers: [TaggedObserver<T>] = []
    
    public var lastValue: T? {
        return _value
    }
    
    public typealias Token = UInt
    
    private var lastToken: Token = 0
    
    @discardableResult
    public func subscribe(_ observer: @escaping (T)->Void) -> Token {
        
        lastToken += 1
        observers.append(TaggedObserver<T>(token: lastToken, observer: observer))
        
        if let value = _value {
            observer(value)
        }
    
        return lastToken
    }
    
    public func unsubscribe(_ token: Token) {
        guard let idx = (observers.index { $0.token == token }) else {
            return
        }
        
        observers.remove(at: idx)
    }

    internal func rawUpdate(_ newValue: T) {
        _value = newValue
        
        observers.forEach {
            $0.observer(newValue)
        }
    }
}

