//
//  Created by Pavel Sharanda on 08.10.2018.
//  Copyright © 2018 Jetpack. All rights reserved.
//

import Foundation

open class MutableMetaProperty<T, Event: ChangeEventProtocol>: ObservableProtocol, UpdateValueProtocol, GetValueProtocol {
    
    public var value: T {
        get {
            return mutableProperty.value.0
        }
        set {
            update(newValue)
        }
    }

    private let mutableProperty: MutableProperty<(T, Event)>
    
    public init(_ value: T) {
        mutableProperty = MutableProperty((value, .resetEvent))
    }
    
    public func update(_ newValue: T) {
        mutableProperty.update((newValue, .resetEvent))
    }
    
    @discardableResult
    public func subscribe(_ observer: @escaping ((T, Event)) -> Void) -> Disposable {
        return mutableProperty.subscribe(observer)
    }
    
    public var asProperty: Property<T> {
        return mutableProperty.asProperty.map { $0.0 }
    }
    
    public var asMutableProperty: MutableProperty<T> {
        return mutableProperty.map(transform: {
            $0.0
        }, reduce: { lhs, _ in
            (lhs.0, .resetEvent)
        })
    }
    
    public var asMetaProperty: MetaProperty<T, Event> {
        return MetaProperty(property: mutableProperty.asProperty)
    }
    
    public func changeWithEvent(_ handler: (inout T)-> Event) {
        var v = value
        let event = handler(&v)
        mutableProperty.update((v, event))
    }
}
