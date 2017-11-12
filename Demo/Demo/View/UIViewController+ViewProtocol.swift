//
//  UIViewController+ViewProtocol.swift
//  Demo
//
//  Created by Pavel Sharanda on 10.11.17.
//  Copyright © 2017 Pavel Sharanda. All rights reserved.
//

import Foundation
import UIKit
import Jetpack

extension UIViewController: ViewProtocol {
    var apool: AutodisposePool {
        return jx.autodisposePool
    }
}
