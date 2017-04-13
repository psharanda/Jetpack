//
//  Created by Pavel Sharanda on 12.04.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation

extension TaskProtocol {
    
    /**
     Start task
     */
    @discardableResult
    public func start() -> Disposable {
        return start { _ in }
    }
    
    /**
     Perform one task after another
     */
    public func then<U>(_ task: @escaping (ValueType)->Task<U>) -> Task<U>  {
        return Task<U> { completion  in
            let serial = SerialDisposable()
            serial.swap(with: self.start { result in
                switch result {
                case .success(let value):
                    serial.swap(with: task(value).start(completion))
                case .failure(let error):
                    completion(.failure(error))
                case .cancelled:
                    completion(.cancelled)
                }
            })
            return serial
        }
    }
    
    /**
     Transform task success value to value
     */
    public func map<U>(_ transform: @escaping (ValueType)-> U) -> Task<U> {
        return Task<U> { completion in
            return self.start { result in
                completion(result.map(transform))
            }
        }
    }
    
    /**
     Transform task success value  to result
     */
    public func flatMap<U>(_ transform: @escaping (ValueType)-> TaskResult<U>) -> Task<U> {
        return Task<U> { completion in
            return self.start { result in
                completion(result.flatMap(transform))
            }
        }
    }
    
    /**
     Transform task success value  to static value
     */
    public func just<U>(_ value: U) -> Task<U> {
        return map { _ -> U in
            return value
        }
    }
    
    /**
     Transform task success value to void value
     */
    public var just: Task<Void> {
        return just(())
    }
    
    /**
     Add handler to perform specific action if task was successful
     */
    public func onSuccess(_ handler:  @escaping(ValueType) -> Void) -> Task<ValueType> {
        return Task { completion in
            return self.start { result in
                if case let .success(value) = result {
                    handler(value)
                }
                completion(result)
            }
        }
    }
    
    /**
     Add handler to perform specific action if task failed
     */
    public func onFailure(_ handler:  @escaping(Error) -> Void) -> Task<ValueType> {
        return Task { completion in
            return self.start { result in
                if case let .failure(error) = result {
                    handler(error)
                }
                completion(result)
            }
        }
    }
    
    /**
     Add handler to perform specific action on task cancellation
     */
    public func onCancelled(_ handler:  @escaping() -> Void) -> Task<ValueType> {
        return Task { completion in
            return self.start { result in
                if case .cancelled = result {
                    handler()
                }
                completion(result)
            }
        }
    }
    
    /**
     Add handler to perform specific action on result
     */
    public func onResult(_ handler:  @escaping(TaskResult<ValueType>) -> Void) -> Task<ValueType> {
        return Task { completion in
            return self.start { result in
                handler(result)
                completion(result)
            }
        }
    }
    
    /**
     Run two tasks concurrently, return the result of the first successfull one, other one will be cancelled. When one of them fails, other one is cancelled. On cancel, it cancelles both children.
     */
    public func race<U, R: TaskProtocol>(_ right: R) -> Task<Either<ValueType,U>>  where R.ValueType == U {
        let left = self
        return Task<Either<ValueType,U>> { completion in
            var leftTask: Disposable?
            var rightTask: Disposable?
            
            // done means that we already called the completion
            var done = false
            // number of childred exited so far
            var exited = 0
            
            func handler(other: Disposable?) -> ((TaskResult<Either<ValueType,U>>) -> Void) {
                return { result in
                    exited += 1
                    
                    guard !done else {
                        // other one already called completion, nothing to do here
                        return
                    }
                    
                    switch result {
                    case .success(let value):
                        // we are the winner!
                        done = true
                        other?.dispose()
                        completion(.success(value))
                    case .failure(let error):
                        // we are the failing winner...
                        done = true
                        other?.dispose()
                        completion(.failure(error))
                    case .cancelled:
                        if exited == 2 {
                            // we are the last cancelled child, lets notify parent
                            done = true
                            completion(.cancelled)
                        }
                    }
                }
            }
            
            leftTask = left.map{.left($0)}.start(handler(other: rightTask))
            
            // Note that left could immediately return result (or just fail)
            // We don't need to start the right one in that case
            if !done {
                rightTask = right.map{.right($0)}.start(handler(other: leftTask))
            }
            
            return DelegateDisposable {
                leftTask?.dispose()
                rightTask?.dispose()
            }
        }
    }
    
