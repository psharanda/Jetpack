//
//  Created by Pavel Sharanda on 16.02.17.
//  Copyright © 2017. All rights reserved.
//

import Foundation


/// Object which holds and manages observers and can broadcast values to them ('set/subscribe')
public final class PublishSubject<T>: ObserveValueProtocol, UpdateValueProtocol {

    private let innerUnsafeSubject = UnsafeSubject<T>()
    private let lock = Lock()

    public init() { }
    
    public func update(_ newValue: T) {
        lock.synchronized {
            innerUnsafeSubject.update(newValue)
        }
    }
    
    public func subscribe(_ observer: @escaping (T) -> Void) -> Disposable {
        lock.synchronized {
            return innerUnsafeSubject.subscribe(observer).locked(with: lock)
        }
    }
}



