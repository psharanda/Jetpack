//
//  Created by Pavel Sharanda on 20.09.16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

public extension ObservableProtocol where ValueType: ValueConvertible {
    
    public var valueOnly: Observable<ValueType.ValueType> {
        return flatMap { result in
            result.value
        }
    }
}

public extension ObservableProtocol where ValueType: ErrorConvertible {
    
    public var errorOnly: Observable<Error> {
        return flatMap { result in
            result.error
        }
    }
}

public extension ObservableProtocol where ValueType: ResultConvertible {
    
    var resultOnly: Observable<Result<ValueType.ValueType>> {
        return flatMap {
            $0.result
        }
    }
}


public extension ObservableProtocol where ValueType: Error {

    public var localizedDescription: Observable<String> {
        return map { $0.localizedDescription }
    }
}




