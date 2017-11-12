//
//  ListViewProtocol.swift
//  Demo
//
//  Created by Pavel Sharanda on 29.09.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation
import Jetpack

protocol ListViewProtocol: ViewProtocol {
    var undoEnabled: Receiver<Bool> {get}
    var items: Receiver<([Item], ArrayEditEvent)> {get}
    var didAdd: Observable<String> {get}
    var didToggle: Observable<(Int)> {get}
    var didDelete: Observable<Int> {get}
    var didMove: Observable<(Int, Int)> {get}
    var didUndo: Observable<Void> {get}
    var didClean: Observable<Void> {get}
}
