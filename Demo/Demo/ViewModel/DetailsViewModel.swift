//
//  DetailsViewModel.swift
//  Demo
//
//  Created by Pavel Sharanda on 8/23/19.
//  Copyright © 2019 Pavel Sharanda. All rights reserved.
//

import Foundation
import Jetpack

class DetailsViewModel {
    let item: Property<Item>
    
    init(item: Property<Item>) {
        self.item = item
    }
}
