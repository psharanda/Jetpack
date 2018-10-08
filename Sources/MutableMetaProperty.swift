//
//  Created by Pavel Sharanda on 08.10.2018.
//  Copyright © 2018 Jetpack. All rights reserved.
//

import Foundation

open class MutableMetaProperty<T, Event: ChangeEventProtocol>: ObservableProtocol, UpdateValueProtocol, GetValueProtocol {
    
    public var value: T {
        get {
            return _value
        }
        set {
            update(newValue)
        }
    }
    
    private let signal = Signal<(T, Event)>()
    private var _value: T
    
    public init(_ value: T) {
        self._value = value
    }
    
    public func update(_ newValue: T) {
        _value = newValue
        signal.update((_value, .resetEvent))
    }
    
    @discardableResult
    public func subscribe(_ observer: @escaping ((T, Event)) -> Void) -> Disposable {
        observer((_value, .resetEvent))
        return signal.subscribe(observer)
    }
    
    public var asProperty: Property<T> {
        return Property(asObservable.map { $0.0 }) {
            return self.value
        }
    }
    
    public var asMutableProperty: MutableProperty<T> {
        return MutableProperty(property: asProperty, receiver: asReceiver)
    }
    
    public var asMetaProperty: MetaProperty<T, Event> {
        return MetaProperty(asObservable) {
            return self.value
        }
    }
    
    public func changeWithEvent(_ handler: (inout T)-> Event) {
        let event = handler(&_value)
        signal.update((_value, event))
    }
}
