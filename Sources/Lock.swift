//
//  Created by Pavel Sharanda on 10/2/19.
//  Copyright © 2019 Jetpack. All rights reserved.
//

import Foundation

public final class Lock {
    private let innerLock = NSRecursiveLock()
    
    public func lock() {
        innerLock.lock()
    }

    public func unlock() {
        innerLock.unlock()
    }
    
    public func synchronized<T>(_ action: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try action()
    }
}
