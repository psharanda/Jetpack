//
//  Created by Pavel Sharanda on 20.09.16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

public protocol Bindable {
    associatedtype ValueType
    func update(_ newValue: ValueType)
}

extension Bindable where ValueType == Void {
    public func update() {
        update(())
    }
}

public extension ObservableProtocol {
    
    public func bind<T: Bindable>(_ bindable: T) -> Disposable where T.ValueType == ValueType {
        return subscribe {result in
            bindable.update(result)
        }
    }
    
    public func bind<T: Bindable>(_ bindable: T) -> Disposable where T.ValueType == ValueType? {
        
        return subscribe { result in
            bindable.update(result)
        }
    }
}


