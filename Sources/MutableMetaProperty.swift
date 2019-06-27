//
//  Created by Pavel Sharanda on 08.10.2018.
//  Copyright © 2018 Jetpack. All rights reserved.
//

import Foundation

open class MutableMetaProperty<T, Event: ChangeEventProtocol>: ObservableProtocol, UpdateValueProtocol, GetValueProtocol {

    public var value: T {
        get {
            return property.value
        }
        set {
            update(newValue)
        }
    }

    private let property: MetaProperty<T, Event>
    private let setter:  (T, Event)->Void

    public init(_ value: T) {

        let subject = PublishSubject<(T, Event)>()
        var v = value

        property = MetaProperty(observable: subject.asObservable) {
            return v
        }
        setter = {
            v = $0
            subject.update((v, $1))
        }
    }

    public func update(_ newValue: T) {
        setter(newValue, .resetEvent)
    }

    @discardableResult
    public func subscribe(_ observer: @escaping ((T, Event)) -> Void) -> Disposable {
        return property.subscribe(observer)
    }

    public var asProperty: Property<T> {
        return property.asProperty
    }

    public var asMutableProperty: MutableProperty<T> {
        return MutableProperty(property: asProperty) {
            self.update($0)
        }
    }

    public var asMetaProperty: MetaProperty<T, Event> {
        return property
    }

    public func changeWithEvent(_ handler: (inout T)-> Event) {
        var v = value
        let event = handler(&v)
        setter(v, event)
    }
}
