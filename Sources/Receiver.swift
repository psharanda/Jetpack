//
//  Created by Pavel Sharanda on 16.02.17.
//  Copyright © 2017. All rights reserved.
//

import Foundation

/**
 Wrapper around some state which provides interface for binding
 */
public struct Receiver<T>: Bindable {
    
    private let setter: (T)->Void
    
    public init(setter: @escaping (T)->Void) {
        self.setter = setter
    }
    
    public func update(_ newValue: T) {
        setter(newValue)
    }
}

extension Receiver {
    public func map<U>(_ transform: @escaping (U) -> T) -> Receiver<U> {
        return Receiver<U> {
            self.update(transform($0))
        }
    }
}

extension Receiver where ValueType: Optionable {
    
    /**
     Convert Receiver that accepts optional values into Receiver which accepts non optional values
     */
    public var unwrapped: Receiver<ValueType.Wrapped> {
        return Receiver<ValueType.Wrapped> {
            self.update(ValueType.init($0))
        }
    }
}


