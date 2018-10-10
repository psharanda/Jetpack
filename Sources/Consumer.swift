//
//  Created by Pavel Sharanda on 16.02.17.
//  Copyright © 2017. All rights reserved.
//

import Foundation

/// Wrapper around setter ('set')
public final class Consumer<T>: UpdateValueProtocol {

    private let setter: (T)->Void
    
    public init(setter: @escaping (T)->Void) {
        self.setter = setter
    }
    
    public func update(_ newValue: T) {
        setter(newValue)
    }
}

extension Consumer {
    public func map<U>(_ transform: @escaping (U) -> T) -> Consumer<U> {
        return Consumer<U> {
            self.update(transform($0))
        }
    }
    
    public func map<U>(keyPath: KeyPath<U, UpdateValueType>) -> Consumer<U> {
        return map { $0[keyPath: keyPath] }
    }
}

extension Consumer where T: Optionable {
    
    /**
     Convert Consumer that accepts optional values into Consumer which accepts non optional values
     */
    public var unwrapped: Consumer<T.Wrapped> {
        return Consumer<T.Wrapped> {
            self.update(T($0))
        }
    }
}

extension UpdateValueProtocol {
    public var asConsumer: Consumer<UpdateValueType> {
        return Consumer {
            self.update($0)
        }
    }
}

