//
//  Created by Pavel Sharanda on 16.02.17.
//  Copyright © 2017. All rights reserved.
//

import Foundation

/**
 Object which holds and manages subscribers and can broadcast values to them
 */
public final class Signal<T>: ObservableProtocol, UpdateValueProtocol {
  
    private let observable: Observable<T>
    private let receiver: Receiver<T>
    
    public init() {
        var observers: [TaggedObserver<T>] = []
        var lastToken: UInt = 0
        
        observable = Observable { observer in
            lastToken += 1
            
            let token = lastToken
            observers.append(TaggedObserver<T>(token: token, observer: observer))
            
            return DelegateDisposable {
                guard let idx = (observers.index { $0.token == token }) else {
                    return
                }
                
                observers.remove(at: idx)
            }
        }
        
        receiver = Receiver { newValue in
            observers.forEach {
                $0.observer(newValue)
            }
        }
    }
    
    public func update(_ newValue: T) {
        receiver.update(newValue)
    }
    
    @discardableResult
    public func subscribe(_ observer: @escaping (T) -> Void) -> Disposable {
        return observable.subscribe(observer)
    }
}

private struct TaggedObserver<T> {
    let token: UInt
    let observer: (T)->Void
}

