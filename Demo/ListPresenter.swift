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
    
    private let apool = AutodisposePool()
    
    init(view: ListViewProtocol, storeItems: MutableProperty<[Item]> ) {
        self.view = view
        
        storeItems
            .subscribe { [weak self] in
                self?.view.items = $0
            }
            .autodispose(in: apool)
        
        view.didAdd
            .subscribe {
                var items = storeItems.value
                items.append(Item(title: $0, completed: false))
                storeItems.update(items)
            }
            .autodispose(in: apool)
        
        view.didToggle
            .subscribe {
                var items = storeItems.value
                items[$0.0].completed = $0.1
                storeItems.update(items)
            }
            .autodispose(in: apool)
        
        view.didDelete
            .subscribe {
                var items = storeItems.value
                items.remove(at: $0)
                storeItems.update(items)
            }
            .autodispose(in: apool)
    }
}
