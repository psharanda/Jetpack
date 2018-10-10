//
//  Created by Pavel Sharanda on 08.10.2018.
//  Copyright © 2018 Jetpack. All rights reserved.
//

import Foundation

/// Basically the same as subject, but replays during subscription last values if there are any of them ('set/subscribe')
public final class ReplaySubject<T>: ObservableProtocol, UpdateValueProtocol {
    public let bufferSize: Int
    
    private(set) var buffer = [T]()
    
    public var lastValue: T? {
        return buffer.last
    }
    
    private let subject = PublishSubject<T>()
    
    public init(bufferSize: Int = 1) {
        self.bufferSize = bufferSize
    }
    
    @discardableResult
    public func subscribe(_ observer: @escaping (T) -> Void) -> Disposable {
        buffer.forEach {
            observer($0)
        }
        return subject.subscribe(observer)
    }
    
    public func update(_ newValue: T) {
        buffer.append(newValue)
        if buffer.count > bufferSize {
            buffer.removeFirst()
        }
        subject.update(newValue)
    }
}
