//
//  Created by Pavel Sharanda on 9/13/19.
//  Copyright © 2019 Jetpack. All rights reserved.
//

import Foundation

@propertyWrapper
public struct Reactive<T> {
    
    public let mutableProperty: MutableProperty<T>

    public init(wrappedValue: T) {
        mutableProperty = MutableProperty(wrappedValue)
    }
    
    public var wrappedValue: T {
        nonmutating set {
            mutableProperty.value = newValue
        }
        get {
            mutableProperty.value
        }
    }
    
    public var projectedValue: Property<T> {
        mutating get {
            return mutableProperty.asProperty
        }
    }
}

@propertyWrapper
public struct ReactiveArray<T> {
    
    public let mutableArrayProperty: MutableArrayProperty<T>

    public init(wrappedValue: [T]) {
        mutableArrayProperty = MutableArrayProperty(wrappedValue)
    }
    
    public var wrappedValue: [T] {
        nonmutating set {
            mutableArrayProperty.value = newValue
        }
        get {
            mutableArrayProperty.value
        }
    }
    
    public var projectedValue: ArrayProperty<T> {
        mutating get {
            return mutableArrayProperty.asMetaProperty
        }
    }
}

@propertyWrapper
public struct ReactiveArray2D<T> {
    
    public let mutableArray2DProperty: MutableArray2DProperty<T>
    
    public init(wrappedValue: [[T]]) {
        mutableArray2DProperty = MutableArray2DProperty(wrappedValue)
    }
    
    public var wrappedValue: [[T]] {
        nonmutating set {
            mutableArray2DProperty.value = newValue
        }
        get {
            mutableArray2DProperty.value
        }
    }
    
    public var projectedValue: Array2DProperty<T> {
        mutating get {
            return mutableArray2DProperty.asMetaProperty
        }
    }
}

@propertyWrapper
public struct Subject<T> {
    
    public let publishSubject = PublishSubject<T>()
    
    public init() { }
    
    public var wrappedValue: Observable<T> {
        get {
            return publishSubject.asObservable
        }
    }
    
    public var projectedValue: Observable<T> {
        get {
            return wrappedValue
        }
    }
    
    public func update(_ newValue: T) {
        publishSubject.update(newValue)
    }
}

extension Subject where T == Void {
    
    public func update() {
        publishSubject.update(())
    }
}
