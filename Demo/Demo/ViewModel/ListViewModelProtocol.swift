//
//  ListViewProtocol.swift
//  Demo
//
//  Created by Pavel Sharanda on 29.09.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation
import Jetpack

protocol ListViewModelProtocol {
    
    var items: ArrayProperty<Item> {get}
    var undoEnabled: Property<Bool> {get}
    
    func didAdd(title: String)
    func didToggle(at: Int)
    func didDelete(at: Int)
    func didMove(from: Int, to: Int)
    func didUndo()
    func didClean()
}


