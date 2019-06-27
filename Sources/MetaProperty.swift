//
//  Created by Pavel Sharanda on 08.10.2018.
//  Copyright © 2018 Jetpack. All rights reserved.
//

import Foundation

public protocol ChangeEventProtocol {
    static var resetEvent: Self {get}
}

public final class MetaProperty<T, Event: ChangeEventProtocol>: ObservableProtocol, GetValueProtocol {
    private let observable: Observable<(T, Event)>
    private let getter: ()->T

    public var value: T {
        return getter()
    }

    init(observable: Observable<(T, Event)>, getter: @escaping ()->T) {
        self.getter = getter
        self.observable = observable
    }

    @discardableResult
    public func subscribe(_ observer: @escaping ((T, Event)) -> Void) -> Disposable {
        observer((value, .resetEvent))
        return observable.subscribe(observer)
    }

    public var asProperty: Property<T> {
        return Property(observable: observable.map { $0.0 }) {
            return self.value
        }
    }
}

extension MetaProperty {
    public static func just(_ value: T) -> MetaProperty<T, Event> {
        return MetaProperty(observable: Observable.just((value, .resetEvent)), getter: { value })
    }
}
