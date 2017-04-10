//
//  Created by Pavel Sharanda on 20.09.16.
//  Copyright © 2016. All rights reserved.
//

import Foundation


/* Example of possible Result enum

enum Result<T>: Errorable, Resultable {
    case Success(T)
    case Failure(NSError)
    
    var result: T? {
        switch self {
        case .Success(let result):
            return result
        default:
            return nil
        }
    }
    
    var error: NSError? {
        switch self {
        case .Failure(let error):
            return error
        default:
            return nil
        }
    }
}
 
*/

public protocol Errorable {
    var error: Error? {get}
}

public protocol Resultable {
    associatedtype ResultType
    var result: ResultType? {get}
}

public extension Observable where ValueType: Errorable {
    
    public var error: Observer<Error> {
        return flatMap { result in
            result.error
        }
    }
}

public extension Observable where ValueType: Resultable {
    
    public var result: Observer<ValueType.ResultType> {
        return flatMap { result in
            result.result
        }
    }
}