    /** Run two tasks concurrently, wait for both to succeed and return both results. If one fails, then other one will be cancelled.
     */
    public func concurrently<U, R: TaskProtocol>(_ right: R) -> Task<(ValueType, U)>  where R.ValueType == U {
        let left = self
        return Task<(ValueType,U)> { completion in
            var leftTask: Disposable?
            var rightTask: Disposable?
            
            // done means that we already called the completion
            var done = false
            // number of childred exited so far
            var exited = 0
            
            func handler<R>(other: Disposable?, block: @escaping (R)->Void) -> ((TaskResult<R>) -> Void) {
                return { result in
                    exited += 1
                    
                    guard !done else {
                        // other one already called completion, nothing to do here
                        return
                    }
                    
                    switch result {
                    case .success(let value):
                        block(value)
                    case .failure(let error):
                        done = true
                        other?.dispose()
                        completion(.failure(error))
                    case .cancelled:
                        if exited == 2 {
                            // we are the last cancelled child, lets notify parent
                            done = true
                            completion(.cancelled)
                        }
                    }
                }
            }
            
            var t: ValueType?
            var u: U?
            
            func onResult() {
                guard let t = t else {
                    return
                }
                guard let u = u else {
                    return
                }
                // both results are available
                done = true
                completion(.success(t,u))
            }
            
            leftTask = left.start(handler(other: rightTask) { value in
                t = value
                onResult()
            })
            
            // Note that left could immediately fail
            // We don't need to start the right one in that case
            if !done {
                rightTask = right.start(handler(other: leftTask) { value in
                    u = value
                    onResult()
                })
            }
            
            return DelegateDisposable {
                leftTask?.dispose()
                rightTask?.dispose()
            }
        }
    }
    
    /**
     Run a number of tasks one by one in a sequence
     */
    public static func sequence(_ tasks: [Task<ValueType>]) -> Task<[ValueType]> {
        let empty = Task<[ValueType]>.from(value: [])
        return tasks.reduce(empty) { left, right in
            left.then { result in
                right.map { t in
                    result + [t]
                }
            }
        }
    }
    
    /**
     Run a number of tasks concurrently
     */
    public static func concurrently<R: TaskProtocol>(_ tasks: [R]) -> Task<[ValueType]>  where R.ValueType == ValueType {
        let empty = Task<[ValueType]>.from(value: [])
        return tasks.reduce(empty) { left, right in
            left.concurrently(right).map { (result, t) in
                result + [t]
            }
        }
    }
    
    /**
     Deliver value after delay
     */
    public func delay(timeInterval: TimeInterval, queue: DispatchQueue = .main) -> Task<ValueType> {
        
        return Task { completion  in
            let serial = SerialDisposable()
            serial.swap(with: self.start { result in
                
                if  case .cancelled = result {
                    completion(.cancelled)
                    return
                }
                
                serial.swap(with: queue.after(timeInterval: timeInterval) { cancelled in
                    if cancelled {
                        completion(.cancelled)
                    } else {
                        completion(result)
                    }
                })
            })
            return serial
        }
    }
    
    /**
     Retry task if error did happen.
     
     - parameter numberOfTimes: number of retries before stop
     
     - parameter timeout: timeout between first and second try
     
     - parameter nextTimeout: timeout value generator. By default generates same value as previous timeout
     
     - parameter queue: set queue where you want to deliver results. DispatchQueue.main is default
     
     - parameter until: return false to stop retrying, return true to keep trying
     
     - returns: new task
     */
    public func retry(numberOfTimes: Int, timeout: TimeInterval, nextTimeout: @escaping (TimeInterval)->TimeInterval = { $0 }, queue: DispatchQueue = .main, until: @escaping (Error)->(Bool) = {_ in true }) -> Task<ValueType> {
        
        var currentTimeout = timeout
        var numberOfRetries = 0
        
        return Task<ValueType> { completion  in
            let serial = SerialDisposable()
            
            func retryImpl() -> Disposable {
                return self.start { result in
                    switch result {
                    case .success(let value):
                        completion(.success(value))
                    case .failure(let error):
                        numberOfRetries += 1
                        if until(error) && (numberOfRetries <= numberOfTimes) {
                            serial.swap(with: queue.after(timeInterval: currentTimeout) { cancelled in
                                if cancelled {
                                    completion(.cancelled)
                                } else {
                                    serial.swap(with: retryImpl())
                                }
                            })
                            currentTimeout = nextTimeout(currentTimeout)
                        } else {
                            completion(.failure(error))
                        }
                    case .cancelled:
                        completion(.cancelled)
                    }
                }
            }
            
            serial.swap(with: retryImpl())
            return serial
        }
    }
}
