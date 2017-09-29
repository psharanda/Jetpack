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

struct AppState: Codable {
    var items: [Item]
    var filter: VisibilityFilter
    
    init() {
        items = []
        filter = .all
    }
}

class AppStateStore {
    
    let state: MutableProperty<AppState>
    
    let itemsState: MutableProperty<[Item]>
    
    init() {        
        state = MutableProperty(AppStateStore.loadState() ?? AppState())
        
        itemsState = state
            .map(transform: {
                $0.items
            }, reduce: {
                var newState = $0
                newState.items = $1
                return newState
            })
        
        _ = state.subscribe {
            AppStateStore.saveState($0)
        }
    }
    
    //MARK: - persistent state storage
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
