//
//  ListModel.swift
//  Demo
//
//  Created by Pavel Sharanda on 29.09.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation
import Jetpack




enum VisibilityFilter: String, Codable {
    case all
    case notCompleted
    case completed
}

struct Item: Codable, Equatable {
    static func ==(lhs: Item, rhs: Item) -> Bool {
        return (lhs.id == rhs.id) && (lhs.title == rhs.title) && (lhs.completed == rhs.completed)
    }
    let id: String
    var title: String
    var completed: Bool
}

class ListModel {
    
    var undoStack: ArrayProperty<[Item]> {
        return _undoStack.asArrayProperty
    }
    
    private let _undoStack: MutableArrayProperty<[Item]>
    
    var items: ArrayProperty<Item> {
        return _items.asArrayProperty
    }
    
    private let _items: MutableArrayProperty<Item>
    
    var filter: Property<VisibilityFilter> {
        return _filter.asProperty
    }
    
    private let _filter: MutableProperty<VisibilityFilter>
    
    init() {
        let state = ListModel.loadState() ?? AppState()
        
        _items = MutableArrayProperty(state.items)
        _filter = MutableProperty(state.filter)
        _undoStack = MutableArrayProperty([_items.value])
        
        _items.asProperty.combineLatest(_filter).subscribe {
            let appState = AppState(items: $0.0, filter: $0.1)
            ListModel.saveState(appState)
        }
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
    
    //MARK: - persistent state storage
    
    struct AppState: Codable {
        var items: [Item]
        var filter: VisibilityFilter
        
        init(items: [Item], filter: VisibilityFilter) {
            self.items = items
            self.filter = filter
        }
        
        init() {
            items = []
            filter = .all
        }
    }
    
    private static func stateFilePath() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last?.appendingPathComponent("state.json")
    }
    
    private static func loadState() -> AppState? {
        
        if let path = stateFilePath(), let data = try? Data(contentsOf: path) {
            return try? JSONDecoder().decode(AppState.self, from: data)
        }
        return nil
    }
    
    private static func saveState(_ state: AppState) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        if let path = stateFilePath(), let data = try? encoder.encode(state) {
            try? data.write(to: path)
        }
    }
}
