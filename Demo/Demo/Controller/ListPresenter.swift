//
//  Created by Pavel Sharanda on 29.09.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation
import Jetpack

enum ListPresenter {

    static func main(view: ListViewProtocol, model: ListModel) {
        
        model.undoStack
            .map { $0.0.count > 1 }
            .bind(view.undoEnabled)
            .autodispose(in: view.apool)
        
        model.items
            .bind(view.items)
            .autodispose(in: view.apool)
        
        view.didAdd.subscribe {
            let item = Item(id: UUID().uuidString, title: $0, completed: false)
            model.appendItem(item)
        }
        
        view.didToggle.subscribe {
            model.toggleItem(at: $0)
        }
        
        view.didDelete.subscribe {
            model.removeItem(at: $0)
        }
        
        view.didMove.subscribe {
            model.moveItem(from: $0, to: $1)
        }
        
        view.didClean.subscribe {
            model.clean()
        }
        
        view.didUndo.subscribe {
            model.undo()
        }
    }
}



