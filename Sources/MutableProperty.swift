//
//  Created by Pavel Sharanda on 16.02.17.
//  Copyright © 2017. All rights reserved.
//

import Foundation

/// Wrapper around some mutable value. ('set/get/subscribe')
public final class MutableProperty<T>: ObservableProtocol, GetValueProtocol, UpdateValueProtocol {
    
    public var value: T {
        get {
            return property.value
        }
        set {
            setter(newValue)
        }
    }
    
    private let property: Property<T>
    private let setter:  (T)->Void
    
    public init(_ value: T) {
        
        let subject = PublishSubject<T>()
        var v = value
        
        property = Property(observable: subject.asObservable) {
            return v
        }
        setter = {
            v = $0
            subject.update(v)
        }
    }
    
    init(property: Property<T>, setter: @escaping (T)->Void) {
        self.property = property
        self.setter = setter
    }
    
    @discardableResult
    public func subscribe(_ observer: @escaping (T) -> Void) -> Disposable {
        return property.subscribe(observer)
    }
    
    public func update(_ newValue: T) {
        setter(newValue)
    }
    
    public var asProperty: Property<ValueType> {
        return property
    }
}

extension MutableProperty {
    
    public func map<U>(transform: @escaping (T) -> U, reduce: @escaping (T, U) -> T) -> MutableProperty<U> {
        let p = property.map(transform)
        return MutableProperty<U>(property: p) {
            self.update(reduce(self.value, $0))
        }
    }
    
    public func map<U>(keyPath: WritableKeyPath<T, U>) -> MutableProperty<U> {
        let p = property.map(keyPath: keyPath)
        return MutableProperty<U>(property: p) {
            var newValue = self.value
            newValue[keyPath: keyPath] = $0
            self.update(newValue)
        }
    }
}
