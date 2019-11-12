//
//  Created by Pavel Sharanda on 16.02.17.
//  Copyright © 2017. All rights reserved.
//

import Foundation

/// Wrapper around some mutable value. ('set/get/subscribe')
public final class MutableProperty<T>: ObserveValueProtocol, GetValueProtocol, UpdateValueProtocol, MutateValueProtocol {
    
    private var _value: T
    private let innerUnsafeSubject = UnsafeSubject<T>()
    private let subjectLock = Lock()
    private let valueLock = Lock()
    private let mutateLock = Lock()
    
    public init(_ value: T) {
        _value = value
    }
    
    public var value: T {
        get {
            valueLock.synchronized {
                return _value
            }
        }
        set {
            mutate { $0 = newValue }
        }
    }
    
    public func subscribe(_ observer: @escaping (T) -> Void) -> Disposable {
        subjectLock.synchronized {
            observer(_value)
            return innerUnsafeSubject.subscribe(observer).locked(with: subjectLock)
        }
    }
    
    public func update(_ newValue: T) {
        mutate { $0 = newValue }
    }
    
    public func mutate(_ transform: (inout T) -> ()) {
        mutateLock.synchronized {
            
            let newValue: T = valueLock.synchronized {
                transform(&_value)
                return _value
            }

            subjectLock.synchronized {
                innerUnsafeSubject.update(newValue)
            }
        }
    }
    
    public var asProperty: Property<ValueType> {
        return Property(observable: asObservable) { self.value }
    }

    public var asMainThreadProperty: Property<ValueType> {
        return Property(observable: dispatch(on: .main)) { self.value }
    }
}


