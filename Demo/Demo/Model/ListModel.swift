//
//  ListModel.swift
//  Demo
//
//  Created by Pavel Sharanda on 29.09.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation
import Jetpack

struct Item: Codable, Equatable {
    let id: String
    var title: String
    var completed: Bool
}

class ListModel {
    
    var undoEnabled: Property<Bool> {
        return _undoStack.asProperty.map { $0.count > 1 }
    }
    
    private let _undoStack: MutableArrayProperty<[Item]>
    
    var items: ArrayProperty<Item> {
        return _items.asMetaProperty
    }
    
    private let _items: MutableArrayProperty<Item>
    
    init(items: [Item]) {
        _items = MutableArrayProperty(items)
        _undoStack = MutableArrayProperty([_items.value])
    }
    
    //MARK: Store API
    
    func appendItem(_ newItem: Item) {
        _items.append(newItem)
        _undoStack.append(_items.value)
    }
    
    func removeItem(at: Int) {
        _items.remove(at: at)
        _undoStack.append(_items.value)
    }
    
    func toggleItem(at: Int) {
        var item = _items.value[at]
        item.completed = !item.completed
        _items.update(at: at, with: item)
        _undoStack.append(_items.value)
    }
    
    func moveItem(from: Int, to: Int) {
        _items.move(from: from, to: to)
        _undoStack.append(_items.value)
    }
    
    func clean() {
        _items.update([])
        _undoStack.append(_items.value)
    }
    
    func undo() {
        if _undoStack.value.count > 1 {
            _undoStack.remove(at: _undoStack.value.count - 1)
            _items.update(_undoStack.value[_undoStack.value.count - 1])
        }
    }
}
