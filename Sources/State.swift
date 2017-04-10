//
//  Created by Pavel Sharanda on 16.02.17.
//  Copyright © 2017 SnipSnap. All rights reserved.
//

import Foundation

// real state
public class State<T>: Bindable {
    
    private var _value: T
    
    public var value: T {
        return _value
    }
    
    let onChange: (T, T)->Void
    
    public init(_ value: T, onChange: @escaping (T, T)->Void) {
        _value = value
        self.onChange = onChange
    }
    
    public func update(_ newValue: T) {
        let oldValue = _value
        _value = newValue
        onChange(oldValue, newValue)
    }
}
