//
//  Created by Pavel Sharanda on 16.02.17.
//  Copyright © 2017 SnipSnap. All rights reserved.
//

import Foundation

///observable with initial value "var x: Bool { return true|false }"
public class Property<T>: Observable<T> {
    
    public var value: T {
        return _value! //we are sure here that value can't be nil
    }
    
    public init(_ value: T) {
        super.init()
        _value = value
    }
}
