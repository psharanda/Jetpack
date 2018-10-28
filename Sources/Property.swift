//
//  Created by Pavel Sharanda on 16.02.17.
//  Copyright © 2017. All rights reserved.
//

import Foundation

/// Wrapper around some state which provides interface for observing state changes. state always exist and always has some value ('get/subscribe')
public final class Property<T>: ObservableProtocol , GetValueProtocol {
    
    private let observable: Observable<T>
    private let getter: ()->T
    
    public var value: T {
        return getter()
    }
    
    init(observable: Observable<T>, getter: @escaping ()->T) {
        self.getter = getter
        self.observable = observable
    }
    
    @discardableResult
    public func subscribe(_ observer: @escaping (T) -> Void) -> Disposable {
        observer(value)
        return self.observable.subscribe(observer)
    }
}

extension Property {
    
    public static func just(_ value: T) -> Property<T> {
        return Property(observable: Observable.just(value), getter: { value })
    }
    
    public func map<U>(_ transform: @escaping (T) -> U) -> Property<U> {
        return Property<U>(observable: observable.map(transform)) {
            transform(self.value)
        }
    }
    
    public func map<U>(keyPath: KeyPath<T, U>) -> Property<U> {
        return map { $0[keyPath: keyPath] }
    }
}
