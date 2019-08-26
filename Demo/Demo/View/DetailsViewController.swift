//
//  DetailsViewController.swift
//  Demo
//
//  Created by Pavel Sharanda on 8/23/19.
//  Copyright © 2019 Pavel Sharanda. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    let viewModel: DetailsViewModel
    
    init(viewModel: DetailsViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        viewModel.item.subscribe { [weak self] in
            self?.label.text = $0.title
        }
    }
    
    private let label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
