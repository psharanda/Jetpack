//
//  Created by Pavel Sharanda on 16.02.17.
//  Copyright © 2017. All rights reserved.
//

import Foundation

/// Wrapper around some mutable value. ('set/get/subscribe')
public final class MutableProperty<T>: PropertyProtocol, VariableProtocol {
    
    public var value: T {
        get {
            return property.value
        }
        set {
            receiver.update(newValue)
        }
    }
    
    private let property: Property<T>
    private let receiver: Receiver<T>
    
    public init(_ value: T) {
        
        let signal = Signal<T>()
        var v = value
        
        property = Property(signal.asObservable) {
            return v
        }
        receiver = Receiver  {
            v = $0
            signal.update(v)
        }
    }
    
    public init(property: Property<T>, receiver: Receiver<T>) {
        self.property = property
        self.receiver = receiver
    }
    
    public init(getter: @escaping ()->T, setter: @escaping (T)->Void) {
        let signal = Signal<T>()
        property = Property(signal.asObservable, getter: getter)
        receiver = Receiver  {
            setter($0)
            signal.update($0)
        }
    }
    
    @discardableResult
    public func subscribe(_ observer: @escaping (T) -> Void) -> Disposable {
        return property.subscribe(observer)
    }
    
    public func update(_ newValue: T) {
        receiver.update(newValue)
    }
    
    public var asProperty: Property<ValueType> {
        return property
    }
}

extension MutableProperty {
    
    public func map<U>(transform: @escaping (T) -> U, reduce: @escaping (T, U) -> T) -> MutableProperty<U> {
        let p = property.map(transform)
        let r = Receiver<U> { self.update(reduce(self.value, $0)) }
        return MutableProperty<U>(property: p, receiver: r)
    }
    
    public func map<U>(keyPath: WritableKeyPath<T, U>) -> MutableProperty<U> {
        let p = property.map(keyPath: keyPath)
        let r = Receiver<U> {
            var newValue = self.value
            newValue[keyPath: keyPath] = $0
            self.update(newValue)
        }
        return MutableProperty<U>(property: p, receiver: r)
    }
}
