//
//  Created by Pavel Sharanda on 12.04.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation

extension Observable where ValueType: ResultConvertible {
    
    public typealias ResultValueType = ValueType.ValueType
    
    /**
     Start task, actually just typealias for subscribe.
     */
    @discardableResult
    public func start() -> Disposable {
        return start { _ in }
    }
    
    @discardableResult
    public func start(_ completion: @escaping (ValueType) -> Void) -> Disposable {
        return subscribe(completion)
    }
    
    /**
     Perform one task after another
     */
    public func then<U>(_ task: @escaping (ResultValueType)->Task<U>) -> Task<U>  {
        return Task<U> { completion  in
            let disposable = SwapableDisposable()
            disposable.swap(parent: self.start { result in
                switch result.result {
                case .success(let value):
                    disposable.swap(child: task(value).start(completion))
                case .failure(let error):
                    completion(.failure(error))
                }
            })
            return disposable
        }
    }
    
    /**
     Transform task success value to value
     */
    public func mapValue<U>(_ transform: @escaping (ResultValueType)-> U) -> Task<U> {
        return Task<U> { completion in
            return self.start { result in
                completion(result.result.map(transform))
            }
        }
    }
    
    /**
     Transform task success value  to result
     */
    public func flatMapValue<U>(_ transform: @escaping (ResultValueType)-> Result<U>) -> Task<U> {
        return Task<U> { completion in
            return self.start { result in
                completion(result.result.flatMap(transform))
            }
        }
    }
    
    /**
     Transform task success value  to static value
     */
    public func justValue<U>(_ value: U) -> Task<U> {
        return mapValue { _ -> U in
            return value
        }
    }
    
    /**
     Transform task success value to void value
     */
    public var justValue: Task<Void> {
        return justValue(())
    }
    
    /**
     Add handler to perform specific action if task was successful
     */
    public func onSuccess(_ handler:  @escaping(ResultValueType) -> Void) -> Task<ResultValueType> {
        return Task { completion in
            return self.start { result in
                if case let .success(value) = result.result {
                    handler(value)
                }
                completion(result.result)
            }
        }
    }
    
    /**
     Add handler to perform specific action if task failed
     */
    public func onFailure(_ handler:  @escaping(Error) -> Void) -> Task<ResultValueType> {
        return Task { completion in
            return self.start { result in
                if case let .failure(error) = result.result {
                    handler(error)
                }
                completion(result.result)
            }
        }
    }
    
    /**
     Run two tasks concurrently, return the result of the first successfull one, other one will be cancelled. When one of them fails, other one is cancelled. On cancel, it cancelles both children.
     */
    public func race<R: Observable>(_ right: R) -> Task<Either<ResultValueType, R.ResultValueType>>  where R.ValueType: ResultConvertible {
        let left = self
        return Task<Either<ResultValueType,R.ResultValueType>> { completion in
            var leftTask: Disposable?
            var rightTask: Disposable?
            
            // done means that we already called the completion
            var done = false
            // number of childred exited so far
            var exited = 0
            
            func handler(other: Disposable?) -> ((Result<Either<ResultValueType,R.ResultValueType>>) -> Void) {
                return { result in
                    exited += 1
                    
                    guard !done else {
                        // other one already called completion, nothing to do here
                        return
                    }
                    
                    switch result.result {
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
                    }
                }
            }
            
            leftTask = left.mapValue{.left($0)}.start(handler(other: rightTask))
            
            // Note that left could immediately return result (or just fail)
            // We don't need to start the right one in that case
            if !done {
                rightTask = right.mapValue{.right($0)}.start(handler(other: leftTask))
            }
            
            return DelegateDisposable {
                leftTask?.dispose()
                rightTask?.dispose()
            }
        }
    }
    
    /** Run two tasks concurrently, wait for both to succeed and return both results. If one fails, then other one will be cancelled.
     */
   // public func combineLatest<T: Observable>(_ with: T) -> Observer<(ValueType,T.ValueType)> {
        
    public func concurrently<R: Observable>(_ with: R) -> Task<(ResultValueType,R.ResultValueType)>  where R.ValueType: ResultConvertible {
        
        return Task { completion in
            
            var withValue: R.ResultValueType?
            var selfValue: ResultValueType?
            
            var withDisposable: Disposable?
            var selfDisposable: Disposable?
            
            var done = false
            
            withDisposable = with.subscribe { result in
                
                switch result.result {
                case .success(let value):
                    withValue = value
                case .failure(let error):
                    done = true
                    completion(.failure(error))
                    selfDisposable?.dispose()
                }
                if let left = selfValue, let right = withValue {
                    done = true
                    completion(.success((left,right)))
                }
            }
            
            if !done {
                selfDisposable = self.subscribe { result in
                    switch result.result {
                    case .success(let value):
                        selfValue = value
                    case .failure(let error):
                        done = true
                        completion(.failure(error))
                        withDisposable?.dispose()
                    }
                    if let left = selfValue, let right = withValue {
                        done = true
                        completion(.success((left,right)))
                    }
                }
            }
            
            return DelegateDisposable {
                withDisposable?.dispose()
                selfDisposable?.dispose()
            }
        }
    }

    
    /**
     Run a number of tasks one by one in a sequence
     */
    public static func sequence<R: Observable>(_ tasks: [R]) -> Task<[R.ResultValueType]> where R.ValueType: ResultConvertible {
        let empty = Task<[R.ResultValueType]>.from(resultValue: [])
        return tasks.reduce(empty) { left, right in
            left.then { result in
                right.mapValue { t in
                    result + [t]
                }
            }
        }
    }

    /**
     Run a number of tasks concurrently
     */
    public static func concurrently<R: Observable>(_ tasks: [R]) -> Task<[R.ResultValueType]> where R.ValueType: ResultConvertible {
        let empty = Task<[R.ResultValueType]>.from(resultValue: [])
        return tasks.reduce(empty) { left, right in
            left.concurrently(right).mapValue { (result, t) in
                result + [t]
            }
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
    public func retry(numberOfTimes: Int, timeout: TimeInterval, nextTimeout: @escaping (TimeInterval)->TimeInterval = { $0 }, queue: DispatchQueue = .main, until: @escaping (Error)->(Bool) = {_ in true }) -> Task<ResultValueType> {
        
        var currentTimeout = timeout
        var numberOfRetries = 0
        
        return Task<ResultValueType> { completion  in
            let serial = SerialDisposable()
            
            func retryImpl() -> Disposable {
                return self.start { result in
                    switch result.result {
                    case .success(let value):
                        completion(.success(value))
                    case .failure(let error):
                        numberOfRetries += 1
                        if until(error) && (numberOfRetries <= numberOfTimes) {
                            serial.swap(with: queue.after(timeInterval: currentTimeout) {
                                serial.swap(with: retryImpl())
                            })
                            currentTimeout = nextTimeout(currentTimeout)
                        } else {
                            completion(.failure(error))
                        }
                    }
                }
            }
            
            serial.swap(with: retryImpl())
            return serial
        }
    }
}
