//
//  Created by Pavel Sharanda
//  Copyright (c) 2016. All rights reserved.
//

import Foundation

public protocol Disposable {
    func dispose()
}

public protocol Observable {
    associatedtype ValueType
    func subscribe(_ observer: @escaping (ValueType) -> Void) -> Disposable
}

/**
 Type erased observable
 */
public struct AnyObservable<T>: Observable {
    public typealias ValueType = T
    
    private let observable: (@escaping (T) -> Void) -> Disposable
    
    public init<R: Observable>(observable: R) where R.ValueType == T {
        self.observable = {
            observable.subscribe($0)
        }
    }
    
    public func subscribe(_ observer: @escaping (T) -> Void) -> Disposable {
        return observable(observer)
    }
}

extension Observable{
    var anyObservable: AnyObservable<ValueType> {
        return AnyObservable(observable: self)
    }
}
