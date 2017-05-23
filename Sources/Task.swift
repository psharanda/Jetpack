//
//  Created by Pavel Sharanda and Yuras Shumovich
//  Copyright © 2017. All rights reserved.
//

import Foundation

public typealias Task<T> = Observer<Result<T>>


extension Task {
    
    /**
     Create task with worker which will be run in workerQueue and send result to completionQueue. Worker can produce value or error.
     */
    public init<U>(workerQueue: DispatchQueue, completionQueue: DispatchQueue = .main, worker: @escaping () -> Result<U>) where ValueType == Result<U> {
        self.init { completion in
            return workerQueue.jx.execute(worker: worker, completionQueue: completionQueue) { (value: Result<U>) in
                completion(value)
            }
        }
    }
    
    /**
     Create task with worker which will be run in workerQueue and send value to completionQueue. Worker can produce only value.
     */
    public init<U>(workerQueue: DispatchQueue, completionQueue: DispatchQueue = .main, worker: @escaping () -> U)  where ValueType == Result<U> {
        self.init(workerQueue: workerQueue, completionQueue: completionQueue) { () -> Result<U> in
            return .success(worker())
        }
    }
    
    /**
     Create task which immediately completes with result
     */
    public static func from<U>(result: Result<U>) -> Task<U>  where ValueType == Result<U> {
        return Task<U> { completion in
            completion(result)
            return EmptyDisposable()
        }
    }
    
    /**
     Create task which immediately completes with value
     */
    public static func from<U>(value: U) -> Task<U>  where ValueType == Result<U> {
        return from(result: .success(value))
    }
    
    /**
     Create task which immediately completes with error
     */
    public static func from<U>(error: Error) -> Task<U>  where ValueType == Result<U> {
        return from(result: .failure(error))
    }
}

