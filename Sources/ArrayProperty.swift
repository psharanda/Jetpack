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

/// Wrapper around some array which provides interface for observing changes. Items always exist ('get/subscribe')
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
    
    @discardableResult
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

public enum Array2DEditEvent {
    case set
    case removeItem(IndexPath)
    case insertItem(IndexPath)
    case moveItem(IndexPath, IndexPath)
    case updateItem(IndexPath)
    
    case removeSection(Int)
    case insertSection(Int)
    case moveSection(Int, Int)
    case updateSection(Int)
}

/// Wrapper around some 2D array (array of arrays) which provides interface for observing changes. Items always exist ('get/subscribe')
public struct Array2DProperty<T>: ObservableProtocol, GetValueProtocol  {
    
    private let observable: Observable<([[T]], Array2DEditEvent)>
    private let getter: ()->[[T]]
    
    public var value: [[T]] {
        return getter()
    }
    
    public init(_ observable: Observable<([[T]], Array2DEditEvent)>, getter: @escaping ()->[[T]]) {
        self.getter = getter
        self.observable = observable
    }
    
    public init(constant: [[T]]) {
        self.init(Observable.from((constant, .set)), getter: { constant })
    }
    
    @discardableResult
    public func subscribe(_ observer: @escaping (([[T]], Array2DEditEvent)) -> Void) -> Disposable {
        observer((value, .set))
        return observable.subscribe(observer)
    }
    
    public var asProperty: Property<[[T]]> {
        return Property(observable.map { $0.0 }) {
            return self.value
        }
    }
}


