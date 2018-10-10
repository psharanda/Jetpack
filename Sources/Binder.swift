//
//  Created by Pavel Sharanda on 16.02.17.
//  Copyright © 2017. All rights reserved.
//

import Foundation

/// Wrapper around setter ('set')
public final class Binder<T>: UpdateValueProtocol {

    private let setter: (T)->Void
    
    public init(setter: @escaping (T)->Void) {
        self.setter = setter
    }
    
    public func update(_ newValue: T) {
        setter(newValue)
    }
}

extension Binder {
    public func map<U>(_ transform: @escaping (U) -> T) -> Binder<U> {
        return Binder<U> {
            self.update(transform($0))
        }
    }
    
    public func map<U>(keyPath: KeyPath<U, UpdateValueType>) -> Binder<U> {
        return map { $0[keyPath: keyPath] }
    }
}

extension Binder where T: Optionable {
    
    /**
     Convert Binder that accepts optional values into Binder which accepts non optional values
     */
    public var unwrapped: Binder<T.Wrapped> {
        return Binder<T.Wrapped> {
            self.update(T($0))
        }
    }
}

extension UpdateValueProtocol {
    public var asBinder: Binder<UpdateValueType> {
        return Binder {
            self.update($0)
        }
    }
}

