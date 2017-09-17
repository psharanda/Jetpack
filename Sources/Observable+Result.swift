//
//  Created by Pavel Sharanda on 20.09.16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

public extension ObservableProtocol where ValueType: ResultConvertible {
    
    public var valueOnly: Observable<ValueType.ValueType> {
        return flatMap { result in
            result.value
        }
    }
    
    public var errorOnly: Observable<Error> {
        return flatMap { result in
            result.error
        }
    }
}

public extension ObservableProtocol where ValueType: Error {

    public var localizedDescription: Observable<String> {
        return map { $0.localizedDescription }
    }
}




