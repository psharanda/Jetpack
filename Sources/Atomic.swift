//
//  Created by Pavel Sharanda on 10/29/19.
//  Copyright © 2019 Jetpack. All rights reserved.
//

import Foundation

@propertyWrapper
public struct Atomic<T> {
    
    private let queue = DispatchQueue(label: "Atomic.queue")
    
    private var _value: T

    public init(wrappedValue: T) {
        _value = wrappedValue
    }
    
    public var wrappedValue: T {
        set {
            queue.sync { self._value = newValue }
        }
        get {
            return queue.sync { self._value }
        }
    }
}
