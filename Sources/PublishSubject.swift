//
//  Created by Pavel Sharanda on 16.02.17.
//  Copyright © 2017. All rights reserved.
//

import Foundation


/// Object which holds and manages observers and can broadcast values to them ('set/subscribe')
public final class PublishSubject<T>: ObservableProtocol, UpdateValueProtocol {
  
    private var observers: [PublishSubjectObserver<T>] = []
    private var lastToken: UInt = 0
    
    public init() { }
    
    public func update(_ newValue: T) {
        observers.forEach {
            $0.observer(newValue)
        }
    }
    
    @discardableResult
    public func subscribe(_ observer: @escaping (T) -> Void) -> Disposable {
        lastToken += 1
        
        let token = lastToken
        observers.append(PublishSubjectObserver<T>(token: token, observer: observer))
        
        return BlockDisposable {
            guard let idx = (self.observers.firstIndex { $0.token == token }) else {
                return
            }
            
            self.observers.remove(at: idx)
        }
    }
}

private struct PublishSubjectObserver<T> {
    let token: UInt
    let observer: (T)->Void
}

