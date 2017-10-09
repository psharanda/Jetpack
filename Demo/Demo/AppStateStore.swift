//
//  AppStateStore.swift
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



class AppStateStore {
    
    let undoStack: MutableArrayProperty<[Item]>
    
    let items: MutableArrayProperty<Item>
    
    let filter: MutableProperty<VisibilityFilter>
    
    init() {
        let state = AppStateStore.loadState() ?? AppState()
        
        items = MutableArrayProperty(state.items)
        filter = MutableProperty(state.filter)
        undoStack = MutableArrayProperty([items.value])        
        
        items.asProperty.combineLatest(filter).subscribe {
            let appState = AppState(items: $0.0, filter: $0.1)
            AppStateStore.saveState(appState)
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
