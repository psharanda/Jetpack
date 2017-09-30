//
//  Created by Pavel Sharanda on 11.04.17.
//  Copyright © 2017. All rights reserved.
//

import Foundation

/**
 Building block to chain observables
 */
public struct Observable<T>: ObservableProtocol {
    
    public typealias ValueType = T
    
    private let generator: (@escaping (T) -> Void) -> Disposable
    
    public init(generator: @escaping (@escaping (T) -> Void) -> Disposable) {
        self.generator = generator
    }
    
    public func subscribe(_ observer: @escaping (T) -> Void) -> Disposable {
        return generator(observer)
    }
}

extension Observable {
    
    /**
     Create task with worker which will be run in workerQueue and send result to completionQueue. Worker can produce value or error.
     */
    public init(workerQueue: DispatchQueue, completionQueue: DispatchQueue = .main, worker: @escaping () -> T) {
        self.init { completion in
            return workerQueue.jx.execute(worker: worker, completionQueue: completionQueue) { (value: T) in
                completion(value)
            }
        }
    }
    
    public static func delayed(_ value: T, timeInterval: TimeInterval, queue: DispatchQueue = .main) ->  Observable<T> {
        return Observable<T> { observer in
            return queue.jx.after(timeInterval: timeInterval) {
                observer(value)
            }
        }
    }
    
    public static func dispatched(_ value: T, in queue: DispatchQueue) ->  Observable<T> {
        return Observable<T> { observer in
            return queue.jx.async {
                observer(value)
            }
        }
    }
    
    public static func from(_ value: T) -> Observable<T> {
        return Observable<T> { observer in
            observer(value)
            return EmptyDisposable()
        }
    }
    
    public static var never: Observable<T> {
        return Observable<T> { observer in
            return EmptyDisposable()
        }
    }
}

extension ObservableProtocol {
    public var asObservable: Observable<ValueType> {
        return Observable { observer in
            return self.subscribe(observer)
        }
    }
}



