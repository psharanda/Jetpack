//
//  ViewController.swift
//  Demo
//
//  Created by Pavel Sharanda on 11.04.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import UIKit
import Jetpack
import Differ

protocol ListViewProtocol: class {
    var undoEnabled: Bool {get set}
    var items: [Item] {get set}
    var didAdd: Observable<String> {get}
    var didToggle: Observable<(Int, Bool)> {get}
    var didDelete: Observable<Int> {get}
    var didMove: Observable<(Int, Int)> {get}
    var didUndo: Observable<Void> {get}
    var didClean: Observable<Void> {get}
}

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ListViewProtocol {
    
    var presenter: Any?
    
    private var didLoadTableView = false
    var items: [Item] = [] {
        didSet {

            if didLoadTableView {
                let diff = oldValue.extendedDiff(items) {
                    $0.0.id == $0.1.id
                }
                
                if diff.elements.count > 0 {
                    tableView.apply(diff)
                } else {
                    let deepDiff = oldValue.extendedDiff(items)
                    
                    let indexPathsToReload = deepDiff.elements.flatMap { el -> IndexPath? in
                        switch el {
                        case .insert(let i):
                            return IndexPath(row: i, section: 0)
                        default:
                            return nil
                        }
                    }
                    
                    tableView.reloadRows(at: indexPathsToReload, with: .automatic)
                }
            }
        }
    }
    
    let undoButton = UIBarButtonItem(barButtonSystemItem: .undo)
    
    var undoEnabled: Bool = false {
        didSet {
            undoButton.isEnabled = undoEnabled
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
    
    var didMove: Observable<(Int, Int)> {
        return _didMove.asObservable
    }
    
    private let _didMove = Signal<(Int, Int)>()
    
    var didUndo: Observable<Void> {
        return _didUndo.asObservable
    }
    
    private let _didUndo = Signal<Void>()
    
    var didClean: Observable<Void> {
        return _didClean.asObservable
    }
    
    private let _didClean = Signal<Void>()
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "TODO"
        
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add)
        _ = addButton.jx.clicked.map { Lorem.words(2) }.bind(_didAdd)
        
        
        _ = undoButton.jx.clicked.bind(_didUndo)
        
        navigationItem.rightBarButtonItems = [addButton, undoButton]
        
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done)
        
        let cleanButton = UIBarButtonItem(barButtonSystemItem: .trash)
        
        _ = cleanButton.jx.clicked.bind(_didClean)
        
        navigationItem.leftBarButtonItems = [editButton, cleanButton]
    
        _ = editButton.jx.clicked.subscribe { [unowned self] in
            self.tableView.setEditing(true, animated: true)
            self.navigationItem.leftBarButtonItems = [doneButton, cleanButton]
        }
        
        _ = doneButton.jx.clicked.subscribe { [unowned self] in
            self.tableView.setEditing(false, animated: true)
            self.navigationItem.leftBarButtonItems = [editButton, cleanButton]
        }
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    //MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        didLoadTableView = true
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
        tableView.deselectRow(at: indexPath, animated: true)
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
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        _didMove.update((sourceIndexPath.row, destinationIndexPath.row))
    }
}



