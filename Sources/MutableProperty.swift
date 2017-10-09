//
//  Created by Pavel Sharanda on 16.02.17.
//  Copyright © 2017. All rights reserved.
//

import Foundation

/**
 Standalone reactive state
 */
public struct MutableProperty<T>: PropertyProtocol, VariableProtocol {
    
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
    
    public func map<U>(transform: @escaping (T) -> U, reduce: @escaping (T, U) -> T) -> MutableProperty<U> {
        let p: Property<U> = property.map(transform)
        let v: Receiver<U> = receiver.map(getter: { self.value }, reduce: reduce)
        return MutableProperty<U>(property: p, receiver: v)
    }
}
