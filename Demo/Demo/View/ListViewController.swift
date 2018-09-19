//
//  Created by Pavel Sharanda on 11.04.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import UIKit
import Jetpack
import Differ

#if swift(>=4.2)
public typealias TableViewCellEditingStyle = UITableViewCell.EditingStyle
#else
public typealias TableViewCellEditingStyle = UITableViewCellEditingStyle
#endif

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let addButton = UIBarButtonItem(barButtonSystemItem: .add)
    private let editButton = UIBarButtonItem(barButtonSystemItem: .edit)
    private let doneButton = UIBarButtonItem(barButtonSystemItem: .done)
    
    private let undoButton = UIBarButtonItem(barButtonSystemItem: .undo)
    private let cleanButton = UIBarButtonItem(barButtonSystemItem: .trash)
    
    private var didLoadTableView = false
    
    let viewModel: ListViewModelProtocol
    
    init(viewModel: ListViewModelProtocol) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        //perform bindings
        self.viewModel.items.diff.subscribe { [weak self] in
            self?.updateTableView(oldItems: $0.old.0, newItems: $0.new.0, editEvent: $0.new.1)
        }
        
        self.viewModel.undoEnabled.subscribe { [weak self] in
            self?.undoButton.isEnabled = $0
        }
        
        addButton.jx.clicked.subscribe {
            self.viewModel.didAdd(title: Lorem.words(2))
        }
        
        undoButton.jx.clicked.subscribe {
            self.viewModel.didUndo()
        }
        
        cleanButton.jx.clicked.subscribe {
            self.viewModel.didClean()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "TODO"
        
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)

        navigationItem.rightBarButtonItems = [addButton, undoButton]
        navigationItem.leftBarButtonItems = [editButtonItem, cleanButton]
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    //MARK: - update
    
    private func updateTableView(oldItems: [Item], newItems: [Item], editEvent: ArrayEditEvent) {
        if didLoadTableView {
            switch editEvent {
            case .set:
                let diff = oldItems.extendedDiff(newItems) {
                    $0.id == $1.id
                }
                
                var valuesMap = [String: (Item, Int)]()
                
                oldItems.enumerated().forEach {
                    valuesMap[$0.element.id] = ($0.element, $0.offset)
                }
                
                #if swift(>=4.1)
                let indexPathsToReload = newItems.compactMap { i -> IndexPath? in
                    if let oldValue = valuesMap[i.id] {
                        if oldValue.0 != i {
                            return IndexPath(row: oldValue.1, section: 0)
                        }
                    }
                    return nil
                }
                #else
               let indexPathsToReload = _items.flatMap { i -> IndexPath? in
                    if let oldValue = valuesMap[i.id] {
                        if oldValue.0 != i {
                            return IndexPath(row: oldValue.1, section: 0)
                        }
                    }
                    return nil
                }
                #endif
 
                tableView.beginUpdates()
                tableView.apply(diff)
                tableView.reloadRows(at: indexPathsToReload, with: .automatic)
                tableView.endUpdates()
            case .remove(let idx):
                tableView.deleteRows(at: [IndexPath(row: idx, section: 0) ], with: .automatic)
            case .insert(let idx):
                tableView.insertRows(at: [IndexPath(row: idx, section: 0) ], with: .automatic)
                tableView.scrollToRow(at: IndexPath(row: idx, section: 0), at: .bottom, animated: true)
            case .move(let from, let to):
                tableView.moveRow(at: IndexPath(row: from, section: 0), to: IndexPath(row: to, section: 0))
            case .update(let idx):
                tableView.reloadRows(at: [IndexPath(row: idx, section: 0) ], with: .automatic)
            }
        }
    }
    
    //MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        didLoadTableView = true
        return viewModel.items.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "CellId"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) ?? UITableViewCell(style: .default, reuseIdentifier: cellId)
        
        let item = viewModel.items.value[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.completed ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didToggle(at: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: TableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            viewModel.didDelete(at: indexPath.row)
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
        viewModel.didMove(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
}







