//
//  Created by Pavel Sharanda on 16.02.17.
//  Copyright © 2017. All rights reserved.
//

import Foundation


/// Object which holds and manages observers and can broadcast values to them ('set/subscribe')
public final class PublishSubject<T>: ObservableProtocol, UpdateValueProtocol {
  
    private let observable: Observable<T>
    private let consumer: Consumer<T>
    
    public init() {
        var observers: [Observer<T>] = []
        var lastToken: UInt = 0
        
        observable = Observable { observer in
            lastToken += 1
            
            let token = lastToken
            observers.append(Observer<T>(token: token, observer: observer))
            
            return BlockDisposable {
                guard let idx = (observers.index { $0.token == token }) else {
                    return
                }
                
                observers.remove(at: idx)
            }
        }
        
        consumer = Consumer { newValue in
            observers.forEach {
                $0.observer(newValue)
            }
        }
    }
    
    public func update(_ newValue: T) {
        consumer.update(newValue)
    }
    
    @discardableResult
    public func subscribe(_ observer: @escaping (T) -> Void) -> Disposable {
        return observable.subscribe(observer)
    }
}

private struct Observer<T> {
    let token: UInt
    let observer: (T)->Void
}

