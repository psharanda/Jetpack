//
//  Created by Pavel Sharanda on 08.10.2018.
//  Copyright © 2018 Jetpack. All rights reserved.
//

import Foundation

public protocol ChangeEventProtocol {
    static var resetEvent: Self {get}
}

public final class MetaProperty<T, Event: ChangeEventProtocol>: ObserveValueProtocol, GetValueProtocol {
    private let observable: Observable<(T, Event)>
    private let getter: () -> T

    public var value: T {
        return getter()
    }

    init(observable: Observable<(T, Event)>, getter: @escaping () -> T) {
        self.getter = getter
        self.observable = observable
    }

    public func subscribe(_ observer: @escaping ((T, Event)) -> Void) -> Disposable {
        return observable.subscribe(observer)
    }
}

