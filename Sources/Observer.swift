//
//  Created by Pavel Sharanda on 11.04.17.
//  Copyright © 2017. All rights reserved.
//

import Foundation

/**
 Building block to chain observables
 */
public struct Observer<T>: Observable {
    
    public typealias ValueType = T
    
    private let generator: (@escaping (T) -> Void) -> Disposable
    
    public init(generator: @escaping (@escaping (T) -> Void) -> Disposable) {
        self.generator = generator
    }
    
    @discardableResult
    public func subscribe(_ observer: @escaping (T) -> Void) -> Disposable {
        return generator(observer)
    }
}

extension Observer {
    
    /**
     Create task with worker which will be run in workerQueue and send result to completionQueue. Worker can produce value or error.
     */
    public init(workerQueue: DispatchQueue, completionQueue: DispatchQueue = .main, worker: @escaping () -> ValueType) {
        self.init { completion in
            return workerQueue.run(worker: worker, completionQueue: completionQueue) { (value: ValueType) in
                completion(value)
            }
        }
    }
    
    public static func delay(timeInterval: TimeInterval, queue: DispatchQueue = .main) ->  Observer<Void> {
        return Observer<Void> { observer in
            return queue.after(timeInterval: timeInterval) {
                observer(())
            }
        }
    }
    
    
    public static func from(value: T) -> Observer<T> {
        return Observer<T> { observer in
            observer(value)
            return EmptyDisposable()
        }
    }
    
    public static var never: Observer<T> {
        return Observer<T> { observer in
            return EmptyDisposable()
        }
    }
}

extension Observable {
    public var asObserver: Observer<ValueType> {
        return Observer { observer in
            return self.subscribe(observer)
        }
    }
}



