//
//  Created by Pavel Sharanda on 16.02.17.
//  Copyright © 2017 SnipSnap. All rights reserved.
//

import Foundation

// wrapper around real state
public class BindingTarget<T>: Bindable {
    
    private let setter: (T)->Void
    
    public init(setter: @escaping (T)->Void) {
        self.setter = setter
    }
    
    public func update(_ newValue: T) {
        setter(newValue)
    }
}
