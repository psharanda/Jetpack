//
//  Created by Pavel Sharanda on 20.09.16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

extension ObservableProtocol where ValueType: ValueConvertible {
    
    public var valueOnly: Observable<ValueType.ValueType> {
        return flatMap { result in
            result.value
        }
    }
}

extension ObservableProtocol where ValueType: ErrorConvertible {
    
    public var errorOnly: Observable<Error> {
        return flatMap { result in
            result.error
        }
    }
}

extension ObservableProtocol where ValueType: ResultConvertible {
    
    var resultOnly: Observable<Result<ValueType.ValueType>> {
        return flatMap {
            $0.result
        }
    }
}


extension ObservableProtocol where ValueType: Error {

    public var localizedDescription: Observable<String> {
        return map { $0.localizedDescription }
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
                return Task.from(error: error)
            }
        }
    }
    
    public func flatMapMergeValue<U>(_ f: @escaping (ResultValueType)->Task<U>) -> Task<U>  {
        return flatMapMerge { result in
            switch result.result {
            case .success(let value):
                return f(value)
            case .failure(let error):
                return Task.from(error: error)
            }
        }
    }
    
    /**
     Transform task success value to value
     */
    public func mapValue<U>(_ transform: @escaping (ResultValueType)-> U) -> Task<U> {
        return map { $0.result.map(transform) }
    }
    
    /**
     Transform task success value  to result
     */
    public func flatMapValue<U>(_ transform: @escaping (ResultValueType)-> Result<U>) -> Task<U> {
        return flatMap { $0.result.flatMap(transform) }
    }
    
    /**
     Transform task success value  to static value
     */
    public func justValue<U>(_ value: U) -> Task<U> {
        return mapValue { _ in value }
    }
    
    /**
     Transform task success value to void value
     */
    public var justValue: Task<Void> {
        return justValue(())
    }
    
    /**
     Transform task success value to optional
     */
    public var optionalizedValue: Task<ResultValueType?> {
        return mapValue { Optional.some($0) }
    }
}

extension ObservableProtocol where ValueType: ValueConvertible {
    /**
     Add handler to perform specific action if task was successful
     */
    public func forEachValue(_ handler:  @escaping(ResultValueType) -> Void) -> Observable<ValueType> {
        return forEach { result in
            if let value = result.value {
                handler(value)
            }
        }
    }
}

extension ObservableProtocol where ValueType: ErrorConvertible {
    
    /**
     Add handler to perform specific action if task failed
     */
    public func forEachError(_ handler:  @escaping(Error) -> Void) -> Observable<ValueType> {
        return forEach { result in
            if let error = result.error {
                handler(error)
            }
        }
    }
}

extension ObservableProtocol where ValueType: ResultConvertible {
    
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
        return Task<ResultValueType> { completion  in
            var currentTimeout = timeout
            var numberOfRetries = 0
            
            let serial = SwapableDisposable()
            
            func retryImpl() -> Disposable {
                return self.subscribe { result in
                    switch result.result {
                    case .success(let value):
                        completion(.success(value))
                    case .failure(let error):
                        numberOfRetries += 1
                        if until(error) && (numberOfRetries <= numberOfTimes) {
                            serial.disposeChild()
                            serial.swap(child: queue.jx.after(timeInterval: currentTimeout) {
                                serial.disposeParent()
                                serial.swap(parent: retryImpl())
                            })
                            currentTimeout = nextTimeout(currentTimeout)
                        } else {
                            completion(.failure(error))
                        }
                    }
                }
            }
            
            serial.swap(parent: retryImpl())
            return serial
        }
    }
}




