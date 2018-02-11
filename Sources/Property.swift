//
//  Created by Pavel Sharanda on 16.02.17.
//  Copyright © 2017. All rights reserved.
//

import Foundation

public protocol PropertyProtocol: ObservableProtocol , GetValueProtocol { }

/// Wrapper around some state which provides interface for observing state changes. state always exist and always has some value ('get/subscribe')
public final class Property<T>: PropertyProtocol {
    
    private let observable: Observable<T>
    private let getter: ()->T
    
    public var value: T {
        return getter()
    }
    
    public init(_ observable: Observable<T>, getter: @escaping ()->T) {
        self.getter = getter
        self.observable = observable
    }
    
    public convenience  init(constant: T) {
        self.init(Observable.from(constant), getter: { constant })
    }
    
    @discardableResult
    public func subscribe(_ observer: @escaping (T) -> Void) -> Disposable {
        observer(value)
        return self.observable.subscribe(observer)
    }
}

extension Property {
    
    public func map<U>(_ transform: @escaping (T) -> U) -> Property<U> {
        return Property<U>(observable.map(transform)) {
            transform(self.value)
        }
    }
    
    public func map<U>(keyPath: KeyPath<T, U>) -> Property<U> {
        return map { $0[keyPath: keyPath] }
    }
}
