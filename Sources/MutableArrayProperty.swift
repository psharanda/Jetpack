//
//  Created by Pavel Sharanda on 30.09.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation


public final class MutableArrayProperty<T>: ObservableProtocol, VariableProtocol {
    
    public var value: [T] {
        return elements
    }
    
    private let signal = Signal<([T], ArrayEditEvent)>()
    private var elements: [T]
    
    public init(_ elements: [T] = []) {
        self.elements = elements
    }
    
    public func update(at: Int, with value: T) {
        elements[at] = value
        signal.update((elements, .update(at)))
    }
    
    public func remove(at: Int) {
        elements.remove(at: at)
        signal.update((elements, .remove(at)))
    }
    
    public func append(_ newElement: T) {
        insert(newElement, at: elements.count)
    }
    
    public func insert(_ newElement: T, at: Int) {
        elements.insert(newElement, at: at)
        signal.update((elements, .insert(at)))
    }
    
    public func move(from: Int, to: Int) {
        elements.insert(elements.remove(at: from), at: to)
        signal.update((elements, .move(from, to)))
    }
    
    public func update(_ newValue: [T]) {
        elements = newValue
        signal.update((elements, .set))
    }
    
    public func subscribe(_ observer: @escaping (([T], ArrayEditEvent)) -> Void) -> Disposable {
        observer((elements, .set))
        return signal.subscribe(observer)
    }
    
    public var asProperty: Property<[T]> {
        return Property(signal.map { $0.0 }) {
            return self.value
        }
    }
    
    public var asArrayProperty: ArrayProperty<T> {
        return ArrayProperty(signal.asObservable) {
            return self.value
        }
    }
}

