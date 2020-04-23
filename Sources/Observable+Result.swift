//
//  Created by Pavel Sharanda on 20.09.16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

extension ObservableProtocol where ValueType: ValueConvertible {
    
    public var valueOnly: Observable<ValueType.ValueType> {
        return compactMap { result in
            result.value
        }
    }
}

extension ObservableProtocol where ValueType: ErrorConvertible {
    
    public var errorOnly: Observable<Error> {
        return compactMap { result in
            result.error
        }
    }
}

extension ObservableProtocol where ValueType: ResultConvertible {
    
    var resultOnly: Task<ValueType.ValueType> {
        return compactMap {
            $0.result
        }
    }
}

extension ObservableProtocol where ValueType: ResultConvertible {
    
    public typealias ResultValueType = ValueType.ValueType
    
    public func flatMapLatestValue<U>(_ f: @escaping (ResultValueType)->Task<U>) -> Task<U>  {
        return flatMapLatest { result in
            switch result.result {
            case .success(let value):
                return f(value)
            case .failure(let error):
                return Task.just(error: error)
            }
        }
    }
    
    public func flatMapMergeValue<U>(_ f: @escaping (ResultValueType)->Task<U>) -> Task<U>  {
        return flatMapMerge { result in
            switch result.result {
            case .success(let value):
                return f(value)
            case .failure(let error):
                return Task.just(error: error)
            }
        }
    }
    
    public func mapValue<U>(_ transform: @escaping (ResultValueType)-> U) -> Task<U> {
        return map { $0.result.map(transform) }
    }
    
    public func compactMapValue<U>(_ transform: @escaping (ResultValueType)-> Result<U>) -> Task<U> {
        return compactMap { $0.result.flatMap(transform) }
    }

    /// Transform task success value  to static value
    public func justValue<U>(_ value: U) -> Task<U> {
        return mapValue { _ in value }
    }
    
    /// Transform task success value to void value
    public var justValue: Task<Void> {
        return justValue(())
    }
    
    /// Transform task success value to optional
    public var optionalizedValue: Task<ResultValueType?> {
        return mapValue { Optional.some($0) }
    }
}

extension ObservableProtocol where ValueType: ValueConvertible {
    /// Add handler to perform specific action on each value
    public func forEachValue(_ handler:  @escaping(ValueType.ValueType) -> Void) -> Observable<ValueType> {
        return forEach { result in
            if let value = result.value {
                handler(value)
            }
        }
    }
}

extension ObservableProtocol where ValueType: ErrorConvertible {
    /// Add handler to perform specific action on each error
    public func forEachError(_ handler:  @escaping(Error) -> Void) -> Observable<ValueType> {
        return forEach { result in
            if let error = result.error {
                handler(error)
            }
        }
    }
}

extension ObservableProtocol where ValueType: ResultConvertible {
    
    /// Run two tasks concurrently, wait for both to succeed and return both results. If one fails, then other one will be cancelled.
    ///
    /// - Parameter with: Other task.
    /// - Returns: New task.
    public func concurrently<R: ObservableProtocol>(_ with: R) -> Task<(ResultValueType,R.ResultValueType)>  where R.ValueType: ResultConvertible {
        
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
            
            return BlockDisposable {
                withDisposable?.dispose()
                selfDisposable?.dispose()
            }
        }
    }
    
    /// Run a number of tasks concurrently. If at least one task did fail, whole task fails.
    ///
    /// - Parameter tasks: List of tasks.
    /// - Returns: New task.
    public static func concurrently<R: ObservableProtocol>(_ tasks: [R]) -> Task<[R.ResultValueType]> where R.ValueType: ResultConvertible, R.ValueType == ValueType {
        let empty = Task<[R.ResultValueType]>.just(value: [])
        return tasks.reduce(empty) { left, right in
            left.concurrently(right).mapValue { (result, t) in
                result + [t]
            }
        }
    }
    
    /// Run a number of tasks one by one in a sequence. If at least one task did fail, whole sequence fails.
    ///
    /// - Parameter tasks: List of tasks.
    /// - Returns: New task.
    public static func sequence<R: ObservableProtocol>(_ tasks: [R]) -> Task<[R.ResultValueType]> where R.ValueType: ResultConvertible, R.ValueType == ValueType {
        let empty = Task<[R.ResultValueType]>.just(value: [])
        return tasks.reduce(empty) { left, right in
            left.flatMapLatestValue { result in
                right.mapValue { t in
                    result + [t]
                }
            }
        }
    }
}

extension ObservableProtocol where ValueType: ResultConvertible {
    
    /// Retry task if error did happen
    ///
    /// - Parameters:
    ///   - numberOfTimes: Number of retries.
    ///   - timeout: Timeout between first and second retry.
    ///   - nextTimeout: Timeout value generator. Can be used for *exponential backoff*. By default generates same value as previous timeout.
    ///   - queue: Queue where you want to deliver results. DispatchQueue.main is default.
    ///   - until: Last error can be checked in this closute. Return false to stop retrying, return true to keep trying. By default it keeps trying for any error
    /// - Returns: New task.
    public func retry(numberOfTimes: Int,
                      timeout: TimeInterval,
                      nextTimeout: @escaping (TimeInterval)->TimeInterval = { $0 },
                      queue: DispatchQueue = .main,
                      until: @escaping (Error)->(Bool) = {_ in true }) -> Task<ResultValueType> {
        return Task<ResultValueType> { completion  in
            var currentTimeout = timeout
            var numberOfRetries = 0
            
            let parent = SwapableDisposable()
            let child = SwapableDisposable()
            
            func retryImpl() -> Disposable {
                return self.subscribe { result in
                    switch result.result {
                    case .success(let value):
                        completion(.success(value))
                    case .failure(let error):
                        numberOfRetries += 1
                        if until(error) && (numberOfRetries <= numberOfTimes) {
                            child.swap(with: queue.jx.asyncAfter(deadline: .now() + currentTimeout) {
                                parent.swap(with: retryImpl())
                            })
                            currentTimeout = nextTimeout(currentTimeout)
                        } else {
                            completion(.failure(error))
                        }
                    }
                }
            }
            
            parent.swap(with: retryImpl())
            return parent.with(disposable: child)
        }
    }
}
