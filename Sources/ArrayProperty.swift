//
//  ArrayProperty.swift
//  Jetpack
//
//  Created by Pavel Sharanda on 30.09.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation

public enum ArrayEditEvent {
    case set
    case remove(Int)
    case insert(Int)
    case move(Int, Int)
    case update(Int)
}

public struct ArrayProperty<T>: ObservableProtocol, GetValueProtocol  {
    
    private let observable: Observable<([T], ArrayEditEvent)>
    private let getter: ()->[T]
    
    public var value: [T] {
        return getter()
    }
    
    public init(_ observable: Observable<([T], ArrayEditEvent)>, getter: @escaping ()->[T]) {
        self.getter = getter
        self.observable = observable
    }
    
    public init(constant: [T]) {
        self.init(Observable.from((constant, .set)), getter: { constant })
    }
    
    public func subscribe(_ observer: @escaping (([T], ArrayEditEvent)) -> Void) -> Disposable {
        observer((value, .set))
        return observable.subscribe(observer)
    }
    
    public var asProperty: Property<[T]> {
        return Property(observable.map { $0.0 }) {
            return self.value
        }
    }
}

