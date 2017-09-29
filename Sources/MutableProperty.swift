//
//  Created by Pavel Sharanda on 16.02.17.
//  Copyright © 2017. All rights reserved.
//

import Foundation

/**
 Standalone reactive state
 */
public struct MutableProperty<T>: ObservableProtocol, Bindable {
    
    public var value: T {
        return property.value
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
    
    private init(property: Property<T>, receiver: Receiver<T>) {
        self.property = property
        self.receiver = receiver
    }
    
    public func subscribe(_ observer: @escaping (T) -> Void) -> Disposable {
        return property.subscribe(observer)
    }
    
    public func update(_ newValue: T) {
        receiver.update(newValue)
    }
    
    public var asReceiver: Receiver<T> {
        return receiver
    }
    
    public var asProperty: Property<T> {
        return property
    }
    
    public var asVariable: Variable<T> {
        return Variable(setter: {
            self.receiver.update($0)
        }, getter: {
            return self.property.value
        })
    }
    
    public func map<U>(transform: @escaping (T) -> U, reduce: @escaping (T, U) -> T) -> MutableProperty<U> {
        let p: Property<U> = property.map(transform)
        let v: Receiver<U> = receiver.map(getter: { self.value }, reduce: reduce)
        return MutableProperty<U>(property: p, receiver: v)
    }
}




