//
//  Created by Pavel Sharanda on 29.10.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation

extension Observable {
    
    public convenience init(workerQueue: DispatchQueue, completionQueue: DispatchQueue = .main, worker: @escaping () -> T) {
        self.init { completion in
            return workerQueue.jx.execute(worker: worker, completionQueue: completionQueue) { (value: T) in
                completion(value)
            }
        }
    }
    
    public static func create(_ generator: @escaping (@escaping (T) -> Void) -> Disposable) -> Observable<T> {
        return Observable(generator)
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
    
    public static func just(_ value: T) -> Observable<T> {
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
    
    public static func deferred(_ f: @escaping ()->T) -> Observable<T> {
        return Observable<T> { observer in
            observer(f())
            return EmptyDisposable()
        }
    }
    
    public static func deferred(_ f: @escaping ()->Observable<T>) -> Observable<T> {
        return Observable<T> { observer in
            return f().subscribe {
                observer($0)
            }
        }
    }
}
