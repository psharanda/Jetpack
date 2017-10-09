//
//  Created by Pavel Sharanda on 29.09.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation
import Jetpack

class ListPresenter {
    
    unowned let view: ListViewProtocol
    let appStateStore: AppStateStore
    
    private let apool = AutodisposePool()
    
    init(view: ListViewProtocol, appStateStore: AppStateStore) {
        self.view = view
        self.appStateStore = appStateStore
        
        appStateStore.undoStack
            .map { $0.0.count > 1 }
            .bind(view.undoEnabled)
            .autodispose(in: apool)
        
        appStateStore.items
            .bind(view.items)
            .autodispose(in: apool)
        
        view.didAdd
            .subscribe {
                let item = Item(id: UUID().uuidString, title: $0, completed: false)
                self.appStateStore.items.append(item)
                self.appStateStore.undoStack.append(self.appStateStore.items.value)
        }
        
        view.didToggle
            .subscribe {
                var item = appStateStore.items.value[$0.0]
                item.completed = $0.1
                self.appStateStore.items.update(at: $0.0, with: item)
                self.appStateStore.undoStack.append(self.appStateStore.items.value)
        }
        
        view.didDelete
            .subscribe {
                self.appStateStore.items.remove(at: $0)
                self.appStateStore.undoStack.append(self.appStateStore.items.value)
        }
        
        view.didMove
            .subscribe {
                self.appStateStore.items.move(from: $0.0, to: $0.1)
                self.appStateStore.undoStack.append(self.appStateStore.items.value)
        }
        
        view.didClean
            .subscribe {
                self.appStateStore.items.update([])
                self.appStateStore.undoStack.append(self.appStateStore.items.value)
        }
        
        view.didUndo
            .subscribe {
                if self.appStateStore.undoStack.value.count > 1 {
                    self.appStateStore.undoStack.remove(at: self.appStateStore.undoStack.value.count - 1)
                    self.appStateStore.items.update(self.appStateStore.undoStack.value[self.appStateStore.undoStack.value.count - 1])
                }
        }
    }    
}

