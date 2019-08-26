//
//  HomeViewModel.swift
//  Demo
//
//  Created by Pavel Sharanda on 8/23/19.
//  Copyright © 2019 Pavel Sharanda. All rights reserved.
//

import Foundation

class HomeViewModel {
    
    private let model: ListModel
    
    init(items: [Item]) {
        model = ListModel(items: items)
        
        model.items.subscribe {
            ListPersistentStorage.save(items: $0.0)
        }
    }
    
    func makeListViewModel() -> ListViewModel {
        return ListViewModel(model: model)
    }
    
    func makeDetailsViewModel(index: Int) -> DetailsViewModel {
        return DetailsViewModel(item: model.items.asProperty.map { $0[index] })
    }
}
