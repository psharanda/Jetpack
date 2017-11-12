//
//  ViewProtocol.swift
//  Demo
//
//  Created by Pavel Sharanda on 10.11.17.
//  Copyright © 2017 Pavel Sharanda. All rights reserved.
//

import Foundation
import Jetpack

protocol ViewProtocol: class {
    var apool: AutodisposePool {get}
}
