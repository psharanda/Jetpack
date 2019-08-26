//
//  HomeNavigationController.swift
//  Demo
//
//  Created by Pavel Sharanda on 8/23/19.
//  Copyright © 2019 Pavel Sharanda. All rights reserved.
//

import UIKit

class HomeNavigationController: UINavigationController {
    
    private let viewModel: HomeViewModel
    
    init(viewModel: HomeViewModel   ) {
        
        self.viewModel = viewModel
        
        let listViewModel = viewModel.makeListViewModel()
        let vc = ListViewController(viewModel: listViewModel)
        super.init(nibName: nil, bundle: nil)
        
        self.viewControllers = [vc]
        
        listViewModel.onToggle.subscribe { [weak self] index in
            self?.pushDetails(index: index)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func pushDetails(index: Int) {
        let detailsViewModel = viewModel.makeDetailsViewModel(index: index)
        let vc = DetailsViewController(viewModel: detailsViewModel)
        pushViewController(vc, animated: true)
    }
}
