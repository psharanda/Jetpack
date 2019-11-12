//
//  Created by Pavel Sharanda on 16.02.17.
//  Copyright © 2017. All rights reserved.
//

import Foundation

/// Wrapper around some state which provides interface for observing state changes. state always exists and always has some value ('get/subscribe')
public final class Property<T>: ObserveValueProtocol , GetValueProtocol {
    
    private let observable: Observable<T>
    private let getter: ()->T
    
    public var value: T {
        return getter()
    }
    
    init(observable: Observable<T>, getter: @escaping ()->T) {
        self.getter = getter
        self.observable = observable
    }
    
    public init(observable: Observable<T>, initialValue: T) {
        
        var value = initialValue
        
        self.getter = {
            return value
        }
        self.observable = observable.forEach {
            value = $0
        }
    }
    
    public func subscribe(_ observer: @escaping (T) -> Void) -> Disposable {
        return observable.subscribe(observer)
    }
    
    public func map<U>(_ transform: @escaping (ValueType)-> U) -> Property<U> {
        return Property<U>(observable: map(transform)) {
            return transform(self.getter())
        }
    }
    
    public func map<U>(keyPath: KeyPath<ValueType, U>) -> Property<U> {
        return map { $0[keyPath: keyPath] }
    }
    
    public func compactMap<U>(_ transform: @escaping (T)-> U?) -> Property<U?> {
        return Property<U?>(observable: compactMap(transform).map { Optional.some($0) }, initialValue: transform(value))
    }
    
    public func filter(_ isIncluded: @escaping (T) -> Bool) -> Property<T?> {
        return Property<T?>(observable: filter(isIncluded).map { Optional.some($0) }, initialValue: isIncluded(value) ? value : nil)
    }
    
    public func distinctUntilChanged(_ isEqual: @escaping (T, T) -> Bool) -> Property<T> {
        return Property(observable: observable.distinctUntilChanged(isEqual) , getter: getter)
    }
}

extension Property where T: Equatable {
    
    public var distinctUntilChanged: Property<T> {
        return Property(observable: observable.distinctUntilChanged, getter: getter)
    }
}

