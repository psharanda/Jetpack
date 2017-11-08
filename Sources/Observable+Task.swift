//
//  Created by Pavel Sharanda on 12.04.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation


extension ObservableProtocol where ValueType: ResultConvertible {
    
    /** Run two tasks concurrently, wait for both to succeed and return both results. If one fails, then other one will be cancelled.
     */
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
            
            return DelegateDisposable {
                withDisposable?.dispose()
                selfDisposable?.dispose()
            }
        }
    }
    
    /**
     Run a number of tasks concurrently.  If at least one task did fail, whole task fails.
     */
    public static func concurrently<R: ObservableProtocol>(_ tasks: [R]) -> Task<[R.ResultValueType]> where R.ValueType: ResultConvertible, R.ValueType == ValueType {
        let empty = Task<[R.ResultValueType]>.from(value: [])
        return tasks.reduce(empty) { left, right in
            left.concurrently(right).mapValue { (result, t) in
                result + [t]
            }
        }
    }
    
    /**
     Run a number of tasks one by one in a sequence. If at least one task did fail, whole sequence fails.
     */
    public static func sequence<R: ObservableProtocol>(_ tasks: [R]) -> Task<[R.ResultValueType]> where R.ValueType: ResultConvertible, R.ValueType == ValueType {
        let empty = Task<[R.ResultValueType]>.from(value: [])
        return tasks.reduce(empty) { left, right in
            left.flatMapLatestValue { result in
                right.mapValue { t in
                    result + [t]
                }
            }
        }
    }
}








