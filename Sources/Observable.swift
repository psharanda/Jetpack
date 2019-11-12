//
//  Created by Pavel Sharanda on 11.04.17.
//  Copyright © 2017. All rights reserved.
//

import Foundation

/// Wrapper around some deffered, cancellable work which produces value and will be executed in the future ('subscribe')
public final class Observable<T>: ObserveValueProtocol {
    
    public typealias ValueType = T
    
    private let generator: (@escaping (T) -> Void) -> Disposable
    
    
    public init(_ generator: @escaping (@escaping (T) -> Void) -> Disposable) {
        self.generator = generator
    }
    
    public func subscribe(_ observer: @escaping (T) -> Void) -> Disposable {
        let lock = Lock()
        
        return generator { result in
            lock.synchronized {
                observer(result)
            }
        }
    }
}

extension Observable {

    public static func performed(workerQueue: DispatchQueue, completionQueue: DispatchQueue, worker: @escaping () -> T) ->  Observable<T> {
        return Observable<Void>.dispatched((), on: workerQueue)
            .map(worker)
            .dispatch(on: completionQueue)
    }
    
    public static func delayed(_ value: T, timeInterval: TimeInterval, on queue: DispatchQueue) ->  Observable<T> {
        return Observable { observer in
            return queue.jx_asyncAfter(deadline: .now() + timeInterval) {
                observer(value)
            }
        }
    }
    
    public static func repeated(_ value: T, timeInterval: TimeInterval, on queue: DispatchQueue? = nil) -> Observable<T> {
        return Observable { observer in
            let timer = DispatchSource.makeTimerSource(flags: .strict, queue: queue)

            var strongTimerRef: DispatchSourceTimer? = timer

            timer.setCancelHandler {
                if strongTimerRef != nil {
                    strongTimerRef = nil
                }
            }

            timer.setEventHandler {
                observer(value)
            }
            timer.schedule(deadline: .now() + timeInterval, repeating: timeInterval)
            timer.resume()

            return BlockDisposable {
                timer.cancel()
            }
        }
    }
    
    public static func dispatched(_ value: T, on queue: DispatchQueue) ->  Observable<T> {
        return Observable { observer in
            if queue == .main && Thread.isMainThread {
                observer(value)
                return EmptyDisposable()
            } else {
                return queue.jx_async {
                    observer(value)
                }
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
}

extension Observable where T == Void {
    public static func delayed(timeInterval: TimeInterval, on queue: DispatchQueue) ->  Observable<Void> {
        return Observable.delayed((), timeInterval: timeInterval, on: queue)
    }
       
    public static func repeated(timeInterval: TimeInterval, on queue: DispatchQueue? = nil) -> Observable<Void> {
        return Observable.repeated((), timeInterval: timeInterval, on: queue)
    }
    
    public static var just: Observable<Void> {
        return just(())
    }
}


