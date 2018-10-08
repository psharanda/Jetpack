//
//  Created by Pavel Sharanda on 08.10.2018.
//  Copyright © 2018 Jetpack. All rights reserved.
//

import Foundation

/// Basically the same as signal, but replays during subscription last values if there are any of them ('set/subscribe')
public final class Replayer<T>: ObservableProtocol, UpdateValueProtocol {
    private let bufferSize: Int
    
    private(set) var buffer = [T]()
    
    public var lastValue: T? {
        return buffer.last
    }
    
    private let signal = Signal<T>()
    
    public init(bufferSize: Int = 1) {
        self.bufferSize = bufferSize
    }
    
    @discardableResult
    public func subscribe(_ observer: @escaping (T) -> Void) -> Disposable {
        buffer.forEach {
            observer($0)
        }
        return signal.subscribe(observer)
    }
    
    public func update(_ newValue: T) {
        buffer.append(newValue)
        if buffer.count > bufferSize {
            buffer.removeFirst()
        }
        signal.update(newValue)
    }
}
