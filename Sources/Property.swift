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
    
    private let signal: Signal<T>
    private let getter: ()->T
    
    public var value: T {
        return getter()
    }
    
    public init(signal: Signal<T>, getter: @escaping ()->T) {
        self.getter = getter
        self.signal = signal
    }
    
    @discardableResult
    public func subscribe(_ observer: @escaping (T) -> Void) -> Disposable {
        observer(value)
        return signal.subscribe(observer)
    }
}


