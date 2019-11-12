//
//  Created by Pavel Sharanda on 08.10.2018.
//  Copyright © 2018 Jetpack. All rights reserved.
//

import Foundation

/// Basically the same as subject, but replays during subscription last values if there are any of them ('set/subscribe')
public final class ReplaySubject<T>: ObserveValueProtocol, UpdateValueProtocol {
    
    public let bufferSize: Int
    private var _buffer = [T]()
    private let innerUnsafeSubject = UnsafeSubject<T>()
    private let lock = Lock()
    
    public init(bufferSize: Int = 1) {
        self.bufferSize = bufferSize
    }
    
    public func subscribe(_ observer: @escaping (T) -> Void) -> Disposable {
        lock.synchronized {
            _buffer.forEach {
                observer($0)
            }
            return innerUnsafeSubject.subscribe(observer).locked(with: lock)
        }
    }
    
    public func update(_ newValue: T) {
        lock.synchronized {
            _buffer.append(newValue)
            if _buffer.count > bufferSize {
                _buffer.removeFirst()
            }
            
            innerUnsafeSubject.update(newValue)
        }        
    }
}
