//
//  Created by Pavel Sharanda on 16.02.17.
//  Copyright © 2017. All rights reserved.
//

import Foundation

/**
 Wrapper around some state which provides interface for observing state changes. state always exist and always has some value
 */
public struct Property<T>: ObservableProtocol {
    
    private let observable: Observable<T>
    private let getter: ()->T
    
    public var value: T {
        return getter()
    }
    
    public init(_ observer: Observable<T>, getter: @escaping ()->T) {
        self.getter = getter
        self.observable = observer
    }
    
    public init(constant: T) {
        self.init(Observable.from(constant), getter: { constant })
    }
    
    public func subscribe(_ observer: @escaping (T) -> Void) -> Disposable {
        observer(value)
        return self.observable.subscribe(observer)
    }
    
    public func map<U>(_ transform: @escaping (T) -> U) -> Property<U> {
        return Property<U>(observable.map(transform)) {
            transform(self.getter())
        }
    }
}


