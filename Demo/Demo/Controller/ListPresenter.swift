//
//  Created by Pavel Sharanda on 29.09.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation
import Jetpack

class ListPresenter {
    
    unowned let view: ListViewProtocol
    let model: ListModelProtocol
    
    private let apool = AutodisposePool()
    
    init(view: ListViewProtocol, model: ListModelProtocol) {
        self.view = view
        self.model = model
        
        model.undoStack
            .map { $0.0.count > 1 }
            .bind(view.undoEnabled)
            .autodispose(in: apool)
        
        model.items
            .bind(view.items)
            .autodispose(in: apool)
        
        view.didAdd.subscribe {
            let item = Item(id: UUID().uuidString, title: $0, completed: false)
            self.model.appendItem(item)
        }
        
        view.didToggle.subscribe {
            self.model.toggleItem(at: $0)
        }
        
        view.didDelete.subscribe {
            self.model.removeItem(at: $0)
        }
        
        view.didMove.subscribe {
            self.model.moveItem(from: $0, to: $1)
        }
        
        view.didClean.subscribe {
            self.model.clean()
        }
        
        view.didUndo.subscribe {
            self.model.undo()
        }
    }    
}

