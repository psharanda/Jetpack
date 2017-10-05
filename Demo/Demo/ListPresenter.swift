//
//  Created by Pavel Sharanda on 29.09.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation
import Jetpack

class ListPresenter {
    
    unowned let view: ListViewProtocol
    let storeItems: MutableArrayProperty<Item>
    
    private var undoStack = [[Item]]() {
        didSet {
            updateUndoStack()
        }
    }
    
    private func updateUndoStack() {
        view.undoEnabled = undoStack.count > 1
    }
    
    deinit {
        print("deinit")
    }
    
    private let apool = AutodisposePool()
    
    init(view: ListViewProtocol, storeItems: MutableArrayProperty<Item> ) {
        self.view = view
        self.storeItems = storeItems
        
        undoStack.append(storeItems.value)
        
        updateUndoStack()
        
        storeItems
            .bind(view.items)
            .autodispose(in: apool)
        
        _ = view.didAdd
            .subscribe {
                let item = Item(id: UUID().uuidString, title: $0, completed: false)
                self.storeItems.append(item)
                self.undoStack.append(self.storeItems.value)
            }
        
        _ = view.didToggle
            .subscribe {
                var item = self.storeItems.value[$0.0]
                item.completed = $0.1
                self.storeItems.update(at: $0.0, with: item)
                self.undoStack.append(self.storeItems.value)
            }
        
        _ = view.didDelete
            .subscribe {
                self.storeItems.remove(at: $0)
                self.undoStack.append(self.storeItems.value)
            }
        
        _ = view.didMove
            .subscribe {
                self.storeItems.move(from: $0.0, to: $0.1)
                self.undoStack.append(self.storeItems.value)
            }
        
        _ = view.didClean
            .subscribe {
                self.storeItems.update([])
                self.undoStack.append(self.storeItems.value)
            }
        
        _ = view.didUndo
            .subscribe {
                if self.undoStack.count > 1 {
                    self.undoStack.removeLast()
                    self.storeItems.update(self.undoStack[self.undoStack.count - 1])
                }
            }
    }

}
