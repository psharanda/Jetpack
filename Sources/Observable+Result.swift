//
//  Created by Pavel Sharanda on 20.09.16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

public extension Observable where ValueType: ResultConvertible {
    
    public var valueOnly: Observer<ValueType.ValueType> {
        return flatMap { result in
            result.value
        }
    }
    
    public var errorOnly: Observer<Error> {
        return flatMap { result in
            result.error
        }
    }
}

public extension Observable where ValueType: Error {

    public var localizedDescription: Observer<String> {
        return map { $0.localizedDescription }
    }
}




