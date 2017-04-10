//
//  Created by Pavel Sharanda on 16.02.17.
//  Copyright © 2017 SnipSnap. All rights reserved.
//

import Foundation

///Bindable observable with initial value "var x: Bool = true|false"
public class MutableProperty<T>: Property<T>, Bindable {
    
    public override init(_ value: T) {
        super.init(value)
    }
    
    public func update(_ newValue: T) {
        rawUpdate(newValue)
    }
}
