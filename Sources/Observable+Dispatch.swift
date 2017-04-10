//
//  Created by Pavel Sharanda on 20.09.16.
//  Copyright © 2016 SnipSnap. All rights reserved.
//

import Foundation

extension Observable {
    
    @discardableResult
    public func delay(timeInterval: TimeInterval, queue: DispatchQueue = DispatchQueue.main) -> Observable<T> {
        let signal = Signal<T>()
        subscribe { result in
            _ = JetPackUtils.after(timeInterval, queue: queue) { [weak signal] in
                guard let signal = signal else { return }
                signal.update(result)
            }
        }
        return signal
    }
    
    @discardableResult
    public func dispatch(in queue: DispatchQueue) -> Observable<T> {
        let signal = Signal<T>()
        subscribe { result in
            
            queue.async { [weak signal] in
                guard let signal = signal else { return }
                signal.update(result)
            }
        }
        return signal
    }
    
    @discardableResult
    public func dispatchInBackgroundQueue() -> Observable<T> {
        return dispatch(in: DispatchQueue.global(qos: DispatchQoS.QoSClass.background))
    }
    
    @discardableResult
    public func dispatchInMainQueue() -> Observable<T> {
        return dispatch(in: DispatchQueue.main)
    }
}
