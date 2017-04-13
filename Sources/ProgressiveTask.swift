//
//  Created by Pavel Sharanda on 09.04.17.
//  Copyright © 2017. All rights reserved.
//

import Foundation

/**
 Task which can track operation progress
 */
public struct ProgressiveTask<T, ProgressType> {
    
    private let worker: (@escaping (ProgressType) -> Void, @escaping (TaskResult<T>) -> Void) -> Disposable
    
    /**
     Create task with worker
     */
    public init(worker: @escaping (@escaping (ProgressType) -> Void, @escaping (TaskResult<T>) -> Void) -> Disposable) {
        self.worker = worker
    }
    
    /**
     Start task and handle progress and result
     */
    @discardableResult
    public func start(progress: @escaping (ProgressType) -> Void, completion: @escaping (TaskResult<T>) -> Void) -> Disposable {
        return worker(progress, completion)
    }
}

extension ProgressiveTask: TaskProtocol {
    
    public typealias ValueType = T
    
    /**
     Start task and handle result
     */
    @discardableResult
    public func start(_ completion: @escaping (TaskResult<T>) -> Void) -> Disposable {
        return start(progress: {_ in }, completion: completion)
    }
}

extension ProgressiveTask {
    
    /**
     Create task with worker which will be run in workerQueue and send result to completionQueue. Worker can produce value or error.
     */
    public init(workerQueue: DispatchQueue, completionQueue: DispatchQueue = .main, worker: @escaping (@escaping (ProgressType) -> Void) -> TaskResult<T>) {
        self.init { progress, completion in
            return workerQueue.run(worker: {
                return worker(progress)
            }, completionQueue: completionQueue) { value in
                completion(value)
            }
        }
    }
    
    /**
     Create task with worker which will be run in workerQueue and send value to completionQueue. Worker can produce only value.
     */
    public init(workerQueue: DispatchQueue, completionQueue: DispatchQueue = .main, worker: @escaping (@escaping (ProgressType) -> Void) -> T) {
        self.init(workerQueue: workerQueue, completionQueue: completionQueue) { (progress) -> TaskResult<T> in
            return .success(worker(progress))
        }
    }
    
    /**
     Add handler to perform specific action on progress event
     */
    public func onProgress(_ handler:  @escaping(ProgressType) -> Void) -> ProgressiveTask<T, ProgressType> {
        return ProgressiveTask { (progress, completion) in
            return self.start(progress: { (p) in
                handler(p)
                progress(p)
            }, completion: completion)
        }
    }
}

