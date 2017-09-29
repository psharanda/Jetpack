//
//  ViewController.swift
//  Demo
//
//  Created by Pavel Sharanda on 11.04.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import UIKit
import Jetpack

protocol ListViewProtocol: class {
    var items: [Item] {get set}
    var didAdd: Observable<String> {get}
    var didToggle: Observable<(Int, Bool)> {get}
    var didDelete: Observable<Int> {get}
}

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ListViewProtocol {
    
    var presenter: Any?
    
    var items: [Item] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var didAdd: Observable<String> {
        return _didAdd.asObservable
    }
    
    private let _didAdd = Signal<String>()
    
    var didToggle: Observable<(Int, Bool)> {
        return _didToggle.asObservable
    }
    
    private let _didToggle = Signal<(Int, Bool)>()
    
    var didDelete: Observable<Int> {
        return _didDelete.asObservable
    }
    
    private let _didDelete = Signal<Int>()
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "TODO"
        
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add)
        _ = addButton.jx.clicked.map { "\(Date())" }.bind(_didAdd)
        
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    //MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "CellId"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) ?? UITableViewCell(style: .default, reuseIdentifier: cellId)
        
        let item = items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.completed ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        _didToggle.update((indexPath.row, !item.completed))
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            _didDelete.update(indexPath.row)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}



