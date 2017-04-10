//
//  Created by Pavel Sharanda on 16.02.17.
//  Copyright © 2017 SnipSnap. All rights reserved.
//

import Foundation

///Bindable observable but with no initial value "var x: Bool? = nil|true|false"
public class Signal<T>: Observable<T>, Bindable {
    
    public override init() {
        super.init()
    }
    
    public func update(_ newValue: T) {
        rawUpdate(newValue)
    }
}
