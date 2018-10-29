//
//  Created by Pavel Sharanda on 29.10.17.
//  Copyright © 2017 Jetpack. All rights reserved.
//

import Foundation

extension Observable {
    
    public static func create(_ generator: @escaping (@escaping (T) -> Void) -> Disposable) -> Observable<T> {
        return Observable(generator)
    }
    
    public static func performed(workerQueue: DispatchQueue, completionQueue: DispatchQueue = .main, worker: @escaping () -> T) ->  Observable<T> {
        return Observable<Void>.dispatched((), in: workerQueue)
            .map(worker)
            .dispatchIn(queue: completionQueue)
    }
    
    public static func delayed(_ value: T, timeInterval: TimeInterval, queue: DispatchQueue = .main) ->  Observable<T> {
        return Observable { observer in
            return queue.jx.asyncAfter(deadline: .now() + timeInterval) {
                observer(value)
            }
        }
    }
    
    public static func dispatched(_ value: T, in queue: DispatchQueue) ->  Observable<T> {
        return Observable { observer in
            return queue.jx.async {
                observer(value)
            }
        }
    }
    
    public static func just(_ value: T) -> Observable<T> {
        return Observable { observer in
            observer(value)
            return EmptyDisposable()
        }
    }
    
    public static var never: Observable<T> {
        return Observable { observer in
            return EmptyDisposable()
        }
    }
    
    public static func deferred(_ f: @escaping ()->T) -> Observable<T> {
        return Observable { observer in
            observer(f())
            return EmptyDisposable()
        }
    }
    
    public static func deferred(_ f: @escaping ()->Observable<T>) -> Observable<T> {
        return Observable { observer in
            return f().subscribe {
                observer($0)
            }
        }
    }
}
