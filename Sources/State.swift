//
//  Created by Pavel Sharanda on 16.02.17.
//  Copyright © 2017. All rights reserved.
//

import Foundation

/**
 Standalone reactive state
 */
public final class State<T>: Observable, Bindable {
    public typealias ValueType = T
    
    public var value: T {
        return property.value
    }
    
    private let property: Property<T>
    private let variable: Variable<T>
    
    public init(_ value: T) {
        
        let signal = Signal<T>()
        var v = value
        
        property = Property(signal: signal) {
            return v
        }
        variable = Variable(setter: {
            v = $0
            signal.update(v)
        }, getter: {
            return v
        })
    }
    
    @discardableResult
    public func subscribe(_ observer: @escaping (T) -> Void) -> Disposable {
        return property.subscribe(observer)
    }
    
    public func update(_ newValue: T) {
        variable.update(newValue)
    }
    
    public var asReceiver: Receiver<ValueType> {
        return variable.asReceiver
    }
    
    public var asProperty: Property<ValueType> {
        return property
    }
    
    public var asVariable: Variable<ValueType> {
        return variable
    }
}




