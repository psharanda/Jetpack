//
//  ListPersistentStorage.swift
//  Demo
//
//  Created by Pavel Sharanda on 07.10.2018.
//  Copyright © 2018 Pavel Sharanda. All rights reserved.
//

import Foundation

class ListPersistentStorage {
    
    private struct PersistentState: Codable {
        let items: [Item]
    }
    
    private static func stateFilePath() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last?.appendingPathComponent("state.json")
    }
    
    static func load() -> [Item]? {
        
        if let path = stateFilePath(), let data = try? Data(contentsOf: path) {
            return try? JSONDecoder().decode(PersistentState.self, from: data).items
        }
        return nil
    }
    
    static func save(items: [Item]) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        if let path = stateFilePath(), let data = try? encoder.encode(PersistentState(items: items)) {
            try? data.write(to: path)
        }
    }
}
