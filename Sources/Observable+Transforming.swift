//
//  Created by Pavel Sharanda on 20.09.16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

extension Observable {
    
    public func map<U>(_ transform: @escaping (ValueType)-> U) -> Observer<U> {
        return Observer<U> { observer in
            return self.subscribe { result in
                observer((transform(result)))
            }
        }
    }
    
    public func flatMap<U>(_ transform: @escaping (ValueType)-> U?) -> Observer<U> {
        return Observer<U> { observer in
            return self.subscribe { result in
                if let newValue = transform(result) {
                    observer(newValue)
                }
            }
        }
    }
    
    public func reduce<U>(_ initial: U, f: @escaping (U, ValueType) -> U) -> Observer<U> {
        var reduced: U = initial
        return Observer<U> { observer in
            return self.subscribe { result in
                reduced = f(reduced, result)
                observer(reduced)
            }
        }
    }

    
    public func just<U>(_ value: U) -> Observer<U> {
        return map { _ -> U in
            return value
        }
    }
    
    public var just: Observer<Void> {
        return just(())
    }
}


