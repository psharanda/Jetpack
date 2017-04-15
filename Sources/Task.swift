//
//  Created by Pavel Sharanda and Yuras Shumovich
//  Copyright © 2017. All rights reserved.
//

import Foundation

public struct Task<T>: Observable, TaskProtocol {
    
    public typealias ValueType = Result<T>
    public typealias ResultValueType = T
    
    private let worker: (@escaping (Result<T>) -> Void) -> Disposable
    
    /**
     Create task with completable worker
     */
    public init(worker: @escaping (@escaping (Result<T>) -> Void) -> Disposable) {
        self.worker = worker
    }

    public func subscribe(_ observer: @escaping (Result<T>) -> Void) -> Disposable {
        return worker(observer)
    }
}


extension Task {
    
    /**
     Create task with worker which will be run in workerQueue and send result to completionQueue. Worker can produce value or error.
     */
    public init(workerQueue: DispatchQueue, completionQueue: DispatchQueue = .main, worker: @escaping () -> Result<T>) {
        self.init { completion in
            return workerQueue.run(worker: worker, completionQueue: completionQueue) { value in
                completion(value)
            }
        }
    }
    
    /**
     Create task with worker which will be run in workerQueue and send value to completionQueue. Worker can produce only value.
     */
    public init(workerQueue: DispatchQueue, completionQueue: DispatchQueue = .main, worker: @escaping () -> T) {
        self.init(workerQueue: workerQueue, completionQueue: completionQueue) { () -> Result<T> in
            return .success(worker())
        }
    }
    
    /**
     Create task which immediately completes with result
     */
    public static func from(result: Result<T>) -> Task<T> {
        return Task<T> { completion in
            completion(result)
            return EmptyDisposable()
        }
    }
    
    /**
     Create task which immediately completes with value
     */
    public static func from(value: T) -> Task<T> {
        return from(result: .success(value))
    }
    
    /**
     Create task which immediately completes with error
     */
    public static func from(error: Error) -> Task<T> {
        return from(result: .failure(error))
    }
}

