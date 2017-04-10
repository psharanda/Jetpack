//
//  Created by Pavel Sharanda on 20.09.16.
//  Copyright © 2016 SnipSnap. All rights reserved.
//

import Foundation

public protocol Bindable: class {
    associatedtype ValueType
    func update(_ newValue: ValueType)
}

public extension Observable {
    
    @discardableResult
    public func bind<U: Bindable>(_ bindable: U) -> Token where U.ValueType == T {
        return subscribe {[weak bindable] result in
            bindable?.update(result)
        }
    }
    
    @discardableResult
    public func bind<U: Bindable>(_ bindable: U) -> Token where U.ValueType == T? {
        
        return subscribe {[weak bindable] result in
            bindable?.update(result)
        }
    }
}

extension Observable {
    
    @discardableResult
    public func bindCancel(_ cancelable: Cancelable) -> Token {
        return subscribe {[weak cancelable] result in
            cancelable?.cancel()
        }
    }
}


