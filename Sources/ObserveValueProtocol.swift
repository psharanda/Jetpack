//
//  Created by Pavel Sharanda
//  Copyright (c) 2016. All rights reserved.
//

import Foundation

/// Base interface to observe value changes over time (`subscribe`)
public protocol ObserveValueProtocol {
    associatedtype ValueType
    func subscribe(_ observer: @escaping (ValueType) -> Void) -> Disposable
}

extension ObserveValueProtocol {
    public var asObservable: Observable<ValueType> {
        return Observable { observer in
            return self.subscribe(observer)
        }
    }
    
    public func asObservableWithSideEffect(_ sideEffect: @escaping () -> Void) -> Observable<ValueType> {
        return Observable { observer in
            sideEffect()
            return self.subscribe(observer)
        }
    }
}

