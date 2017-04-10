//
//  Created by Pavel Sharanda on 26.09.16.
//  Copyright © 2016 SnipSnap. All rights reserved.
//

import Foundation

extension MutableProperty {
    public convenience init(_ value: T, sideEffect: @escaping (T)->Void) {
        self.init(value)
        subscribe(sideEffect)
    }
}

extension Signal {
    public convenience init(sideEffect: @escaping (T)->Void) {
        self.init( )
        subscribe(sideEffect)
    }
}

extension Observable {
    @discardableResult
    public func forEach(_ f: @escaping (T) -> Void) -> Observable<T> {
        let signal = Signal<T>()
        subscribe { result in
            f(result)
            signal.update(result)
        }
        return signal
    }
}
