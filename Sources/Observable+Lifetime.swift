//
//  Created by Pavel Sharanda on 20.03.17.
//  Copyright © 2017 SnipSnap. All rights reserved.
//

import Foundation

extension Observable {
    
    @discardableResult
    public func live(with object: AnyObject) -> Observable<T> {
        let signal = Signal<T>()
        
        var token: Token = 0
        token = subscribe {[weak object, unowned self] result in
            if object != nil {
                signal.update(result)
            } else {
                self.unsubscribe(token)
            }
        }
        return signal
    }
    
    @discardableResult
    public func live<U>(until observable: Observable<U>) -> Observable<T> {
        let signal = Signal<T>()
        
        var token: Token = 0
        token = subscribe {[weak observable, unowned self] result in
            if observable != nil {
                signal.update(result)
            } else {
                self.unsubscribe(token)
            }
        }
        
        var observableToken: Token = 0
        observableToken = observable.subscribe { [weak observable, weak self] _ in
            self?.unsubscribe(token)
            observable?.unsubscribe(observableToken)
        }
        
        return signal
    }
    
}
