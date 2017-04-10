//
//  Created by Pavel Sharanda on 20.09.16.
//  Copyright © 2016 SnipSnap. All rights reserved.
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
    var error: NSError? {get}
}

public protocol Resultable {
    associatedtype ResultType
    var result: ResultType? {get}
}

public extension Observable where T: Errorable {
    
    public var error: Observable<NSError> {
        return flatMap { result in
            result.error
        }
    }
}

public extension Observable where T: Resultable {
    
    public var result: Observable<T.ResultType> {
        return flatMap { result in
            result.result
        }
    }
}

public extension RetriableTaskHolder where T: Errorable {
    
    @discardableResult
    public func retryAfterError(_ numberOfTimes: Int, timeout: TimeInterval? = nil, queue: DispatchQueue = DispatchQueue.main) -> RetriableTaskHolder<T> {
        return retry(numberOfTimes, timeout: timeout, queue: queue) {
            $0.error != nil
        }
    }
}
