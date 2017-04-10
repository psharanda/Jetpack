//
//  Created by Pavel Sharanda on 16.02.17.
//  Copyright © 2017. All rights reserved.
//

import Foundation

/**
 Wrapper around some state which provides interface for binding
 */
public class Receiver<T>: Bindable {
    
    private let setter: (T)->Void
    
    public init(setter: @escaping (T)->Void) {
        self.setter = setter
    }
    
    public func update(_ newValue: T) {
        setter(newValue)
    }
}
