//
//  Created by Pavel Sharanda on 20.09.16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

public protocol ErrorConvertible {
    var error: Error? {get}
}

public protocol ValueConvertible {
    associatedtype ValueType
    var value: ValueType? {get}
}

extension Result: ErrorConvertible, ValueConvertible { }

public extension Observable where ValueType: ErrorConvertible {
    
    public var errorOnly: Observer<Error> {
        return flatMap { result in
            result.error
        }
    }
}

public extension Observable where ValueType: ValueConvertible {
    
    public var valueOnly: Observer<ValueType.ValueType> {
        return flatMap { result in
            result.value
        }
    }
}


