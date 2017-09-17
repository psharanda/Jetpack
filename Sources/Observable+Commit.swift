//
//  Created by Pavel Sharanda on 17.04.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation

extension ObservableProtocol {
    public func commit() -> (Observable<ValueType>, Disposable) {
        
        let signal = Signal<ValueType>()
        var immediateResult: ValueType?
        var shouldSaveImmediateResult = true
        let disposable = subscribe {result in
            if shouldSaveImmediateResult {
                immediateResult = result
            }
            signal.update(result)
        }
        
        if immediateResult != nil {
            let prop = Property<ValueType>(signal.asObservable) {
                return immediateResult!
            }
            return (prop.asObservable, disposable)
        } else {
            shouldSaveImmediateResult = false
            return (signal.asObservable, disposable)
        }
    }
    
    public func commit(autodisposeIn pool: AutodisposePool) -> Observable<ValueType> {
        let (observer, d) = commit()
        pool.add(d)
        return observer
    }
}
