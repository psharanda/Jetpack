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

public final class MutableArray2DProperty<T>: ObservableProtocol, VariableProtocol {
    
    public var value: [[T]] {
        return elements
    }
    
    private let signal = Signal<([[T]], Array2DEditEvent)>()
    private var elements: [[T]]
    
    public init(_ elements: [[T]] = []) {
        self.elements = elements
    }
    
    public func updateSection(at: Int, with value: [T]) {
        elements[at] = value
        signal.update((elements, .updateSection(at)))
    }
    
    public func removeSection(at: Int) {
        elements.remove(at: at)
        signal.update((elements, .removeSection(at)))
    }
    
    public func insertSection(_ newElement: [T], at: Int) {
        elements.insert(newElement, at: at)
        signal.update((elements, .insertSection(at)))
    }
    
    public func moveSection(from: Int, to: Int) {
        elements.insert(elements.remove(at: from), at: to)
        signal.update((elements, .moveSection(from, to)))
    }
    
    public func updateItem(at: IndexPath, with value: T) {
        elements[at.section][at.item] = value
        signal.update((elements, .updateItem(at)))
    }
    
    public func removeItem(at: IndexPath) {
        elements[at.section].remove(at: at.row)
        signal.update((elements, .removeItem(at)))
    }
    
    public func insertItem(_ newElement: T, at: IndexPath) {
        elements[at.section].insert(newElement, at: at.row)
        signal.update((elements, .insertItem(at)))
    }
    
    public func moveItem(from: IndexPath, to: IndexPath) {
        elements[to.section].insert(elements[from.section].remove(at: from.row), at: to.row)
        signal.update((elements, .moveItem(from, to)))
    }
    
    public func update(_ newValue: [[T]]) {
        elements = newValue
        signal.update((elements, .set))
    }
    
    public func subscribe(_ observer: @escaping (([[T]], Array2DEditEvent)) -> Void) -> Disposable {
        observer((elements, .set))
        return signal.subscribe(observer)
    }
    
    public var asProperty: Property<[[T]]> {
        return Property(signal.map { $0.0 }) {
            return self.value
        }
    }
    
    public var asArrayProperty: Array2DProperty<T> {
        return Array2DProperty(signal.asObservable) {
            return self.value
        }
    }
}

