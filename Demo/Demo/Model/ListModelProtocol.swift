//
//  ListModelProtocol.swift
//  Demo
//
//  Created by Pavel Sharanda on 08.11.17.
//  Copyright © 2017 Pavel Sharanda. All rights reserved.
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

protocol ListModelProtocol {
    
    var items: ArrayProperty<Item> {get}
    var undoStack: ArrayProperty<[Item]> {get}
    
    func appendItem(_ newItem: Item)
    func removeItem(at: Int)
    func toggleItem(at: Int)
    func moveItem(from: Int, to: Int)
    func clean()
    func undo()
}
