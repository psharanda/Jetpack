//
//  Created by Pavel Sharanda on 17.04.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation

extension ObservableProtocol {

    @available(*, deprecated, renamed: "share()", message: "Please use share() instead")
    public func commit() -> (Observable<ValueType>, Disposable) {
        return share()
    }
    
    @available(*, deprecated, renamed: "share(autodisposeIn:)", message: "Please use share(autodisposeIn:) instead")
    public func commit(autodisposeIn pool: AutodisposePool) -> Observable<ValueType> {
        return share(autodisposeIn: pool)
    }
    
    public func share() -> (Observable<ValueType>, Disposable) {
        
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
    
    public func share(autodisposeIn pool: AutodisposePool) -> Observable<ValueType> {
        let (observer, d) = share()
        pool.add(d)
        return observer
    }
    
    public func share(autodisposeIn box: AutodisposeBox) -> Observable<ValueType> {
        let (observer, d) = share()
        box.put(d)
        return observer
    }
}
