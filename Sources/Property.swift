//
//  Created by Pavel Sharanda on 16.02.17.
//  Copyright © 2017. All rights reserved.
//

import Foundation

/**
 Wrapper around some state which provides interface for observing state changes. state always exist and always has some value
 */
public final class Property<T>: Observable {
    public typealias ValueType = T
    
    private let observer: Observer<T>
    private let getter: ()->T
    
    public var value: T {
        return getter()
    }
    
    public init(_ observer: Observer<T>, getter: @escaping ()->T) {
        self.getter = getter
        self.observer = observer
    }
    
    public convenience init(constant: T) {
        self.init(Observer.from(constant), getter: { constant })
    }
    
    public func subscribe(_ observer: @escaping (T) -> Void) -> Disposable {
        observer(value)
        return self.observer.subscribe(observer)
    }
    
    public func map<U>(_ transform: @escaping (T) -> U) -> Property<U> {
        return Property<U>(observer.map(transform)) {
            transform(self.getter())
        }
    }
}


