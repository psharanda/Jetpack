//
//  Created by Pavel Sharanda on 16.02.17.
//  Copyright © 2017. All rights reserved.
//

import Foundation

/**
 Wrapper around some state which provides interface for binding
 */
public final class Receiver<T>: UpdateValueProtocol {

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
    
    public func map<U>(keyPath: KeyPath<U, UpdateValueType>) -> Receiver<U> {
        return map { $0[keyPath: keyPath] }
    }
}

extension Receiver where T: Optionable {
    
    /**
     Convert Receiver that accepts optional values into Receiver which accepts non optional values
     */
    public var unwrapped: Receiver<T.Wrapped> {
        return Receiver<T.Wrapped> {
            self.update(T($0))
        }
    }
}

extension UpdateValueProtocol {
    public var asReceiver: Receiver<UpdateValueType> {
        return Receiver {
            self.update($0)
        }
    }
}

