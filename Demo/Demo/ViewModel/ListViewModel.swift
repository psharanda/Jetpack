//
//  Created by Pavel Sharanda on 29.09.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation
import Jetpack

class ListViewModel {
    
    private let model: ListModel
    
    init(model: ListModel) {
        self.model = model
    }
    
    var items: ArrayProperty<Item> {
        return model.items
    }
    
    var undoEnabled: Property<Bool> {
        return model.undoEnabled
    }
    
    func didAdd(title: String) {
        model.appendItem(Item(id: UUID().uuidString, title: title, completed: false))
    }
    
    var onToggle: Observable<Int> {
        return _onToggle.asObservable
    }
    
    private let _onToggle = PublishSubject<Int>()
    
    func didSelect(at: Int) {
        _onToggle.update(at)
    }
    
    func didDelete(at: Int) {
        model.removeItem(at: at)
    }
    
    func didMove(from: Int, to: Int) {
        model.moveItem(from: from, to: to)
    }
    
    func didUndo() {
        model.undo()
    }
    
    func didClean() {
        model.clean()
    }
}



