//
//  Created by Pavel Sharanda on 16.02.17.
//  Copyright © 2017. All rights reserved.
//

import Foundation

/**
 Object which holds and manages subscribers and can broadcast values to them
 */
public final class Signal<T>: Observable, Bindable {
    
    public typealias ValueType = T
    
    private var observers: [TaggedObserver<T>] = []
    
    private var lastToken: UInt = 0
    
    public init() {
    }
    
    @discardableResult
    public func subscribe(_ observer: @escaping (T) -> Void) -> Disposable {
        lastToken += 1
        
        let token = lastToken
        observers.append(TaggedObserver<T>(token: token, observer: observer))
        
        return DelegateDisposable { [weak self] in
            self?.unsubscribe(token)
        }
    }
    
    public func update(_ newValue: T) {
        observers.forEach {
            $0.observer(newValue)
        }
    }
    
    private func unsubscribe(_ token: UInt) {
        guard let idx = (observers.index { $0.token == token }) else {
            return
        }
        
        observers.remove(at: idx)
    }
}

private struct TaggedObserver<T> {
    let token: UInt
    let observer: (T)->Void
}

extension Signal {
    public var asReceiver: Receiver<ValueType> {
        return Receiver {
            self.update($0)
        }
    }
}

