//
//  Created by Pavel Sharanda on 20.09.16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

public protocol Errorable {
    var error: Error? {get}
}

public protocol Valueable {
    associatedtype ValueType
    var value: ValueType? {get}
}

extension Result: Errorable, Valueable { }
extension TaskResult: Errorable, Valueable { }

public extension Observable where ValueType: Errorable {
    
    public var error: Observer<Error> {
        return flatMap { result in
            result.error
        }
    }
}

public extension Observable where ValueType: Valueable {
    
    public var value: Observer<ValueType.ValueType> {
        return flatMap { result in
            result.value
        }
    }
}


