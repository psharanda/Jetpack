//
//  ListPresenter.swift
//  Demo
//
//  Created by Pavel Sharanda on 29.09.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation
import Jetpack

class ListPresenter {
    
    unowned let view: ListViewProtocol
    let storeItems: MutableProperty<[Item]>
    
    private let apool = AutodisposePool()
    
    private var undoStack = [[Item]]() {
        didSet {
            updateUndoStack()
        }
    }
    
    private func updateUndoStack() {
        view.undoEnabled = undoStack.count > 1
    }
    
    init(view: ListViewProtocol, storeItems: MutableProperty<[Item]> ) {
        self.view = view
        self.storeItems = storeItems
        
        undoStack.append(storeItems.value)
        
        updateUndoStack()
        
        storeItems
            .subscribe { [weak self] in
                self?.view.items = $0
            }
            .autodispose(in: apool)
        
        view.didAdd
            .subscribe {
                var items = storeItems.value
                items.append(Item(id: UUID().uuidString, title: $0, completed: false))
                self.updateItems(items)
            }
            .autodispose(in: apool)
        
        view.didToggle
            .subscribe {
                var items = storeItems.value
                items[$0.0].completed = $0.1
                self.updateItems(items)
            }
            .autodispose(in: apool)
        
        view.didDelete
            .subscribe {
                var items = storeItems.value
                items.remove(at: $0)
                self.updateItems(items)
            }
            .autodispose(in: apool)
        
        view.didMove
            .subscribe {
                var items = storeItems.value                
                items.insert(items.remove(at: $0.0), at: $0.1)
                self.updateItems(items)
            }
            .autodispose(in: apool)
        
        view.didClean
            .subscribe {
                self.updateItems([])
            }
            .autodispose(in: apool)
        
        view.didUndo
            .subscribe {
                if self.undoStack.count > 1 {
                    self.undoStack.removeLast()
                    storeItems.update(self.undoStack[self.undoStack.count - 1])
                }
            }
            .autodispose(in: apool)
    }
    
    private func updateItems(_ items: [Item]) {
        storeItems.update(items)
        undoStack.append(items)
    }
}
